import 'package:flutter/material.dart';

// ===============================================================
// BARRA SUPERIOR
// ===============================================================
class HeaderAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String titulo;
  final Color colorTexto;
  final Color? colorFondo;
  final double fontSize;
  final bool centerTitle;
  final bool mostrarRegreso;
  final bool mostrarLogo;

  const HeaderAppBar({
    super.key,
    this.titulo = '',
    this.colorTexto = _Paleta.tinta,
    this.colorFondo = _Paleta.barra,
    this.fontSize = 20,
    this.centerTitle = true,
    this.mostrarRegreso = false,
    this.mostrarLogo = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 52,
      backgroundColor: colorFondo,
      elevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      //automaticallyImplyLeading: !mostrarRegreso,

      // ---------------------------------------------------------
      // BOTÓN DE REGRESO
      // ---------------------------------------------------------
      leading: mostrarRegreso
          ? Semantics(
              button: true,
              label: 'Volver',
              child: IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                ),
                color: colorTexto,
                tooltip: 'Volver',
              ),
            )
          : null,

      // ---------------------------------------------------------
      // LOGO CENTRADO
      // ---------------------------------------------------------
      actions: mostrarLogo
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 34,
                  height: 34,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/img/LogoApp.jpeg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const ColoredBox(
                          color: Colors.white,
                          child: Icon(
                            Icons.pets,
                            color: _Paleta.primarioOscuro,
                            size: 18,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ]
          : null,

      // ---------------------------------------------------------
      // TÍTULO
      // ---------------------------------------------------------
      title: titulo.isNotEmpty
          ? Text(
              titulo,
              style: TextStyle(
                color: colorTexto,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(52);
}

// ===============================================================
// PALETA DE COLORES
// ===============================================================
class _Paleta {
  static const fondo = Color(0xFFE1F5F2);
  static const barra = Color(0xFFAEDFD9);
  static const primarioOscuro = Color(0xFF1F7A70);
  static const verdeMuyClaro = Color(0xFFD1F0EE);
  static const campo = Color(0xFFF4FBFA);
  static const borde = Color(0xFFCBE5E2);
  static const tinta = Color(0xFF16302D);
  static const tintaSuave = Color(0xFF5C7A77);
  static const aplicada = Color(0xFF2E9E5B);
}