import 'package:flutter/material.dart';

class VacunasScreen extends StatefulWidget {
  const VacunasScreen({super.key});

  @override
  State<VacunasScreen> createState() => _VacunasScreenState();
}

class _Mascota {
  final String nombre;
  final IconData icono; // representa la especie
  const _Mascota(this.nombre, this.icono);
}

class _Vacuna {
  final String nombre;
  final String descripcion;
  final String fecha;
  final String estado; // "Aplicada" | "Próxima dosis" | "No aplicada"
  final String mascota;

  const _Vacuna({
    required this.nombre,
    required this.descripcion,
    required this.fecha,
    required this.estado,
    required this.mascota,
  });
}

class _VacunasScreenState extends State<VacunasScreen> {
  String mascotaSeleccionada = "Luna";

  final List<_Mascota> mascotas = const [
    _Mascota("Luna", Icons.pets),
    _Mascota("Milo", Icons.pets),
  ];

  final List<_Vacuna> vacunas = const [
    _Vacuna(
      nombre: "Rabia",
      descripcion: "Previene la rabia en perros y gatos.",
      fecha: "12/03/2025",
      estado: "Aplicada",
      mascota: "Luna",
    ),
    _Vacuna(
      nombre: "Parvovirus",
      descripcion: "Previene el parvovirus canino.",
      fecha: "15/04/2025",
      estado: "Aplicada",
      mascota: "Luna",
    ),
    _Vacuna(
      nombre: "Moquillo",
      descripcion: "Protege contra el virus del moquillo.",
      fecha: "15/04/2025",
      estado: "Aplicada",
      mascota: "Luna",
    ),
    _Vacuna(
      nombre: "Leptospirosis",
      descripcion: "Protege contra bacterias de leptospira.",
      fecha: "10/05/2025",
      estado: "Próxima dosis",
      mascota: "Luna",
    ),
    _Vacuna(
      nombre: "Triple felina (FVRCP)",
      descripcion: "Previene rinotraqueítis, calicivirus y panleucopenia.",
      fecha: "20/03/2025",
      estado: "Aplicada",
      mascota: "Milo",
    ),
    _Vacuna(
      nombre: "Leucemia felina",
      descripcion: "Protege contra el virus de la leucemia felina.",
      fecha: "02/06/2025",
      estado: "No aplicada",
      mascota: "Milo",
    ),
  ];

  List<_Vacuna> get _vacunasFiltradas =>
      vacunas.where((v) => v.mascota == mascotaSeleccionada).toList();

  Future<void> _abrirSelectorMascotas() async {
    final elegido = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _Paleta.borde,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const Text(
                  "Ver vacunas de",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _Paleta.tinta,
                  ),
                ),
                const SizedBox(height: 12),
                ...mascotas.map((m) {
                  final activa = m.nombre == mascotaSeleccionada;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: _Paleta.verdeMuyClaro,
                      child: Icon(m.icono, color: _Paleta.primarioOscuro),
                    ),
                    title: Text(
                      m.nombre,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            activa ? FontWeight.w700 : FontWeight.w500,
                        color: _Paleta.tinta,
                      ),
                    ),
                    trailing: activa
                        ? const Icon(Icons.check_rounded,
                            color: _Paleta.primarioOscuro)
                        : null,
                    onTap: () => Navigator.pop(context, m.nombre),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (elegido != null) {
      setState(() => mascotaSeleccionada = elegido);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Paleta.fondo,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _encabezadoLogo(),
                    const SizedBox(height: 22),
                    _tarjetaTitulo(),
                    const SizedBox(height: 18),
                    _selectorMascotas(),
                    const SizedBox(height: 18),
                    if (_vacunasFiltradas.isEmpty)
                      _estadoVacio()
                    else
                      ..._vacunasFiltradas.map(_tarjetaVacuna),
                  ],
                ),
              ),
            ),
            _barraInferior(),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // ENCABEZADO CON LOGO
  // ===============================================================

  Widget _encabezadoLogo() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Decoración de huellitas, sutil, no interactiva.
        Positioned(
          top: -6,
          right: -10,
          child: Opacity(
            opacity: 0.28,
            child: Icon(Icons.pets, size: 64, color: _Paleta.verdeClaro),
          ),
        ),
        Column(
          children: [
            Row(
              children: [
                Semantics(
                  button: true,
                  label: "Volver",
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: _Paleta.primarioOscuro,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: _Paleta.primario, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A0F3D3A),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: _Paleta.primarioOscuro,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Mi Mascota",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _Paleta.primarioOscuro,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Text(
                    "Bitácora de salud y cuidado",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: _Paleta.tintaSuave,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===============================================================
  // TARJETA TÍTULO
  // ===============================================================

  Widget _tarjetaTitulo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: _Paleta.verdeMuyClaro,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.vaccines,
              color: _Paleta.primarioOscuro,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Vacunas",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _Paleta.tinta,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Mantén al día el esquema de vacunación de tu mascota.",
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: _Paleta.tintaSuave,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SELECTOR DE MASCOTAS
  // ===============================================================

  Widget _selectorMascotas() {
    return Row(
      children: mascotas.map((m) {
        final seleccionada = m.nombre == mascotaSeleccionada;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: m == mascotas.first ? 10 : 0,
            ),
            child: Semantics(
              button: true,
              selected: seleccionada,
              label: "Ver vacunas de ${m.nombre}",
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => setState(() => mascotaSeleccionada = m.nombre),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: seleccionada ? _Paleta.verdeMuyClaro : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: seleccionada
                          ? _Paleta.primarioOscuro
                          : _Paleta.borde,
                      width: seleccionada ? 1.6 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(m.icono, size: 18, color: _Paleta.primarioOscuro),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          m.nombre,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: seleccionada
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: _Paleta.tinta,
                          ),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _abrirSelectorMascotas,
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: _Paleta.tintaSuave,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ===============================================================
  // ESTADO VACÍO
  // ===============================================================

  Widget _estadoVacio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 44),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(Icons.vaccines_outlined,
              size: 40, color: _Paleta.tintaSuave),
          const SizedBox(height: 10),
          const Text(
            "Sin vacunas registradas",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _Paleta.tinta,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Agrega la primera vacuna de $mascotaSeleccionada",
            style: const TextStyle(fontSize: 12.5, color: _Paleta.tintaSuave),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // TARJETA DE VACUNA
  // ===============================================================

  Widget _tarjetaVacuna(_Vacuna vacuna) {
    final estilo = _estiloEstado(vacuna.estado);
    final mascota =
        mascotas.firstWhere((m) => m.nombre == vacuna.mascota);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F3D3A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: _Paleta.verdeMuyClaro,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.vaccines,
              color: _Paleta.primarioOscuro,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        vacuna.nombre,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: _Paleta.tinta,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      vacuna.fecha,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _Paleta.tintaSuave,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  vacuna.descripcion,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.3,
                    color: _Paleta.tintaSuave,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: estilo.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(estilo.icono, size: 13, color: estilo.color),
                          const SizedBox(width: 4),
                          Text(
                            vacuna.estado,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: estilo.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Icon(mascota.icono,
                        size: 14, color: _Paleta.tintaSuave),
                    const SizedBox(width: 4),
                    Text(
                      mascota.nombre,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _Paleta.tintaSuave,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.chevron_right_rounded,
            color: _Paleta.primario,
            size: 22,
          ),
        ],
      ),
    );
  }

  _EstiloEstado _estiloEstado(String estado) {
    switch (estado) {
      case "Aplicada":
        return const _EstiloEstado(_Paleta.aplicada, Icons.check_rounded);
      case "Próxima dosis":
        return const _EstiloEstado(_Paleta.proxima, Icons.schedule_rounded);
      default:
        return const _EstiloEstado(_Paleta.pendiente, Icons.error_rounded);
    }
  }

  // ===============================================================
  // BARRA INFERIOR
  // ===============================================================

  Widget _barraInferior() {
    return Container(
      height: 68,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x140F3D3A),
            blurRadius: 14,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _itemBarra(icono: Icons.home_outlined, label: "Inicio", activo: false),
          _itemBarra(icono: Icons.pets, label: "Mascotas", activo: false),
          _itemBarra(
              icono: Icons.person_outline, label: "Perfil", activo: false),
        ],
      ),
    );
  }

  Widget _itemBarra({
    required IconData icono,
    required String label,
    required bool activo,
  }) {
    final color = activo ? _Paleta.primarioOscuro : _Paleta.tintaSuave;

    return Semantics(
      button: true,
      selected: activo,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, size: 22, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                width: 16,
                height: 2.5,
                decoration: BoxDecoration(
                  color: activo ? _Paleta.primarioOscuro : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstiloEstado {
  final Color color;
  final IconData icono;
  const _EstiloEstado(this.color, this.icono);
}

// ================================================================
// PALETA
// ================================================================

class _Paleta {
  static const fondo = Color(0xFFE1F5F2);
  static const primario = Color(0xFF55C8BD);
  static const primarioOscuro = Color(0xFF1F7A70);
  static const verdeClaro = Color(0xFFA9DDD8);
  static const verdeMuyClaro = Color(0xFFD1F0EE);
  static const borde = Color(0xFFCBE5E2);
  static const tinta = Color(0xFF16302D);
  static const tintaSuave = Color(0xFF5C7A77);

  static const aplicada = Color(0xFF2E9E5B);
  static const proxima = Color(0xFF2E7BC9);
  static const pendiente = Color(0xFFC94F4F);
}