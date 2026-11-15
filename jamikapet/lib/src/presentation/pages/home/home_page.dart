import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jamikapet/src/core/storage/token_storage.dart';
import 'package:jamikapet/src/models/usuario.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';
import 'package:jamikapet/src/presentation/widgets/app_logo.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _nombreUsuario = '';
  bool _esPerrito = true;
  int _indiceConsejo = 0;
  late final PageController _consejosController;

  static const List<({String titulo, String texto, IconData icono})> _consejos = [
    (
      titulo: 'Hidratación constante',
      texto:
          'Asegúrate de que tu mascota siempre tenga agua fresca y limpia disponible durante todo el día.',
      icono: Icons.water_drop_outlined,
    ),
    (
      titulo: 'Tiempo de juego y vínculo',
      texto:
          'Dedicar 15 minutos diarios al juego fortalece su confianza, reduce el estrés y mejora su ánimo.',
      icono: Icons.favorite_border_rounded,
    ),
    (
      titulo: 'Revisiones preventivas',
      texto:
          'Un chequeo periódico y mantener su esquema al día son la mejor forma de cuidar su salud a largo plazo.',
      icono: Icons.health_and_safety_outlined,
    ),
    (
      titulo: 'Rutina de descanso',
      texto:
          'Un espacio tranquilo, limpio y cómodo ayuda a que tu compañero recupere energía y duerma mejor.',
      icono: Icons.bedtime_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _consejosController = PageController();
    _cargarNombreUsuario();
  }

  @override
  void dispose() {
    _consejosController.dispose();
    super.dispose();
  }

  Future<void> _cargarNombreUsuario() async {
    try {
      final datos = await TokenStorage.getUser();
      if (datos != null && mounted) {
        final usuario = Usuario.fromJson(datos);
        setState(() {
          _nombreUsuario = usuario.nombre.trim();
        });
      }
    } catch (_) {
      // Mantiene saludo general si no hay datos locales
    }
  }

  String _saludoSegunHora() {
    final hora = DateTime.now().hour;
    final prefijo = hora < 12
        ? '¡Buenos días'
        : hora < 19
            ? '¡Buenas tardes'
            : '¡Buenas noches';

    return _nombreUsuario.isNotEmpty
        ? '$prefijo, $_nombreUsuario!'
        : '$prefijo!';
  }

  void _avanzarConsejo() {
    final siguiente = (_indiceConsejo + 1) % _consejos.length;
    _consejosController.animateToPage(
      siguiente,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Paleta.fondo,
      appBar: const HeaderAppBar(
        titulo: 'Inicio',
        mostrarLogo: true,
        mostrarRegreso: false,
        icon: Icons.home_outlined,
      ),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  children: [
                    _tarjetaBienvenida(),
                    const SizedBox(height: 18),

                    // ESCENARIO INTERACTIVO DE MASCOTA ANIMADA
                    _EscenarioMascotaAnimada(
                      esPerrito: _esPerrito,
                      onCambiarMascota: (valor) {
                        HapticFeedback.selectionClick();
                        setState(() => _esPerrito = valor);
                      },
                    ),

                    const SizedBox(height: 18),

                    // CARRUSEL DE TIPS DE BIENESTAR
                    _tarjetaConsejosCarrusel(),
                  ],
                ),
              ),
            ),
          ),
          AppBottomNavigation(
            currentIndex: 0,
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

  // ---------------- TARJETA DE BIENVENIDA ----------------
  Widget _tarjetaBienvenida() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F7A70), Color(0xFF3AA69B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F7A70).withValues(alpha: 0.24),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: AppLogo(
                width: 64,
                height: 64,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'JAMIKA PET',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _saludoSegunHora(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Todo lo que necesitas para cuidar y mantener el bienestar de tu mascota.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- CARRUSEL DE CONSEJOS DE BIENESTAR ----------------
  Widget _tarjetaConsejosCarrusel() {
    final consejoActual = _consejos[_indiceConsejo];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _Paleta.bordeSuave),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Container(
                  key: ValueKey(_indiceConsejo),
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: _Paleta.verdeMuyClaro,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    consejoActual.icono,
                    size: 20,
                    color: _Paleta.primarioOscuro,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TIP DE BIENESTAR · DESLIZA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: _Paleta.primarioOscuro,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        consejoActual.titulo,
                        key: ValueKey('titulo_$_indiceConsejo'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _Paleta.tinta,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _avanzarConsejo,
                tooltip: 'Siguiente consejo',
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: _Paleta.primarioOscuro,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 76,
            child: PageView.builder(
              controller: _consejosController,
              itemCount: _consejos.length,
              onPageChanged: (index) {
                setState(() => _indiceConsejo = index);
              },
              itemBuilder: (context, index) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: _Paleta.cajaInterna,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      _consejos[index].texto,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.38,
                        color: _Paleta.tintaSuave,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_consejos.length, (index) {
              final activo = index == _indiceConsejo;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: activo ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: activo
                      ? _Paleta.primarioOscuro
                      : _Paleta.primarioOscuro.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

enum _TipoInteraccion { ninguna, acariciar, premio, jugar }

// ============================================================================
// WIDGET DE MASCOTA ANIMADA INTERACTIVA (PERRITO / GATITO)
// ============================================================================
class _EscenarioMascotaAnimada extends StatefulWidget {
  const _EscenarioMascotaAnimada({
    required this.esPerrito,
    required this.onCambiarMascota,
  });

  final bool esPerrito;
  final ValueChanged<bool> onCambiarMascota;

  @override
  State<_EscenarioMascotaAnimada> createState() =>
      _EscenarioMascotaAnimadaState();
}

class _EscenarioMascotaAnimadaState extends State<_EscenarioMascotaAnimada>
    with TickerProviderStateMixin {
  late final AnimationController _cicloController;
  late final AnimationController _accionController;

  _TipoInteraccion _accionActual = _TipoInteraccion.ninguna;
  Offset _miradaNormalizada = Offset.zero;
  double _nivelAlegria = 0.75;

  @override
  void initState() {
    super.initState();
    _cicloController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    _accionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() {
            _accionActual = _TipoInteraccion.ninguna;
            _miradaNormalizada = Offset.zero;
          });
          _accionController.reset();
        }
      });
  }

  @override
  void dispose() {
    _cicloController.dispose();
    _accionController.dispose();
    super.dispose();
  }

  void _ejecutarInteraccion(_TipoInteraccion tipo) {
    HapticFeedback.lightImpact();
    setState(() {
      _accionActual = tipo;
      _nivelAlegria = (_nivelAlegria + 0.08).clamp(0.0, 1.0);
    });
    _accionController.forward(from: 0);
  }

  void _actualizarMirada(Offset posicionLocal, Size size) {
    final dx = ((posicionLocal.dx / size.width) - 0.5) * 2;
    final dy = ((posicionLocal.dy / size.height) - 0.5) * 2;
    setState(() {
      _miradaNormalizada = Offset(
        dx.clamp(-1.0, 1.0),
        dy.clamp(-1.0, 1.0),
      );
    });
  }

  String _mensajeBurbuja() {
    switch (_accionActual) {
      case _TipoInteraccion.acariciar:
        return widget.esPerrito
            ? '¡Guau! Me encantan tus caricias'
            : '¡Prrr! Qué cálido abrazo';
      case _TipoInteraccion.premio:
        return widget.esPerrito
            ? '¡Qué rico huesito! Gracias'
            : '¡Miau! Delicioso bocadillo';
      case _TipoInteraccion.jugar:
        return widget.esPerrito
            ? '¡Atrapemos la pelota!'
            : '¡Persiguiendo el ovillo!';
      case _TipoInteraccion.ninguna:
        return widget.esPerrito
            ? 'Tócame o elige una actividad'
            : 'Desliza tu dedo o juega conmigo';
    }
  }

  @override
  Widget build(BuildContext context) {
    final porcentaje = (_nivelAlegria * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _Paleta.bordeSuave),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // FILA SUPERIOR: SELECTOR PERRITO/GATITO + NIVEL DE ALEGRÍA
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _Paleta.cajaInterna,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _Paleta.bordeSuave),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _botonSelector(
                      etiqueta: 'Perrito',
                      icono: Icons.pets_rounded,
                      activo: widget.esPerrito,
                      onTap: () => widget.onCambiarMascota(true),
                    ),
                    const SizedBox(width: 2),
                    _botonSelector(
                      etiqueta: 'Gatito',
                      icono: Icons.cruelty_free_rounded,
                      activo: !widget.esPerrito,
                      onTap: () => widget.onCambiarMascota(false),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _Paleta.verdeMuyClaro,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      size: 15,
                      color: Color(0xFFE11D48),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$porcentaje%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _Paleta.primarioOscuro,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // LIENZO INTERACTIVO CON SEGUIMIENTO DE MIRADA Y ANIMACIONES
          LayoutBuilder(
            builder: (context, constraints) {
              const altoLienzo = 235.0;
              final sizeLienzo = Size(constraints.maxWidth, altoLienzo);

              return GestureDetector(
                onTapDown: (details) {
                  _actualizarMirada(details.localPosition, sizeLienzo);
                  _ejecutarInteraccion(_TipoInteraccion.acariciar);
                },
                onPanUpdate: (details) {
                  _actualizarMirada(details.localPosition, sizeLienzo);
                },
                onPanEnd: (_) {
                  setState(() => _miradaNormalizada = Offset.zero);
                },
                child: Container(
                  width: double.infinity,
                  height: altoLienzo,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF3FAF8), Color(0xFFD5F0EB)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: Listenable.merge(
                            [_cicloController, _accionController],
                          ),
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _MascotaPainter(
                                progreso: _cicloController.value,
                                progresoAccion: _accionController.value,
                                accion: _accionActual,
                                mirada: _miradaNormalizada,
                                esPerrito: widget.esPerrito,
                              ),
                            );
                          },
                        ),
                      ),

                      // BURBUJA DE REACCIÓN DINÁMICA
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: Container(
                              key: ValueKey('${_accionActual}_${widget.esPerrito}'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _Paleta.bordeSuave),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                _mensajeBurbuja(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _Paleta.primarioOscuro,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          // BOTONES DE INTERACCIÓN RÁPIDA
          Row(
            children: [
              Expanded(
                child: _botonInteraccion(
                  icono: Icons.favorite_rounded,
                  etiqueta: 'Acariciar',
                  activo: _accionActual == _TipoInteraccion.acariciar,
                  onTap: () => _ejecutarInteraccion(_TipoInteraccion.acariciar),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _botonInteraccion(
                  icono: Icons.cookie_outlined,
                  etiqueta: 'Premio',
                  activo: _accionActual == _TipoInteraccion.premio,
                  onTap: () => _ejecutarInteraccion(_TipoInteraccion.premio),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _botonInteraccion(
                  icono: Icons.sports_baseball_outlined,
                  etiqueta: 'Jugar',
                  activo: _accionActual == _TipoInteraccion.jugar,
                  onTap: () => _ejecutarInteraccion(_TipoInteraccion.jugar),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _botonSelector({
    required String etiqueta,
    required IconData icono,
    required bool activo,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: activo ? _Paleta.primarioOscuro : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              icono,
              size: 15,
              color: activo ? Colors.white : _Paleta.tintaSuave,
            ),
            const SizedBox(width: 5),
            Text(
              etiqueta,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: activo ? Colors.white : _Paleta.tintaSuave,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botonInteraccion({
    required IconData icono,
    required String etiqueta,
    required bool activo,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: activo ? _Paleta.primarioOscuro : _Paleta.cajaInterna,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: activo ? _Paleta.primarioOscuro : _Paleta.bordeSuave,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 17,
              color: activo ? Colors.white : _Paleta.primarioOscuro,
            ),
            const SizedBox(width: 6),
            Text(
              etiqueta,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: activo ? Colors.white : _Paleta.tinta,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// PINTOR VECTORIAL ANIMADO (PERRITO Y GATITO CON ACCIONES)
// ============================================================================
class _MascotaPainter extends CustomPainter {
  _MascotaPainter({
    required this.progreso,
    required this.progresoAccion,
    required this.accion,
    required this.mirada,
    required this.esPerrito,
  });

  final double progreso;
  final double progresoAccion;
  final _TipoInteraccion accion;
  final Offset mirada;
  final bool esPerrito;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 22;

    final onda = math.sin(progreso * 2 * math.pi);

    // Salto según la acción activa
    double saltoY = 0.0;
    if (accion == _TipoInteraccion.acariciar) {
      saltoY = -math.sin(progresoAccion * math.pi) * 12;
    } else if (accion == _TipoInteraccion.jugar) {
      saltoY = -math.sin(progresoAccion * 2 * math.pi).abs() * 14;
    } else if (accion == _TipoInteraccion.premio && progresoAccion > 0.55) {
      saltoY = -math.sin((progresoAccion - 0.55) / 0.45 * math.pi) * 10;
    }

    final offsetY = onda * 3.5 + saltoY;

    // Cola y orejas dinámicas
    final velocidadCola = accion != _TipoInteraccion.ninguna ? 8 : 2;
    final anguloCola = math.sin(progreso * velocidadCola * math.pi) * 0.38;
    final anguloOreja = onda * 0.08 +
        (accion != _TipoInteraccion.ninguna
            ? math.sin(progresoAccion * 4 * math.pi) * 0.14
            : 0);

    // Parpadeo natural o expresión feliz
    final parpadeo = (progreso > 0.88 && progreso < 0.94);
    final ojosFelices = parpadeo ||
        accion == _TipoInteraccion.acariciar ||
        (accion == _TipoInteraccion.premio && progresoAccion > 0.55);

    // Si está jugando, los ojos siguen la pelota
    Offset miradaEfectiva = mirada;
    if (accion == _TipoInteraccion.jugar) {
      final ballX = math.cos(progresoAccion * 2 * math.pi);
      final ballY = -math.sin(progresoAccion * 2 * math.pi).abs() * 0.6;
      miradaEfectiva = Offset(ballX, ballY);
    }

    // Sombra en el piso
    final sombraPaint = Paint()
      ..color = const Color(0xFF1F7A70).withValues(alpha: 0.15);
    final anchoSombra = 56 - (offsetY * 0.65);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, size.height - 18),
        width: anchoSombra * 2,
        height: 13,
      ),
      sombraPaint,
    );

    // Mascota principal
    canvas.save();
    canvas.translate(cx, cy + offsetY);
    canvas.rotate(miradaEfectiva.dx * 0.06);

    if (esPerrito) {
      _dibujarPerrito(
        canvas,
        anguloCola,
        anguloOreja,
        ojosFelices,
        miradaEfectiva,
      );
    } else {
      _dibujarGatito(
        canvas,
        anguloCola,
        anguloOreja,
        ojosFelices,
        miradaEfectiva,
      );
    }

    canvas.restore();

    // Efectos visuales de cada acción
    if (accion == _TipoInteraccion.acariciar) {
      _dibujarCorazones(canvas, cx, cy - 52, progresoAccion);
    } else if (accion == _TipoInteraccion.premio) {
      _dibujarPremio(canvas, cx, cy - 10, progresoAccion, esPerrito);
    } else if (accion == _TipoInteraccion.jugar) {
      _dibujarJuguete(canvas, cx, cy + 36, progresoAccion, esPerrito);
    }
  }

  void _dibujarPerrito(
    Canvas canvas,
    double anguloCola,
    double anguloOreja,
    bool ojosFelices,
    Offset mirada,
  ) {
    final pelajeBase = Paint()..color = const Color(0xFFE6A15C);
    final pelajeClaro = Paint()..color = const Color(0xFFFFF3E0);
    final orejaPaint = Paint()..color = const Color(0xFF9E5A2B);
    final collarPaint = Paint()..color = const Color(0xFF1F7A70);
    final medallaPaint = Paint()..color = const Color(0xFFFFD54F);
    final narizPaint = Paint()..color = const Color(0xFF2D241E);

    // Cola
    canvas.save();
    canvas.translate(32, 34);
    canvas.rotate(anguloCola + 0.4);
    final colaPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(24, -18, 28, -34)
      ..quadraticBezierTo(16, -26, 2, -6)
      ..close();
    canvas.drawPath(colaPath, orejaPaint);
    canvas.restore();

    // Cuerpo y pecho
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-32, 6, 64, 52),
        const Radius.circular(28),
      ),
      pelajeBase,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 28), width: 34, height: 36),
      pelajeClaro,
    );

    // Patitas
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-24, 42, 16, 20),
        const Radius.circular(8),
      ),
      pelajeClaro,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8, 42, 16, 20),
        const Radius.circular(8),
      ),
      pelajeClaro,
    );

    // Collar JamikaPet
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-26, 2, 52, 9),
        const Radius.circular(5),
      ),
      collarPaint,
    );
    canvas.drawCircle(const Offset(0, 12), 5.5, medallaPaint);

    // Orejas animadas
    canvas.save();
    canvas.translate(-34, -34);
    canvas.rotate(-anguloOreja);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-14, 0, 20, 44),
        const Radius.circular(12),
      ),
      orejaPaint,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(34, -34);
    canvas.rotate(anguloOreja);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-6, 0, 20, 44),
        const Radius.circular(12),
      ),
      orejaPaint,
    );
    canvas.restore();

    // Cabeza
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-40, -56, 80, 64),
        const Radius.circular(32),
      ),
      pelajeBase,
    );

    // Hocico
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, -13), width: 42, height: 28),
      pelajeClaro,
    );

    // Ojos con seguimiento de mirada
    _dibujarOjos(canvas, -16, -30, 16, -30, ojosFelices, mirada);

    // Nariz y boca
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-7, -21, 14, 9),
        const Radius.circular(5),
      ),
      narizPaint,
    );

    final bocaPaint = Paint()
      ..color = const Color(0xFF4E342E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final sonrisa = Path()
      ..moveTo(-9, -8)
      ..quadraticBezierTo(-4, -3, 0, -9)
      ..quadraticBezierTo(4, -3, 9, -8);
    canvas.drawPath(sonrisa, bocaPaint);

    if (accion != _TipoInteraccion.ninguna) {
      final lenguaPaint = Paint()..color = const Color(0xFFFF758F);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-4, -6, 8, 9),
          const Radius.circular(4),
        ),
        lenguaPaint,
      );
    }
  }

  void _dibujarGatito(
    Canvas canvas,
    double anguloCola,
    double anguloOreja,
    bool ojosFelices,
    Offset mirada,
  ) {
    final pelajeGato = Paint()..color = const Color(0xFF64748B);
    final pelajeBlanco = Paint()..color = const Color(0xFFF8FAFC);
    final orejaInterior = Paint()..color = const Color(0xFFFDA4AF);
    final collarPaint = Paint()..color = const Color(0xFF3AA69B);
    final narizPaint = Paint()..color = const Color(0xFFFB7185);

    // Cola
    canvas.save();
    canvas.translate(28, 42);
    canvas.rotate(anguloCola * 0.7);
    final colaPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final colaPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(28, -8, 26, -34)
      ..quadraticBezierTo(24, -46, 14, -46);
    canvas.drawPath(colaPath, colaPaint);
    canvas.restore();

    // Cuerpo
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-28, 8, 56, 50),
        const Radius.circular(26),
      ),
      pelajeGato,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 30), width: 30, height: 34),
      pelajeBlanco,
    );

    // Patitas
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-21, 44, 14, 18),
        const Radius.circular(7),
      ),
      pelajeBlanco,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(7, 44, 14, 18),
        const Radius.circular(7),
      ),
      pelajeBlanco,
    );

    // Collar y cascabel
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-24, 3, 48, 8),
        const Radius.circular(4),
      ),
      collarPaint,
    );
    canvas.drawCircle(
      const Offset(0, 12),
      5,
      Paint()..color = const Color(0xFFFFD54F),
    );

    // Orejas puntiagudas
    canvas.save();
    canvas.translate(-24, -46);
    canvas.rotate(-anguloOreja);
    final orejaIzq = Path()
      ..moveTo(-12, 10)
      ..lineTo(-8, -22)
      ..lineTo(12, 4)
      ..close();
    canvas.drawPath(orejaIzq, pelajeGato);
    final orejaIzqIn = Path()
      ..moveTo(-7, 6)
      ..lineTo(-6, -13)
      ..lineTo(6, 3)
      ..close();
    canvas.drawPath(orejaIzqIn, orejaInterior);
    canvas.restore();

    canvas.save();
    canvas.translate(24, -46);
    canvas.rotate(anguloOreja);
    final orejaDer = Path()
      ..moveTo(-12, 4)
      ..lineTo(8, -22)
      ..lineTo(12, 10)
      ..close();
    canvas.drawPath(orejaDer, pelajeGato);
    final orejaDerIn = Path()
      ..moveTo(-6, 3)
      ..lineTo(6, -13)
      ..lineTo(7, 6)
      ..close();
    canvas.drawPath(orejaDerIn, orejaInterior);
    canvas.restore();

    // Cabeza
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-38, -54, 76, 60),
        const Radius.circular(30),
      ),
      pelajeGato,
    );

    // Ojos
    _dibujarOjos(canvas, -15, -28, 15, -28, ojosFelices, mirada);

    // Nariz y boquita
    final narizPath = Path()
      ..moveTo(-5, -18)
      ..lineTo(5, -18)
      ..lineTo(0, -12)
      ..close();
    canvas.drawPath(narizPath, narizPaint);

    final lineaPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final boca = Path()
      ..moveTo(-8, -8)
      ..quadraticBezierTo(-4, -4, 0, -10)
      ..quadraticBezierTo(4, -4, 8, -8);
    canvas.drawPath(boca, lineaPaint);

    // Bigotes
    final bigotePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(-24, -17), const Offset(-44, -20), bigotePaint);
    canvas.drawLine(const Offset(-24, -12), const Offset(-44, -11), bigotePaint);
    canvas.drawLine(const Offset(24, -17), const Offset(44, -20), bigotePaint);
    canvas.drawLine(const Offset(24, -12), const Offset(44, -11), bigotePaint);
  }

  void _dibujarOjos(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    bool cerradosFelices,
    Offset mirada,
  ) {
    if (cerradosFelices) {
      final arcoPaint = Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCenter(center: Offset(x1, y1 + 2), width: 12, height: 10),
        math.pi,
        math.pi,
        false,
        arcoPaint,
      );
      canvas.drawArc(
        Rect.fromCenter(center: Offset(x2, y2 + 2), width: 12, height: 10),
        math.pi,
        math.pi,
        false,
        arcoPaint,
      );
    } else {
      final ojoPaint = Paint()..color = const Color(0xFF1E293B);
      final brilloPaint = Paint()..color = Colors.white;

      final dx = mirada.dx * 2.2;
      final dy = mirada.dy * 1.8;

      canvas.drawCircle(Offset(x1 + dx, y1 + dy), 5.5, ojoPaint);
      canvas.drawCircle(Offset(x1 + dx - 1.8, y1 + dy - 1.8), 2, brilloPaint);

      canvas.drawCircle(Offset(x2 + dx, y2 + dy), 5.5, ojoPaint);
      canvas.drawCircle(Offset(x2 + dx - 1.8, y2 + dy - 1.8), 2, brilloPaint);
    }
  }

  void _dibujarCorazones(
    Canvas canvas,
    double cx,
    double baseY,
    double t,
  ) {
    final opacidad = (1.0 - t).clamp(0.0, 1.0);
    final corazonPaint = Paint()
      ..color = const Color(0xFFE11D48).withValues(alpha: opacidad);

    final posiciones = [
      Offset(cx - 34, baseY - (t * 36)),
      Offset(cx + 30, baseY - 10 - (t * 42)),
      Offset(cx, baseY - 22 - (t * 48)),
    ];

    for (var i = 0; i < posiciones.length; i++) {
      final p = posiciones[i];
      final escala = i == 2 ? 1.0 : 0.78;
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.scale(escala);

      final path = Path()
        ..moveTo(0, 4)
        ..cubicTo(-8, -4, -14, 4, 0, 14)
        ..cubicTo(14, 4, 8, -4, 0, 4);
      canvas.drawPath(path, corazonPaint);
      canvas.restore();
    }
  }

  void _dibujarPremio(
    Canvas canvas,
    double cx,
    double bocaY,
    double t,
    bool esPerrito,
  ) {
    if (t < 0.55) {
      // Premio volando hacia la boca
      final progresoVuelo = t / 0.55;
      final x = cx + 75 * (1 - progresoVuelo);
      final y = bocaY - 35 * math.sin(progresoVuelo * math.pi);
      final escala = 1.0 - (progresoVuelo * 0.35);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progresoVuelo * 2 * math.pi);
      canvas.scale(escala);

      if (esPerrito) {
        // Huesito
        final huesoPaint = Paint()..color = const Color(0xFFFFF8E7);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-12, -4, 24, 8),
            const Radius.circular(4),
          ),
          huesoPaint,
        );
        canvas.drawCircle(const Offset(-12, -4), 4.5, huesoPaint);
        canvas.drawCircle(const Offset(-12, 4), 4.5, huesoPaint);
        canvas.drawCircle(const Offset(12, -4), 4.5, huesoPaint);
        canvas.drawCircle(const Offset(12, 4), 4.5, huesoPaint);
      } else {
        // Pececito
        final pezPaint = Paint()..color = const Color(0xFF38BDF8);
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 22, height: 12),
          pezPaint,
        );
        final colaPez = Path()
          ..moveTo(10, 0)
          ..lineTo(18, -6)
          ..lineTo(18, 6)
          ..close();
        canvas.drawPath(colaPez, pezPaint);
      }
      canvas.restore();
    } else {
      // Destellos de alegría al comerlo
      final tDestello = (t - 0.55) / 0.45;
      final opacidad = (1.0 - tDestello).clamp(0.0, 1.0);
      final estrellaPaint = Paint()
        ..color = const Color(0xFFF59E0B).withValues(alpha: opacidad);

      for (var i = 0; i < 4; i++) {
        final angulo = (i * math.pi / 2) + (math.pi / 4);
        final radio = 28 + (tDestello * 26);
        final px = cx + math.cos(angulo) * radio;
        final py = (bocaY - 22) + math.sin(angulo) * radio;
        canvas.drawCircle(Offset(px, py), 4 * (1 - tDestello * 0.4), estrellaPaint);
      }
    }
  }

  void _dibujarJuguete(
    Canvas canvas,
    double cx,
    double sueloY,
    double t,
    bool esPerrito,
  ) {
    final x = cx + math.sin(t * 2 * math.pi) * 78;
    final rebote = math.sin(t * 4 * math.pi).abs();
    final y = sueloY - (rebote * 42);

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(t * 4 * math.pi);

    if (esPerrito) {
      // Pelota bicolor JamikaPet
      canvas.drawCircle(
        Offset.zero,
        12,
        Paint()..color = const Color(0xFFFF7043),
      );
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: 12),
        0,
        math.pi,
        true,
        Paint()..color = const Color(0xFF1F7A70),
      );
    } else {
      // Ovillo de lana
      canvas.drawCircle(
        Offset.zero,
        12,
        Paint()..color = const Color(0xFFEC4899),
      );
      final hiloPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: 8),
        0.2,
        2.4,
        false,
        hiloPaint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: 5),
        1.2,
        2.6,
        false,
        hiloPaint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MascotaPainter oldDelegate) {
    return oldDelegate.progreso != progreso ||
        oldDelegate.progresoAccion != progresoAccion ||
        oldDelegate.accion != accion ||
        oldDelegate.mirada != mirada ||
        oldDelegate.esPerrito != esPerrito;
  }
}

class _Paleta {
  static const Color fondo = Color(0xFFE2F4F1);
  static const Color primarioOscuro = Color(0xFF1F7A70);
  static const Color verdeMuyClaro = Color(0xFFD5F0EB);
  static const Color cajaInterna = Color(0xFFF3FAF8);
  static const Color bordeSuave = Color(0xFFD0EBE7);
  static const Color tinta = Color(0xFF1E293B);
  static const Color tintaSuave = Color(0xFF64748B);
}