import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';
import 'package:jamikapet/src/services/ai_service.dart';

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
  Uint8List? _selectedImageBytes; // Se guarda la imagen

  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text':
          '¡Hola! 🐾 Soy Jamika AI, tu asistente de orientación sobre mascotas. ¿En qué puedo ayudarte hoy?',
      'time': '10:00 AM',
      'imageBytes': null,
    },
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

  // Selecciona la foto 
  Future<void> _seleccionarImagen() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        final Uint8List bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
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
    final String mensaje = text.trim();
    final Uint8List? bytesImagen = _selectedImageBytes;

    if ((mensaje.isEmpty && bytesImagen == null) || _isTyping) return;

    final String timeNow = TimeOfDay.now().format(context);

    setState(() {
      _sugerencias.removeWhere((sugerencia) => sugerencia == mensaje);
      _messages.add({
        'isUser': true,
        'text': mensaje.isNotEmpty ? mensaje : '📷 [Fotografía adjuntada]',
        'time': timeNow,
        'imageBytes': bytesImagen,
      });
      _isTyping = true;
      _selectedImageBytes = null;
    });

    _textController.clear();
    _scrollToBottom();

    try {
      final respuestaIa = await IaService.enviarConsulta(
        mensaje.isNotEmpty ? mensaje : 'He adjuntado una fotografía de mi mascota.',
      );

      if (!mounted) return;

      setState(() {
        _messages.add({
          'isUser': false,
          'text': respuestaIa,
          'time': TimeOfDay.now().format(context),
          'imageBytes': null,
        });
        _isTyping = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add({
          'isUser': false,
          'text':
              '⚠️ Error al conectar con la IA: ${e.toString().replaceAll("Exception: ", "")}',
          'time': TimeOfDay.now().format(context),
          'imageBytes': null,
        });
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

  @override
  Widget build(BuildContext context) {
    const primaryMint = Color(0xFFE2F4F1);

    return Scaffold(
      backgroundColor: primaryMint,
      appBar: const HeaderAppBar(
        titulo: 'JAMIKA IA',
        subtitulo: 'Asistente Virtual',
        mostrarLogo: true,
        mostrarRegreso: true,
        icon: Icons.smart_toy_outlined,
      ),
      body: Column(
        children: [
          // AVISO INFORMATIVO
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFFFF3CD),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Color(0xFF856404)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Asistente de orientación general. No sustituye la valoración de un veterinario.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF856404)),
                  ),
                ),
              ],
            ),
          ),
        // LISTA DE MENSAJES
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> msg = _messages[index];
                final bool isUser = msg['isUser'] as bool;
                final Uint8List? imageBytes = msg['imageBytes'] as Uint8List?;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF1F7A70) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                      ),
                      border: isUser ? null : Border.all(color: const Color(0xFFB2DFDB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (imageBytes != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              imageBytes,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          msg['text'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            color: isUser ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: isUser ? Colors.white70 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // INDICADOR DE PROCESAMIENTO
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF1F7A70),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Jamika AI está analizando tu consulta...',
                    style: TextStyle(fontSize: 12, color: Colors.teal.shade800),
                  ),
                ],
              ),
            ),
          // PREGUNTAS SUGERIDAS
          if (_sugerencias.isNotEmpty) ...[
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _sugerencias.length,
                itemBuilder: (context, index) {
                  final String sugerencia = _sugerencias[index];

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFB2DFDB)),
                      label: Text(
                        sugerencia,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF1F7A70)),
                      ),
                      onPressed: _isTyping ? null : () => _sendMessage(sugerencia),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
          // VISTA PREVIA DE LA FOTOGRAFÍA
          if (_selectedImageBytes != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFD1F0EE),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _selectedImageBytes!,
                      width: 45,
                      height: 45,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Foto de tu mascota adjuntada',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F7A70),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.redAccent),
                    onPressed: () => setState(() => _selectedImageBytes = null),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFB2DFDB))),
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Adjuntar foto de mascota',
                  icon: const Icon(
                    Icons.add_a_photo_outlined,
                    color: Color(0xFF1F7A70),
                    size: 24,
                  ),
                  onPressed: _isTyping ? null : _seleccionarImagen,
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    enabled: !_isTyping,
                    decoration: InputDecoration(
                      hintText: _selectedImageBytes != null
                          ? 'Añade un comentario sobre la foto...'
                          : 'Escribe tu consulta sobre mascotas...',
                      hintStyle: const TextStyle(fontSize: 14, color: Colors.black45),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: const Color(0xFFE2F4F1),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF1F7A70),
                  child: IconButton(
                    tooltip: 'Enviar mensaje',
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed:
                        _isTyping ? null : () => _sendMessage(_textController.text),
                  ),
                ),
              ],
            ),
          ),
        // BARRA DE NAVEGACIÓN INFERIOR
          AppBottomNavigation(
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
        ],
      ),
    );
  }
}