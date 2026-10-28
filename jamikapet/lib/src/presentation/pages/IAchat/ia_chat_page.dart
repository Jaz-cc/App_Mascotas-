import 'package:flutter/material.dart';
import 'package:jamikapet/src/services/ai_service.dart';
import 'package:jamikapet/src/presentation/pages/menu/menu_page.dart';
import 'package:jamikapet/src/presentation/pages/usuario/perfilUsuario_page.dart';

class ChatIaPage extends StatefulWidget {
  const ChatIaPage({super.key});

  @override
  State<ChatIaPage> createState() => _ChatIaPageState();
}

class _ChatIaPageState extends State<ChatIaPage> {
  final int _selectedIndex = 1;

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text':
          '¡Hola! 🐾 Soy Jamika AI, tu asistente de orientación sobre mascotas. ¿En qué puedo ayudarte hoy?',
      'time': '10:00 AM',
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

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MenuPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PerfilUsuarioPage()),
      );
    } else if (index == 0) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _sendMessage(String text) async {
    final String mensaje = text.trim();
    if (mensaje.isEmpty || _isTyping) return;

    final String timeNow = TimeOfDay.now().format(context);

    setState(() {
      _sugerencias.removeWhere((sugerencia) => sugerencia == mensaje);
      _messages.add({
        'isUser': true,
        'text': mensaje,
        'time': timeNow,
      });
      _isTyping = true;
    });

    _textController.clear();
    _scrollToBottom();

    try {
      // PETICIÓN IA SERVICE
      final respuestaIa = await IaService.enviarConsulta(mensaje);

      if (!mounted) return;

      setState(() {
        _messages.add({
          'isUser': false,
          'text': respuestaIa,
          'time': TimeOfDay.now().format(context),
        });
        _isTyping = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add({
          'isUser': false,
          'text': '⚠️ Error al conectar con la IA: ${e.toString().replaceAll("Exception: ", "")}',
          'time': TimeOfDay.now().format(context),
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
    const headerMint = Color(0xFFC5ECE5);
    const darkText = Colors.black87;

    return Scaffold(
      backgroundColor: primaryMint,
      appBar: AppBar(
        backgroundColor: headerMint,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: darkText),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFF1F7A70),
              radius: 18,
              child: Icon(Icons.smart_toy_outlined, color: Colors.white, size: 20),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asistente IA',
                  style: TextStyle(color: darkText, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'JamikaPet AI • En línea',
                  style: TextStyle(color: Colors.teal, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
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
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> msg = _messages[index];
                final bool isUser = msg['isUser'] as bool;

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
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
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
                    'Jamika AI está consultando al servidor...',
                    style: TextStyle(fontSize: 12, color: Colors.teal.shade800),
                  ),
                ],
              ),
            ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFB2DFDB))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    enabled: !_isTyping,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu consulta sobre mascotas...',
                      hintStyle: const TextStyle(fontSize: 14, color: Colors.black45),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: const Color(0xFFE2F4F1),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
                    onPressed: _isTyping ? null : () => _sendMessage(_textController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildStandardBottomNavigationBar(),
    );
  }

  Widget _buildStandardBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE2F4F1),
        border: Border(top: BorderSide(color: Color(0xFFB2DFDB), width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFFE2F4F1),
        selectedItemColor: const Color(0xFF00695C),
        unselectedItemColor: const Color(0xFF616161),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 26,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            activeIcon: Icon(Icons.pets),
            label: 'Mascotas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}