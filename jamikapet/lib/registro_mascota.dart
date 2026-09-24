import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Paleta de la pantalla
class _Paleta {
  static const fondo = Color(0xFFE6F6F5);
  static const barra = Color(0xFFAEDFD9);
  static const primario = Color(0xFF55C8BD);
  static const primarioOscuro = Color(0xFF23786F);
  static const tinta = Color(0xFF1B3634);
  static const tintaSuave = Color(0xFF4F6B68);
  static const campo = Color(0xFFF1FAF9);
  static const borde = Color(0xFFCBE5E2);
  static const pista = Color(0xFFE0F3F1);
  static const error = Color(0xFFB3261E);
}

class RegistroMascotaScreen extends StatefulWidget {
  const RegistroMascotaScreen({super.key});

  @override
  State<RegistroMascotaScreen> createState() => _RegistroMascotaScreenState();
}

class _RegistroMascotaScreenState extends State<RegistroMascotaScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController edadController = TextEditingController();

  String genero = "Macho";
  String tipoMascota = "";

  @override
  void dispose() {
    nombreController.dispose();
    pesoController.dispose();
    edadController.dispose();
    super.dispose();
  }

  void registrarMascota() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      _mostrarMensaje("Revisa los campos marcados", esError: true);
      return;
    }

    // Aquí posteriormente guardaremos la mascota
    debugPrint("Nombre: ${nombreController.text.trim()}");
    debugPrint("Género: $genero");
    debugPrint("Tipo: $tipoMascota");
    debugPrint("Peso: ${pesoController.text} kg");
    debugPrint("Edad: ${edadController.text}");

    _mostrarMensaje("Mascota registrada correctamente 🐾");
  }

  void _mostrarMensaje(String texto, {bool esError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          backgroundColor:
              esError ? _Paleta.error : _Paleta.primarioOscuro,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text(
            texto,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      );
  }

  // ---------------- ESTILOS ----------------

  InputDecoration _decoracion({String? sufijo, Widget? suffixIcon}) {
    OutlineInputBorder borde(Color color, [double ancho = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: ancho),
      );
    }

    return InputDecoration(
      filled: true,
      fillColor: _Paleta.campo,
      suffixText: sufijo,
      suffixStyle: const TextStyle(color: _Paleta.tintaSuave, fontSize: 15),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: borde(_Paleta.borde),
      enabledBorder: borde(_Paleta.borde),
      focusedBorder: borde(_Paleta.primarioOscuro, 2),
      errorBorder: borde(_Paleta.error),
      focusedErrorBorder: borde(_Paleta.error, 2),
      errorStyle: const TextStyle(color: _Paleta.error, fontSize: 12.5),
    );
  }

  Widget _etiqueta(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: _Paleta.tinta,
        ),
      ),
    );
  }

  // ---------------- BUILD ----------------

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: _Paleta.fondo,

        // ---------------- BARRA SUPERIOR ----------------
        appBar: AppBar(
          backgroundColor: _Paleta.barra,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            tooltip: "Volver",
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _Paleta.tinta,
              size: 22,
            ),
          ),
          title: Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/img/icon_App.jpeg',
                width: 34,
                height: 34,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        // ---------------- CONTENIDO ----------------
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TÍTULO
                const Text(
                  "Registro de la mascota",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _Paleta.tinta,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "",
                  style: TextStyle(fontSize: 15, color: _Paleta.tintaSuave),
                ),

                const SizedBox(height: 20),

                // TARJETA DEL FORMULARIO
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x140F3D3A),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---------------- NOMBRE ----------------
                        _etiqueta("¿Cómo se llama tu mascota?"),
                        TextFormField(
                          controller: nombreController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: const TextStyle(
                            fontSize: 16,
                            color: _Paleta.tinta,
                          ),
                          decoration: _decoracion(),
                          validator: (valor) {
                            if (valor == null || valor.trim().isEmpty) {
                              return "Escribe el nombre de tu mascota";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 22),

                        // ---------------- TIPO ----------------
                        _etiqueta("Tipo de mascota"),
                        FormField<String>(
                          initialValue: tipoMascota,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (_) =>
                              tipoMascota.isEmpty ? "Elige perro o gato" : null,
                          builder: (state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _tarjetaMascota(
                                        tipo: "Perro",
                                        emoji: "🐶",
                                        onTap: () {
                                          setState(() => tipoMascota = "Perro");
                                          state.didChange("Perro");
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: _tarjetaMascota(
                                        tipo: "Gato",
                                        emoji: "🐱",
                                        onTap: () {
                                          setState(() => tipoMascota = "Gato");
                                          state.didChange("Gato");
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                if (state.hasError)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 8, left: 4),
                                    child: Text(
                                      state.errorText!,
                                      style: const TextStyle(
                                        color: _Paleta.error,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 22),

                        // ---------------- GÉNERO ----------------
                        _etiqueta("Género"),
                        _selectorGenero(),

                        const SizedBox(height: 22),
                        // ---------------- EDAD Y PESO ----------------
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _etiqueta("Edad"),
                                  TextFormField(
                                    controller: edadController,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(2),
                                    ],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: _Paleta.tinta,
                                    ),
                                    decoration: _decoracion(sufijo: "años"),
                                    validator: (valor) {
                                      if (valor == null || valor.isEmpty) {
                                        return "Indica la edad";
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _etiqueta("Peso"),
                                  TextFormField(
                                    controller: pesoController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    textInputAction: TextInputAction.done,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d{0,3}[.,]?\d{0,2}'),
                                      ),
                                    ],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: _Paleta.tinta,
                                    ),
                                    decoration: _decoracion(sufijo: "kg"),
                                    validator: (valor) {
                                      final peso = double.tryParse(
                                        (valor ?? "").replaceAll(",", "."),
                                      );
                                      if (peso == null || peso <= 0) {
                                        return "Indica el peso";
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // ---------------- REGISTRAR ----------------
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: registrarMascota,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _Paleta.primario,
                              foregroundColor: _Paleta.tinta,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              "Registrar mascota",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- SELECTOR DE GÉNERO ----------------

  Widget _selectorGenero() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _Paleta.pista,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _opcionGenero("Macho", Icons.male_rounded),
          _opcionGenero("Hembra", Icons.female_rounded),
        ],
      ),
    );
  }

  Widget _opcionGenero(String valor, IconData icono) {
    final bool seleccionado = genero == valor;

    return Expanded(
      child: Semantics(
        button: true,
        selected: seleccionado,
        label: valor,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => genero = valor),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            height: 44,
            decoration: BoxDecoration(
              color: seleccionado ? _Paleta.primario : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icono,
                  size: 20,
                  color: seleccionado ? _Paleta.tinta : _Paleta.tintaSuave,
                ),
                const SizedBox(width: 6),
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: seleccionado ? FontWeight.w700 : FontWeight.w500,
                    color: seleccionado ? _Paleta.tinta : _Paleta.tintaSuave,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- TARJETA MASCOTA ----------------

  Widget _tarjetaMascota({
    required String tipo,
    required String emoji,
    required VoidCallback onTap,
  }) {
    final bool seleccionado = tipoMascota == tipo;

    return Semantics(
      button: true,
      selected: seleccionado,
      label: tipo,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 118,
          decoration: BoxDecoration(
            color: seleccionado ? const Color(0xFFDDF4F1) : _Paleta.campo,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: seleccionado ? _Paleta.primarioOscuro : _Paleta.borde,
              width: seleccionado ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 46)),
                    const SizedBox(height: 4),
                    Text(
                      tipo,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            seleccionado ? FontWeight.w700 : FontWeight.w500,
                        color: _Paleta.tinta,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: AnimatedScale(
                  scale: seleccionado ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutBack,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: _Paleta.primarioOscuro,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}