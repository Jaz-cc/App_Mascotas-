import 'package:flutter/material.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';

class ChatIaPage extends StatefulWidget {
  const ChatIaPage({super.key});

  @override
  State<ChatIaPage> createState() => _ChatIaPageState();
}

class _ChatIaPageState extends State<ChatIaPage> {

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

  // Preguntas rapidas
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

  // Genera una respuesta local según las palabras de la consulta.
  String _generarRespuestaIa(String query) {
    final String text = query.toLowerCase().trim();

    // Detecta saludos antes de evaluar otras palabras.
    if (text == 'hola' ||
        text.startsWith('hola ') ||
        text.startsWith('buenas') ||
        text.startsWith('buenos días') ||
        text.startsWith('buenas tardes') ||
        text.startsWith('buenas noches') ||
        text == 'saludos') {
      return '¡Hola! 😊🐾 Estoy aquí para orientarte sobre el cuidado de tu mascota. ¿Qué te gustaría saber?';
    }

    // Consultas que no corresponden
    final List<String> temasAjenos = [
      'fútbol',
      'futbol',
      'política',
      'politica',
      'dólar',
      'dolar',
      'noticias',
      'canción',
      'cancion',
      'película',
      'pelicula',
      'matemáticas',
      'matematicas',
      'videojuego',
      'capital de',
    ];

    if (temasAjenos.any((palabra) => text.contains(palabra))) {
      return '⚠️ Soy Jamika AI, un asistente enfocado en el cuidado de las mascotas. 🐾\n\nPuedo orientarte sobre alimentación, hábitos, síntomas, medicamentos y cuidados generales de perros y gatos.';
    }

    // Detecta preguntas relacionadas con frutas y alimentos tóxicos.
    if (text.contains('fruta') ||
        text.contains('manzana') ||
        text.contains('plátano') ||
        text.contains('platano') ||
        text.contains('uva') ||
        text.contains('pasas') ||
        text.contains('chocolate') ||
        text.contains('alimento') ||
        text.contains('qué puede comer') ||
        text.contains('que puede comer') ||
        text.contains('puede comer mi perro') ||
        text.contains('puede comer mi gato')) {
      return '🍎 Sobre la alimentación de tu mascota:\n\n'
          '• Algunas frutas, como la manzana sin semillas, el plátano y la sandía sin semillas ni cáscara, pueden ofrecerse en pequeñas cantidades a muchos perros.\n'
          '• Nunca ofrezcas uvas ni pasas a los perros, ya que pueden causar daño renal.\n'
          '• El chocolate también es tóxico para perros y gatos.\n\n'
          'La seguridad de cada alimento depende de la especie y de la cantidad. Si tu mascota ingirió algo tóxico, contacta a un veterinario de inmediato.';
    }

    // Detecta preguntas sobre el consumo excesivo de agua.
    if (text.contains('agua') ||
        text.contains('sed') ||
        text.contains('bebe mucho') ||
        text.contains('bebe demasiada') ||
        text.contains('toma tanta agua') ||
        text.contains('toma mucha agua')) {
      return '🐾 Si tu mascota está tomando más agua de lo habitual, puede deberse al calor, a su alimentación o a algún problema de salud.\n\n'
          'Observa si también orina más, pierde peso, vomita o presenta cambios en su comportamiento. Si el aumento persiste o aparece junto con otros síntomas, agenda una revisión veterinaria.\n\n'
          'No restrinjas su acceso al agua.';
    }

    // Detecta perdida de apetito o rechazo de alimentos.
    if (text.contains('no quiere comer') ||
        text.contains('no come') ||
        text.contains('dejó de comer') ||
        text.contains('dejo de comer') ||
        text.contains('sin apetito') ||
        text.contains('no tiene apetito')) {
      return '🐶🐱 La falta de apetito puede tener distintas causas, como estrés, molestias dentales o enfermedades.\n\n'
          'Observa cuánto tiempo lleva sin comer y si presenta vómitos, diarrea, dolor o decaimiento. Si es un cachorro, un gatito o una mascota con otros problemas de salud, busca orientación veterinaria pronto.\n\n'
          'Si no come durante un día, contacta a su veterinario; si está muy decaído o presenta síntomas graves, busca atención urgente.';
    }

    // Detecta aumento del apetito.
    if (text.contains('come mucho') ||
        text.contains('mucha hambre') ||
        text.contains('más hambre') ||
        text.contains('mas hambre') ||
        text.contains('aumento del apetito') ||
        text.contains('come demasiado')) {
      return '🐾 Un aumento inusual del apetito puede relacionarse con la actividad física, cambios en la alimentación o problemas de salud, como parásitos u otras enfermedades.\n\n'
          'Revisa las porciones y observa si también pierde peso, bebe más agua o cambia su comportamiento. Si el cambio persiste, consulta con un veterinario.';
    }

    // Detecta preguntas relacionadas con fiebre.
    if (text.contains('fiebre') ||
        text.contains('temperatura') ||
        text.contains('está caliente') ||
        text.contains('esta caliente') ||
        text.contains('temblores') ||
        text.contains('tiembla')) {
      return '🌡️ Si sospechas que tu perro o gato tiene fiebre, no te guíes únicamente por si tiene la nariz caliente o seca.\n\n'
          'La temperatura corporal debe medirse con un termómetro adecuado. En perros y gatos suele estar aproximadamente entre 38 y 39.2 °C, aunque puede variar.\n\n'
          'Si la temperatura es elevada o presenta decaimiento, temblores, vómitos u otros síntomas, contacta a un veterinario. No le administres medicamentos humanos.';
    }

    // Detecta preguntas sobre citas veterinarias.
    if (text.contains('cita') ||
        text.contains('agendar') ||
        text.contains('veterinario') ||
        text.contains('consulta veterinaria')) {
      return '📅 Para cuidar la salud de tu mascota, es importante mantener sus revisiones veterinarias al día.\n\n'
          'Puedes organizar la fecha de su próxima consulta en el módulo de citas de JamikaPet, si está disponible en tu aplicación.\n\n'
          'Si tu mascota presenta síntomas graves o empeora rápidamente, no esperes a una cita programada.';
    }

    // Detecta consultas sobre medicamentos y tratamientos.
    if (text.contains('medicamento') ||
        text.contains('medicina') ||
        text.contains('dosis') ||
        text.contains('tratamiento') ||
        text.contains('pastilla') ||
        text.contains('antibiótico') ||
        text.contains('antibiotico')) {
      return '💊 Para administrar un medicamento de forma segura:\n\n'
          '• Sigue la dosis y los horarios indicados por el veterinario.\n'
          '• Registra el nombre del medicamento y la próxima toma.\n'
          '• No cambies la dosis ni administres medicamentos humanos sin indicación profesional.\n\n'
          'Puedes organizar esta información en el módulo de medicamentos de JamikaPet, si está disponible.';
    }

    // Detecta vómitos y diarrea.
    if (text.contains('vómito') ||
        text.contains('vomito') ||
        text.contains('vomita') ||
        text.contains('diarrea') ||
        text.contains('sangre en las heces')) {
      return '🐾 Los vómitos y la diarrea pueden tener distintas causas, desde molestias digestivas hasta enfermedades que requieren tratamiento.\n\n'
          'Observa su frecuencia, si hay sangre y si tu mascota puede beber agua. Si hay sangre, vómitos repetidos, debilidad intensa, dolor o signos de deshidratación, busca atención veterinaria urgente.\n\n'
          'No le administres medicamentos por tu cuenta.';
    }

    // Detecta preguntas sobre vacunas.
    if (text.contains('vacuna') || text.contains('vacunación')) {
      return '💉 Las vacunas ayudan a proteger a perros y gatos contra enfermedades importantes.\n\n'
          'El calendario depende de la especie, la edad, sus antecedentes y el entorno. Consulta con tu veterinario para mantener al día su esquema de vacunación.';
    }

    // Detecta preguntas sobre pulgas y garrapatas.
    if (text.contains('pulga') ||
        text.contains('garrapata') ||
        text.contains('parásito') ||
        text.contains('parasito') ||
        text.contains('desparasitar')) {
      return '🐾 Las pulgas, garrapatas y otros parásitos pueden afectar la salud de tu mascota.\n\n'
          'Usa únicamente productos adecuados para su especie, edad y peso. Algunos productos para perros son peligrosos para los gatos.\n\n'
          'Consulta a un veterinario para elegir el tratamiento y la frecuencia correctos.';
    }

    // Detecta preguntas sobre baño e higiene.
    if (text.contains('baño') ||
        text.contains('bano') ||
        text.contains('bañar') ||
        text.contains('bañar') ||
        text.contains('higiene') ||
        text.contains('cepillar')) {
      return '🧼 La higiene de tu mascota depende de su especie, pelaje y necesidades.\n\n'
          'Utiliza productos específicos para animales, cepilla su pelaje cuando corresponda y revisa con cuidado sus orejas, piel y uñas.\n\n'
          'Si observas heridas, mal olor persistente, irritación o picazón intensa, consulta con un veterinario.';
    }

    // Detecta preguntas sobre comportamiento.
    if (text.contains('comportamiento') ||
        text.contains('agresivo') ||
        text.contains('agresividad') ||
        text.contains('triste') ||
        text.contains('ansiedad') ||
        text.contains('ladra mucho') ||
        text.contains('maúlla') ||
        text.contains('maulla')) {
      return '🐶🐱 Los cambios de comportamiento pueden estar relacionados con el entorno, el estrés, el aburrimiento o molestias físicas.\n\n'
          'Observa cuándo comenzó el cambio y qué situaciones lo provocan. Si aparece de repente, se acompaña de dolor o afecta sus actividades habituales, conviene consultar con un veterinario.';
    }

    // Detecta preguntas sobre esterilización.
    if (text.contains('esterilización') ||
        text.contains('esterilizacion') ||
        text.contains('esterilizar') ||
        text.contains('castrar')) {
      return '🐾 La esterilización es un procedimiento que puede aportar beneficios de salud y ayudar a prevenir camadas no planificadas.\n\n'
          'La edad y el momento adecuados dependen de la especie, el estado de salud y las características de tu mascota. Habla con un veterinario para conocer sus opciones.';
    }

    // Respuesta general cuando no coincide con ningún tema.
    return '🐾 Gracias por tu consulta: "$query".\n\n'
        'Puedo orientarte sobre alimentación, higiene, comportamiento, vacunas, medicamentos y señales de alerta en perros y gatos.\n\n'
        'Para ayudarte mejor, dime qué animal tienes, su edad aproximada y qué situación has observado.';
  }

  // Envía un mensaje y simula una respuesta del asistente.
  Future<void> _sendMessage(String text) async {
    final String mensaje = text.trim();

    // No permite enviar mensajes vacíos ni duplicar envíos
    // mientras el asistente está preparando una respuesta.
    if (mensaje.isEmpty || _isTyping) return;

    final String timeNow = TimeOfDay.now().format(context);

    setState(() {
      // Elimina la sugerencia elegida, si corresponde.
      _sugerencias.removeWhere(
        (sugerencia) => sugerencia == mensaje,
      );

      // Añade el mensaje del usuario a la conversación.
      _messages.add({
        'isUser': true,
        'text': mensaje,
        'time': timeNow,
      });

      // Activa el indicador de escritura.
      _isTyping = true;
    });

    // Limpia el campo de texto después de enviar.
    _textController.clear();

    // Desplaza el chat para mostrar el nuevo mensaje.
    _scrollToBottom();

    // Simula el tiempo de respuesta del asistente.
    await Future.delayed(const Duration(milliseconds: 1200));

    // Evita actualizar la pantalla si ya fue cerrada.
    if (!mounted) return;

    setState(() {
      // Añade la respuesta generada localmente.
      _messages.add({
        'isUser': false,
        'text': _generarRespuestaIa(mensaje),
        'time': TimeOfDay.now().format(context),
      });

      // Oculta el indicador de escritura.
      _isTyping = false;
    });

    _scrollToBottom();
  }

  // Desplaza la lista hasta el último mensaje después de actualizarla.
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
      // Encabezado de la pantalla.

      appBar: const HeaderAppBar(
        titulo: 'JAMIKA IA',
        subtitulo: 'Asistente IA - 🟢 En Linea',
        mostrarLogo: true,
        mostrarRegreso: true,
        icon: Icons.smart_toy_outlined,
      ),

      body: Column(
        children: [
          // Aviso para explicar el propósito y los límites del asistente.
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            color: const Color(0xFFFFF3CD),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Color(0xFF856404),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Asistente de orientación general. No sustituye la valoración de un veterinario.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF856404),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de mensajes de la conversación.
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> msg = _messages[index];
                final bool isUser = msg['isUser'] as bool;

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF1F7A70)
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser
                            ? const Radius.circular(16)
                            : Radius.zero,
                        bottomRight: isUser
                            ? Radius.zero
                            : const Radius.circular(16),
                      ),
                      border: isUser
                          ? null
                          : Border.all(
                              color: const Color(0xFFB2DFDB),
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        // Contenido del mensaje.
                        Text(
                          msg['text'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            color: isUser
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Hora del mensaje.
                        Text(
                          msg['time'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: isUser
                                ? Colors.white70
                                : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Indicador que aparece mientras se prepara la respuesta.
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                bottom: 8,
              ),
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
                    'Jamika AI está escribiendo...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.teal.shade800,
                    ),
                  ),
                ],
              ),
            ),

          // Preguntas sugeridas para facilitar el uso del chat.
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
                      side: const BorderSide(
                        color: Color(0xFFB2DFDB),
                      ),
                      label: Text(
                        sugerencia,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1F7A70),
                        ),
                      ),

                      // Desactiva las sugerencias durante la respuesta.
                      onPressed: _isTyping
                          ? null
                          : () => _sendMessage(sugerencia),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Campo donde el usuario escribe su consulta.
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Color(0xFFB2DFDB),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,

                    // Impide enviar nuevos mensajes mientras se responde.
                    enabled: !_isTyping,

                    decoration: InputDecoration(
                      hintText: 'Escribe tu consulta sobre mascotas...',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black45,
                      ),
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

                    // Permite enviar con el botón de enviar del teclado.
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),

                // Botón para enviar el mensaje.
                CircleAvatar(
                  backgroundColor: const Color(0xFF1F7A70),
                  child: IconButton(
                    tooltip: 'Enviar mensaje',
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _isTyping
                        ? null
                        : () => _sendMessage(_textController.text),
                  ),
                ),
              ],
            ),
          ),
          // ===============================================================
          // PIE DE PÁGINA / BARRA INFERIOR
          // ===============================================================
          AppBottomNavigation(
            currentIndex: 1,
            onItemSelected: (index) {
              switch (index) {
                case 0:
                  Navigator.pushNamed(context, AppRoutes.home,);
                  break;

                case 1:
                  Navigator.pushNamed(context, AppRoutes.menu,);
                  break;

                case 2:
                  Navigator.pushNamed(context, AppRoutes.pets,);
                  break;
                
                case 3:
                  Navigator.pushNamed(context, AppRoutes.perfil,);
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  
}