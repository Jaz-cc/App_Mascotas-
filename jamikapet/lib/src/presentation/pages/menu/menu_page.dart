import 'package:flutter/material.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_animaciones.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  static const _borde = Color(0xFFB2DFDB);
  static const _iconoFondo = Color(0xFFE0F2F1);
  static const _flecha = Color(0xFF80CBC4);

  @override
  Widget build(BuildContext context) {
    const primaryBackground = Color(0xFFE2F4F1);
    const darkText = Colors.black87;

    return Scaffold(
      backgroundColor: primaryBackground,
      appBar: const HeaderAppBar(
        titulo: 'Menu',
        mostrarLogo: true,
        mostrarRegreso: false,
        icon: Icons.menu,
      ),
      body: Column(
        children: [
          // Contenido de la pantalla
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EntradaAnimada(child: _encabezado()),

                    const SizedBox(height: 26),

                    const EntradaAnimada(
                      indice: 1,
                      child: Row(
                        children: [
                          Icon(Icons.pets, size: 22, color: darkText),
                          SizedBox(width: 8),
                          Text(
                            'Salud',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: darkText,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Cuadrícula de opciones de salud
                    Row(
                      children: [
                        //VACUNAS
                        Expanded(
                          child: EntradaAnimada(
                            indice: 2,
                            child: _buildMenuOption(
                              icon: Icons.clean_hands_outlined,
                              title: 'Vacunas',
                              subtitle: 'Esquema y refuerzos',
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.vacunas);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        //DESPARASITACIÓN
                        Expanded(
                          child: EntradaAnimada(
                            indice: 3,
                            child: _buildMenuOption(
                              icon: Icons.bug_report_outlined,
                              title: 'Desparasitación',
                              subtitle: 'Control interno y externo',
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.desparacitacion);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        //MEDICAMENTOS
                        Expanded(
                          child: EntradaAnimada(
                            indice: 4,
                            child: _buildMenuOption(
                              icon: Icons.medication_outlined,
                              title: 'Medicamentos',
                              subtitle: 'Dosis y horarios',
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.medicamentos);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        //CITAS VETERINARIAS
                        Expanded(
                          child: EntradaAnimada(
                            indice: 5,
                            child: _buildMenuOption(
                              icon: Icons.event_available_outlined,
                              title: 'Citas Veterinarias',
                              subtitle: 'Agenda tus visitas',
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.citas);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    //CHAT IA
                    EntradaAnimada(
                      indice: 6,
                      child: _buildOpcionIA(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.chatIA);
                        },
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),

          // Pie de página / barra inferior
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

  // Tarjeta de bienvenida con el escudo animado
  Widget _encabezado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10,
            bottom: -18,
            child: Icon(
              Icons.pets,
              size: 110,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.elasticOut,
                builder: (_, escala, child) =>
                    Transform.scale(scale: escala, child: child),
                child: Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 56,
                        color: Colors.teal.shade400,
                      ),
                      const Icon(
                        Icons.pets,
                        size: 24,
                        color: Colors.teal,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cuidado integral',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Todo lo de la salud de tu mascota en un solo lugar.',
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

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return PresionAnimada(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: Colors.teal.withValues(alpha: 0.08),
          highlightColor: Colors.teal.withValues(alpha: 0.04),
          child: Ink(
            height: 150,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _borde.withValues(alpha: 0.7)),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _iconoFondo,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.teal.shade700,
                        size: 26,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_outward_rounded,
                      color: _flecha,
                      size: 22,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Opción destacada del asistente con IA
  Widget _buildOpcionIA({required VoidCallback onTap}) {
    return PresionAnimada(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: Colors.white.withValues(alpha: 0.15),
          child: Ink(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Colors.teal.shade400],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withValues(alpha: 0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const _IconoLatido(
                  child: Icon(
                    Icons.smart_toy_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Asistente IA',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Resuelve tus dudas sobre su cuidado',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 26,
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

// Contenedor del ícono de IA con un pulso suave y continuo
class _IconoLatido extends StatefulWidget {
  const _IconoLatido({required this.child});

  final Widget child;

  @override
  State<_IconoLatido> createState() => _IconoLatidoState();
}

class _IconoLatidoState extends State<_IconoLatido>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.12 + 0.18 * t),
                blurRadius: 6 + 10 * t,
                spreadRadius: 1 * t,
              ),
            ],
          ),
          child: Transform.scale(scale: 1 + 0.06 * t, child: child),
        );
      },
    );
  }
}
