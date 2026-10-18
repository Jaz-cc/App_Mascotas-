import 'package:flutter/material.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';

// ===============================================================
// ENCABEZADO REUTILIZABLE DE JAMIKA PET
// ===============================================================
class HeaderAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String titulo;
  final String subtitulo;
  final Color colorTexto;
  final Color colorSubtitulo;
  final Color? colorFondo;
  final double fontSize;
  final bool mostrarRegreso;
  final bool mostrarLogo;
  final bool mostrarNotificaciones;
  final int notificacionesPendientes;

  const HeaderAppBar({
    super.key,
    this.titulo = '',
    this.subtitulo = '',
    this.colorTexto = _Paleta.primarioOscuro,
    this.colorSubtitulo = _Paleta.textoSuave,
    this.colorFondo = _Paleta.fondo,
    this.fontSize = 23,
    this.mostrarRegreso = false,
    this.mostrarLogo = false,
    this.mostrarNotificaciones = true,
    this.notificacionesPendientes = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorFondo,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Row(
            children: [
              // -----------------------------------------------------
              // BOTÓN DE REGRESO
              // -----------------------------------------------------
              if (mostrarRegreso) ...[
                IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: colorTexto,
                  tooltip: 'Volver',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(46, 46),
                    shape: const CircleBorder(),
                  ),
                ),
                const SizedBox(width: 10),
              ],

              // -----------------------------------------------------
              // TÍTULO Y SUBTÍTULO
              // -----------------------------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (titulo.isNotEmpty)
                      Text(
                        titulo,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w800,
                          color: colorTexto,
                        ),
                      ),

                    if (subtitulo.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitulo,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorSubtitulo,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // -----------------------------------------------------
              // CAMPANA DE NOTIFICACIONES
              // -----------------------------------------------------
              if (mostrarNotificaciones)
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed( context, AppRoutes.notificaciones,);
                  },
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          color: colorTexto,
                          size: 27,
                        ),

                        if (notificacionesPendientes > 0)
                          Positioned(
                            right: 7,
                            top: 6,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE45C5C),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              // -----------------------------------------------------
              // LOGO OPCIONAL
              // -----------------------------------------------------
              if (mostrarLogo) ...[
                const SizedBox(width: 10),
                ClipOval(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Image.asset(
                      'assets/icons/icon_App.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const ColoredBox(
                          color: Colors.white,
                          child: Icon(
                            Icons.pets,
                            color: _Paleta.primarioOscuro,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      )
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(86);
}

// ===============================================================
// PALETA DE COLORES
// ===============================================================
class _Paleta {
  static const fondo = Color(0xFFF5F9F8);
  static const primarioOscuro = Color(0xFF1F7A70);
  static const textoSuave = Color(0xFF78908C);
}
