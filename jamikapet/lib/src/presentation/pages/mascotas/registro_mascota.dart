import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jamikapet/src/services/pets_service.dart';
import 'package:jamikapet/src/presentation/widgets/app_animaciones.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';

/// Paleta de la pantalla
class _Paleta {
  static const fondo = Color(0xFFE6F6F5);
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
  final TextEditingController razaController = TextEditingController();

  String genero = "Macho";
  String tipoMascota = "";
  bool _guardando = false;

  @override
  void dispose() {
    nombreController.dispose();
    pesoController.dispose();
    edadController.dispose();
    razaController.dispose();
    super.dispose();
  }

  Future<void> registrarMascota() async {
    FocusScope.of(context).unfocus();

    if (_guardando) return;

    if (!(_formKey.currentState?.validate() ?? false)) {
      _mostrarMensaje("Revisa los campos marcados", esError: true);
      return;
    }

    final edad = int.parse(edadController.text.trim());
    final peso = double.parse(
      pesoController.text.trim().replaceAll(',', '.'),
    );

    if (edad < 0 || peso <= 0) {
      _mostrarMensaje("Verifica la edad y el peso", esError: true);
      return;
    } 

    setState(() => _guardando = true);

    try {
      await PetsService.registrarMascota(
        nombre: nombreController.text.trim(),
        especie: tipoMascota,
        raza: razaController.text.trim(),
        sexo: genero,
        edad: edad,
        peso: peso,
      );

      if (!mounted) return;
      _mostrarMensaje("Mascota registrada correctamente 🐾");
      // El formulario queda limpio tras confirmar que el backend guardó la mascota.
      _formKey.currentState?.reset();
      nombreController.clear();
      razaController.clear();
      edadController.clear();
      pesoController.clear();
      setState(() {
        tipoMascota = "";
        genero = "Macho";
      });
    } on PetsServiceException catch (e) {
      if (!mounted) return;
      _mostrarMensaje(e.message, esError: true);
    } catch (_) {
      if (!mounted) return;
      _mostrarMensaje(
        "No se pudo registrar la mascota. Verifica tu conexión e inténtalo de nuevo.",
        esError: true,
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
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

  // Estilos
  InputDecoration _decoracion({
    String? sufijo,
    Widget? suffixIcon,
    IconData? icono,
    String? pista,
  }) {
    OutlineInputBorder borde(Color color, [double ancho = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: ancho),
      );
    }

    return InputDecoration(
      filled: true,
      fillColor: _Paleta.campo,
      hintText: pista,
      hintStyle: TextStyle(
        color: _Paleta.tintaSuave.withValues(alpha: 0.55),
        fontSize: 15,
      ),
      prefixIcon: icono == null
          ? null
          : Icon(icono, color: _Paleta.primarioOscuro, size: 21),
      suffixText: sufijo,
      suffixStyle: const TextStyle(color: _Paleta.tintaSuave, fontSize: 15),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      padding: const EdgeInsets.only(bottom: 9, left: 2),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: _Paleta.tinta,
        ),
      ),
    );
  }

  // Build

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: _Paleta.fondo,
        // Barra superior
        appBar: const HeaderAppBar(
          titulo: 'Registro Pet',
          mostrarRegreso: true,
          mostrarLogo: true,
          mostrarNotificaciones: true,
        ),
        // Contenido
        body: Column(
          children: [
            // Contenido de la pantalla
            Expanded(
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EntradaAnimada(child: _encabezado()),

                      const SizedBox(height: 20),

                      // Tarjeta del formulario
                      EntradaAnimada(
                        indice: 1,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x140F3D3A),
                                blurRadius: 26,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nombre
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
                                  decoration: _decoracion(
                                    icono: Icons.badge_outlined,
                                    pista: "Ej. Firulais",
                                  ),
                                  validator: (valor) {
                                    if (valor == null || valor.trim().isEmpty) {
                                      return "Escribe el nombre de tu mascota";
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 24),

                                // Tipo
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
                                                gif: "assets/img/perro.gif",
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
                                                gif: "assets/img/gato.gif",
                                                onTap: () {
                                                  setState(() => tipoMascota = "Gato");
                                                  state.didChange("Gato");
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        AnimatedSize(
                                          duration: const Duration(milliseconds: 180),
                                          child: state.hasError
                                              ? Padding(
                                                  padding: const EdgeInsets.only(
                                                    top: 8,
                                                    left: 4,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.error_outline_rounded,
                                                        size: 15,
                                                        color: _Paleta.error,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        state.errorText!,
                                                        style: const TextStyle(
                                                          color: _Paleta.error,
                                                          fontSize: 12.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : const SizedBox(width: double.infinity),
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                const SizedBox(height: 24),

                                // Raza
                                _etiqueta("Raza de tu mascota"),
                                TextFormField(
                                  controller: razaController,
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: _Paleta.tinta,
                                  ),
                                  decoration: _decoracion(
                                    icono: Icons.pets_outlined,
                                    pista: "Ej. Labrador, Mestizo",
                                  ),
                                  validator: (valor) {
                                    if (valor == null || valor.trim().isEmpty) {
                                      return "Escribe la raza de tu mascota";
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 24),

                                // Género
                                _etiqueta("Género"),
                                _selectorGenero(),

                                const SizedBox(height: 24),

                                // Edad y peso
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
                                            decoration: _decoracion(
                                              sufijo: "años",
                                              icono: Icons.cake_outlined,
                                            ),
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
                                            decoration: _decoracion(
                                              sufijo: "kg",
                                              icono: Icons.monitor_weight_outlined,
                                            ),
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

                                const SizedBox(height: 30),

                                // Registrar
                                PresionAnimada(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: double.infinity,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: _guardando
                                          ? []
                                          : [
                                              BoxShadow(
                                                color: _Paleta.primario
                                                    .withValues(alpha: 0.45),
                                                blurRadius: 18,
                                                offset: const Offset(0, 8),
                                              ),
                                            ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _guardando ? null : registrarMascota,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _Paleta.primario,
                                        foregroundColor: _Paleta.tinta,
                                        disabledBackgroundColor:
                                            _Paleta.primario.withValues(alpha: 0.6),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                      ),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 200),
                                        child: _guardando
                                            ? const SizedBox(
                                                key: ValueKey('cargando'),
                                                width: 22,
                                                height: 22,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    _Paleta.tinta,
                                                  ),
                                                ),
                                              )
                                            : const Row(
                                                key: ValueKey('texto'),
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.add_circle_outline_rounded),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    "Registrar mascota",
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ),
          ]
        ),
      )
    );
  }

  // Tarjeta de bienvenida
  Widget _encabezado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [_Paleta.primarioOscuro, _Paleta.primario],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _Paleta.primarioOscuro.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -4,
            top: -12,
            child: Icon(
              Icons.pets_rounded,
              size: 92,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.4, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.elasticOut,
                builder: (_, escala, child) =>
                    Transform.scale(scale: escala, child: child),
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🐾', style: TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nueva mascota',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cuéntanos un poco sobre tu compañero.',
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.35,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Selector de género

  Widget _selectorGenero() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: _Paleta.pista,
        borderRadius: BorderRadius.circular(18),
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
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: 48,
            decoration: BoxDecoration(
              color: seleccionado ? _Paleta.primario : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              boxShadow: seleccionado
                  ? [
                      BoxShadow(
                        color: _Paleta.primario.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: seleccionado ? 1.15 : 1,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    icono,
                    size: 20,
                    color: seleccionado ? _Paleta.tinta : _Paleta.tintaSuave,
                  ),
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

  // Tarjeta de tipo de mascota

  Widget _tarjetaMascota({
    required String tipo,
    required String gif,
    required VoidCallback onTap,
  }) {
    final bool seleccionado = tipoMascota == tipo;

    return Semantics(
      button: true,
      selected: seleccionado,
      label: tipo,
      child: PresionAnimada(
        escala: 0.95,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: 140,
            decoration: BoxDecoration(
              color: seleccionado ? null : _Paleta.campo,
              gradient: seleccionado
                  ? const LinearGradient(
                      colors: [Color(0xFFDDF4F1), _Paleta.pista],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: seleccionado ? _Paleta.primarioOscuro : _Paleta.borde,
                width: seleccionado ? 2 : 1,
              ),
              boxShadow: seleccionado
                  ? [
                      BoxShadow(
                        color: _Paleta.primarioOscuro.withValues(alpha: 0.16),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        scale: seleccionado ? 1.12 : 1,
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutBack,
                        child: Image.asset(
                          gif,
                          width: 78,
                          height: 78,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tipo,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight:
                              seleccionado ? FontWeight.w800 : FontWeight.w500,
                          color: seleccionado
                              ? _Paleta.primarioOscuro
                              : _Paleta.tinta,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: AnimatedScale(
                    scale: seleccionado ? 1 : 0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: _Paleta.primarioOscuro,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      ),
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
}
