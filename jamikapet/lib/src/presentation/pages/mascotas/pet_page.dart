import 'package:flutter/material.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';

class PetProfilePage extends StatelessWidget {
  const PetProfilePage({
    super.key,
    this.nombre = "Luna",
    this.tipo = "Perro",
    this.fotoAsset = 'assets/img/perro.png',
    this.peso = "20 kg",
    this.pesoEstado = "Peso normal",
    this.alimentacion = "Normal",
    this.ultimaVacuna = "Rabia",
    this.proximaCitaFecha = "30 - 09 - 2026",
    this.proximaCitaMotivo = "Revisión general",
    this.proximaVacunaNombre = "Refuerzo",
    this.proximaVacunaFecha = "9 - 10 - 2026",
  });

  final String nombre;
  final String tipo;
  final String fotoAsset;
  final String peso;
  final String pesoEstado;
  final String alimentacion;
  final String ultimaVacuna;
  final String proximaCitaFecha;
  final String proximaCitaMotivo;
  final String proximaVacunaNombre;
  final String proximaVacunaFecha;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Paleta.fondo,
      appBar: const HeaderAppBar(
        titulo: 'Información de la mascota',
        mostrarLogo: true,
        mostrarRegreso: false,    
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: Column(
                  children: [
                    _encabezadoMascota(),
                    const SizedBox(height: 18),
                    _tarjetaInformacionGeneral(context),
                  ],
                ),
              ),
            ),

            // ===============================================================
            // PIE DE PÁGINA / BARRA INFERIOR
            // ===============================================================
            AppBottomNavigation(
              currentIndex: 2,
              onItemSelected: (index) {
                switch (index) {
                  case 0:
                    Navigator.pushReplacementNamed(context, AppRoutes.home,);
                    break;

                  case 1:
                    Navigator.pushReplacementNamed(context, AppRoutes.menu,);
                    break;

                  case 2:
                    Navigator.pushReplacementNamed(context, AppRoutes.petProfile,);
                    break;
                  
                  case 3:
                    Navigator.pushReplacementNamed(context, AppRoutes.perfil,);
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // ENCABEZADO DE LA MASCOTA
  // ===============================================================
  Widget _encabezadoMascota() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A0F3D3A),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  fotoAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    tipo.toLowerCase() == "gato" ? Icons.pets : Icons.pets,
                    size: 48,
                    color: _Paleta.primarioOscuro,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -4,
              right: -4,
              child: Semantics(
                button: true,
                label: "Editar foto de $nombre",
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {},
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: _Paleta.primarioOscuro,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          nombre,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _Paleta.tinta,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _Paleta.verdeMuyClaro,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            tipo,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: _Paleta.primarioOscuro,
            ),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // TARJETA DE INFORMACIÓN GENERAL
  // ===============================================================
  Widget _tarjetaInformacionGeneral(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F3D3A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Información general",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _Paleta.tinta,
            ),
          ),

          const SizedBox(height: 14),

          // ---------------- DATOS ----------------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: _Paleta.verdeMuyClaro.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _datoMascota(
                  icono: Icons.monitor_weight_outlined,
                  titulo: "Peso",
                  valor: peso,
                  subtitulo: pesoEstado,
                  subtituloColor: _Paleta.aplicada,
                ),
                _separador(),
                _datoMascota(
                  icono: Icons.restaurant_outlined,
                  titulo: "Alimentación",
                  valor: alimentacion,
                ),
                _separador(),
                _datoMascota(
                  icono: Icons.vaccines_outlined,
                  titulo: "Última vacuna",
                  valor: ultimaVacuna,
                  accion: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: _Paleta.primarioOscuro,
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.vacunas);
                    },
                    child: const Text(
                      "Ver todas",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ---------------- PRÓXIMA CITA ----------------
          _etiquetaSeccion("Próxima cita"),
          const SizedBox(height: 8),
          _tarjetaEvento(
            icono: Icons.event_outlined,
            titulo: proximaCitaMotivo,
            fecha: proximaCitaFecha,
            onTap: () {},
          ),

          const SizedBox(height: 16),

          // ---------------- PRÓXIMA VACUNA ----------------
          _etiquetaSeccion("Próxima vacuna"),
          const SizedBox(height: 8),
          _tarjetaEvento(
            icono: Icons.vaccines_outlined,
            titulo: proximaVacunaNombre,
            fecha: proximaVacunaFecha,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _etiquetaSeccion(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: _Paleta.tinta,
      ),
    );
  }

  Widget _tarjetaEvento({
    required IconData icono,
    required String titulo,
    required String fecha,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: "$titulo, $fecha",
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _Paleta.campo,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _Paleta.borde),
          ),
          child: Row(
            children: [
              Icon(icono, size: 20, color: _Paleta.primarioOscuro),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _Paleta.tinta,
                  ),
                ),
              ),
              Text(
                fecha,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: _Paleta.tintaSuave,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: _Paleta.tintaSuave,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // DATO DE LA MASCOTA
  // ===============================================================
  static Widget _datoMascota({
    required IconData icono,
    required String titulo,
    required String valor,
    String? subtitulo,
    Color? subtituloColor,
    Widget? accion,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: 19, color: _Paleta.primarioOscuro),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: _Paleta.tintaSuave,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: _Paleta.tinta,
                  ),
                ),
                if (subtitulo != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: subtituloColor ?? _Paleta.tintaSuave,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (accion != null) accion,
        ],
      ),
    );
  }

  static Widget _separador() {
    return Divider(height: 1, color: Colors.white.withOpacity(0.9));
  }
}

// ================================================================
// PALETA
// ================================================================

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