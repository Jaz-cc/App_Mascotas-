import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';
import 'package:jamikapet/src/services/ai_service.dart';

class _C {
  static const fondo = Color(0xFFE8F6F3);
  static const primario = Color(0xFF1F7A70);
  static const primarioClaro = Color(0xFF55C8BD);
  static const borde = Color(0xFFCBE5E2);
  static const tinta = Color(0xFF16302D);
  static const textoSuave = Color(0xFF5C7A77);
  static const error = Color(0xFFD34F4F);
}

class _ChatMessage {
  final bool isUser;
  final String text;
  final DateTime time;
  final Uint8List? imageBytes;
  final bool isError;

  const _ChatMessage({
    required this.isUser,
    required this.text,
    required this.time,
    this.imageBytes,
    this.isError = false,
  });
}

class ChatIaPage extends StatefulWidget {
  const ChatIaPage({super.key});

  @override
  State<ChatIaPage> createState() => _ChatIaPageState();
}

class _ChatIaPageState extends State<ChatIaPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  bool _isTyping = false;
  bool _mostrarAviso = true;
  Uint8List? _selectedImageBytes;
  String _selectedImageMime = 'image/jpeg';

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      isUser: false,
      text:
          '¡Hola! 🐾 Soy Jamika AI, tu asistente de orientación sobre mascotas. '
          '¿En qué puedo ayudarte hoy?',
      time: DateTime.now(),
    ),
  ];

  final List<String> _sugerencias = [
    '🍎 ¿Qué frutas puede comer mi perro?',
    '💊 Recordatorio de medicamentos',
    '🐶 Síntomas de fiebre en perros',
    '🐱 ¿Por qué mi gato toma tanta agua?',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _mimeDesdeNombre(String nombre) {
    final n = nombre.toLowerCase();
    if (n.endsWith('.png')) return 'image/png';
    if (n.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg'; // .jpg y .jpeg (image/jpg no es un MIME válido)
  }

  Future<void> _seleccionarImagen() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
      );

      if (image != null) {
        final Uint8List bytes = await image.readAsBytes();
        if (!mounted) return;
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageMime = image.mimeType ?? _mimeDesdeNombre(image.name);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  Future<void> _sendMessage(String text) async {
    final String mimeImagen = _selectedImageMime;
    final String mensaje = text.trim();
    final Uint8List? bytesImagen = _selectedImageBytes;

    if ((mensaje.isEmpty && bytesImagen == null) || _isTyping) return;

    setState(() {
      _sugerencias.removeWhere((s) => s == mensaje);
      _messages.add(
        _ChatMessage(
          isUser: true,
          text: mensaje,
          time: DateTime.now(),
          imageBytes: bytesImagen,
        ),
      );
      _isTyping = true;
      _selectedImageBytes = null;
    });

    _textController.clear();
    _scrollToBottom();

    try {
      final String respuestaIa = bytesImagen != null
          ? await IaService.enviarConsultaConImagen(
              imageBytes: bytesImagen,
              mimeType: mimeImagen,
              prompt: mensaje,
            )
          : await IaService.enviarConsulta(mensaje);

      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(isUser: false, text: respuestaIa, time: DateTime.now()),
        );
        _isTyping = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            isUser: false,
            isError: true,
            text:
                'No pude conectar con la IA: ${e.toString().replaceAll("Exception: ", "")}',
            time: DateTime.now(),
          ),
        );
        _isTyping = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String _formatHora(DateTime t) => MaterialLocalizations.of(
    context,
  ).formatTimeOfDay(TimeOfDay.fromDateTime(t));

  // ───────────────────────── BUILD ─────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.fondo,
      appBar: const HeaderAppBar(
        titulo: 'JAMIKA IA',
        subtitulo: 'Asistente Virtual',
        mostrarLogo: true,
        mostrarRegreso: true,
        icon: Icons.smart_toy_outlined,
      ),
      body: Column(
        children: [
          if (_mostrarAviso) _aviso(),
          Expanded(child: _listaMensajes()),
          _compositor(),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 1,
        onItemSelected: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, AppRoutes.home);
              break;
            case 1:
              Navigator.pushNamed(context, AppRoutes.menu);
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.pets);
              break;
            case 3:
              Navigator.pushNamed(context, AppRoutes.perfil);
              break;
          }
        },
      ),
    );
  }

  Widget _aviso() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3E1A3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: Color(0xFF856404),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Orientación general. No sustituye la valoración de un veterinario.',
              style: TextStyle(
                fontSize: 11.5,
                height: 1.3,
                color: Color(0xFF856404),
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Cerrar aviso',
            onPressed: () => setState(() => _mostrarAviso = false),
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
              color: Color(0xFF856404),
            ),
          ),
        ],
      ),
    );
  }

  Widget _listaMensajes() {
    final total = _messages.length + (_isTyping ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      itemCount: total,
      itemBuilder: (context, index) {
        if (index == _messages.length) return _burbujaEscribiendo();
        return _burbuja(_messages[index]);
      },
    );
  }

  Widget _avatarIa() {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [_C.primario, _C.primarioClaro],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.pets, color: Colors.white, size: 17),
    );
  }

  Widget _burbuja(_ChatMessage msg) {
    final isUser = msg.isUser;
    final maxWidth = MediaQuery.of(context).size.width * 0.74;

    final Color textColor = isUser
        ? Colors.white
        : (msg.isError ? _C.error : _C.tinta);

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      decoration: BoxDecoration(
        gradient: isUser
            ? const LinearGradient(
                colors: [_C.primario, Color(0xFF2A9A8D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isUser ? null : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
        border: isUser
            ? null
            : Border.all(
                color: msg.isError ? const Color(0xFFF0CACA) : _C.borde,
              ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F3D3A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (msg.imageBytes != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                msg.imageBytes!,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            if (msg.text.isNotEmpty) const SizedBox(height: 8),
          ],
          if (msg.text.isNotEmpty)
            SelectableText(
              msg.text,
              style: TextStyle(fontSize: 14.5, height: 1.4, color: textColor),
            ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _formatHora(msg.time),
              style: TextStyle(
                fontSize: 10,
                color: isUser ? Colors.white70 : _C.textoSuave,
              ),
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[_avatarIa(), const SizedBox(width: 8)],
          Flexible(child: bubble),
        ],
      ),
    );
  }

  Widget _burbujaEscribiendo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _avatarIa(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: _C.borde),
            ),
            child: const _PuntosEscribiendo(),
          ),
        ],
      ),
    );
  }

  Widget _compositor() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x140F3D3A),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedImageBytes != null) _vistaPreviaImagen(),
          if (_sugerencias.isNotEmpty && _selectedImageBytes == null)
            _sugerenciasChips(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _botonRedondo(
                icono: Icons.add_a_photo_outlined,
                tooltip: 'Adjuntar foto de mascota',
                fondo: _C.fondo,
                colorIcono: _C.primario,
                onPressed: _isTyping ? null : _seleccionarImagen,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _textController,
                  enabled: !_isTyping,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  style: const TextStyle(fontSize: 14.5, color: _C.tinta),
                  decoration: InputDecoration(
                    hintText: _selectedImageBytes != null
                        ? 'Añade un comentario sobre la foto…'
                        : 'Escribe tu consulta sobre mascotas…',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: _C.textoSuave,
                    ),
                    filled: true,
                    fillColor: _C.fondo,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _textController,
                builder: (context, value, _) {
                  final puedeEnviar =
                      (value.text.trim().isNotEmpty ||
                          _selectedImageBytes != null) &&
                      !_isTyping;
                  return AnimatedScale(
                    scale: puedeEnviar ? 1 : 0.9,
                    duration: const Duration(milliseconds: 150),
                    child: _botonRedondo(
                      icono: Icons.arrow_upward_rounded,
                      tooltip: 'Enviar mensaje',
                      fondo: puedeEnviar ? _C.primario : _C.borde,
                      colorIcono: Colors.white,
                      onPressed: puedeEnviar
                          ? () => _sendMessage(_textController.text)
                          : null,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _botonRedondo({
    required IconData icono,
    required String tooltip,
    required Color fondo,
    required Color colorIcono,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: fondo,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icono, color: colorIcono, size: 22),
      ),
    );
  }

  Widget _sugerenciasChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _sugerencias.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final sugerencia = _sugerencias[index];
          return ActionChip(
            backgroundColor: _C.fondo,
            side: const BorderSide(color: _C.borde),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            label: Text(
              sugerencia,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _C.primario,
              ),
            ),
            onPressed: _isTyping ? null : () => _sendMessage(sugerencia),
          );
        },
      ),
    );
  }

  Widget _vistaPreviaImagen() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.memory(
                _selectedImageBytes!,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: -8,
              right: -8,
              child: GestureDetector(
                onTap: () => setState(() => _selectedImageBytes = null),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: _C.tinta,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tres puntos animados para el indicador de "escribiendo".
class _PuntosEscribiendo extends StatefulWidget {
  const _PuntosEscribiendo();

  @override
  State<_PuntosEscribiendo> createState() => _PuntosEscribiendoState();
}

class _PuntosEscribiendoState extends State<_PuntosEscribiendo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final fase = (_controller.value - i * 0.18) % 1.0;
            final opacidad = (fase < 0.5 ? fase * 2 : (1 - fase) * 2).clamp(
              0.25,
              1.0,
            );
            return Container(
              margin: EdgeInsets.only(right: i == 2 ? 0 : 5),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _C.primario.withValues(alpha: opacidad),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}