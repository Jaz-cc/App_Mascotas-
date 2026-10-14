import 'package:flutter/material.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';

class DewormingPage extends StatefulWidget {
  const DewormingPage({super.key});

  @override
  State<DewormingPage> createState() => _DewormingPageState();
}

class _DewormingPageState extends State<DewormingPage> {
  String mascotaSeleccionada = 'Kyra';

  final List<String> mascotas = ['Kyra', 'Luky', 'Manzano'];

  final List<Map<String, String>> tratamientos = [
    {
      'mascota': 'Kyra',
      'nombre': 'Desparasitación interna',
      'producto': 'Antiparasitario oral',
      'fecha': '10 - 09 - 2026',
      'proxima': '10 - 12 - 2026',
      'estado': 'Aplicada',
    },
    {
      'mascota': 'Kyra',
      'nombre': 'Desparasitación externa',
      'producto': 'Tratamiento antipulgas',
      'fecha': '15 - 08 - 2026',
      'proxima': '15 - 11 - 2026',
      'estado': 'Aplicada',
    },
    {
      'mascota': 'Luky',
      'nombre': 'Desparasitación interna',
      'producto': 'Antiparasitario oral',
      'fecha': '02 - 09 - 2026',
      'proxima': '02 - 12 - 2026',
      'estado': 'Aplicada',
    },
    {
      'mascota': 'Manzano',
      'nombre': 'Próxima desparasitación',
      'producto': 'Pendiente de registrar',
      'fecha': 'Pendiente',
      'proxima': '10 - 12 - 2026',
      'estado': 'Pendiente',
    },
  ];

  List<Map<String, String>> get _tratamientosFiltrados => tratamientos
      .where((t) => t['mascota'] == mascotaSeleccionada)
      .toList();

  Map<String, String>? get _proximoTratamiento {
    final pendientes = _tratamientosFiltrados
        .where((t) => t['estado'] == 'Pendiente')
        .toList();
    if (pendientes.isNotEmpty) return pendientes.first;
    return _tratamientosFiltrados.isNotEmpty
        ? _tratamientosFiltrados.first
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Paleta.fondo,
      appBar: const HeaderAppBar(
        titulo: 'Desparasitación',
        mostrarLogo: true,
        mostrarRegreso: true,
        mostrarNotificaciones: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _tarjetaEncabezado(),
                    const SizedBox(height: 18),
                    _selectorMascotas(),
                    const SizedBox(height: 18),
                    if (_proximoTratamiento != null) _tarjetaProximaDosis(),
                    const SizedBox(height: 22),
                    const Text(
                      'Historial de tratamientos',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _Paleta.tinta,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_tratamientosFiltrados.isEmpty)
                      _estadoVacio()
                    else
                      ..._tratamientosFiltrados.map(_tarjetaTratamiento),
                    const SizedBox(height: 6),
                    _botonRegistrar(),
                  ],
                ),
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
  // ENCABEZADO
  // ===============================================================
  Widget _tarjetaEncabezado() {
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
              Icons.health_and_safety_outlined,
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
                  'Desparasitación',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _Paleta.tinta,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Lleva el control de los tratamientos de tu mascota.',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona tu mascota',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _Paleta.tinta,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: mascotas.map((mascota) {
            final seleccionada = mascota == mascotaSeleccionada;
            return Semantics(
              button: true,
              selected: seleccionada,
              label: 'Ver tratamientos de $mascota',
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () =>
                    setState(() => mascotaSeleccionada = mascota),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color:
                        seleccionada ? _Paleta.verdeMuyClaro : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: seleccionada
                          ? _Paleta.primarioOscuro
                          : _Paleta.borde,
                      width: seleccionada ? 1.6 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pets,
                          size: 15, color: _Paleta.primarioOscuro),
                      const SizedBox(width: 6),
                      Text(
                        mascota,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: seleccionada
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: _Paleta.tinta,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ===============================================================
  // PRÓXIMA DOSIS
  // ===============================================================

  Widget _tarjetaProximaDosis() {
    final tratamiento = _proximoTratamiento!;
    return Semantics(
      label:
          '${tratamiento['nombre']}, ${tratamiento['proxima']}',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _Paleta.borde),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F0F3D3A),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: _Paleta.verdeMuyClaro,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: _Paleta.primarioOscuro,
                size: 25,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Próxima desparasitación',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _Paleta.tinta,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tratamiento['proxima']!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _Paleta.tintaSuave,
                    ),
                  ),
                ],
              ),
            ),
            Semantics(
              button: true,
              label: 'Recordarme esta fecha',
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Te avisaremos antes de esta fecha'),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: _Paleta.primarioOscuro,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // ESTADO VACÍO
  // ===============================================================

  Widget _estadoVacio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(Icons.medication_outlined,
              size: 38, color: _Paleta.tintaSuave),
          const SizedBox(height: 10),
          const Text(
            'Sin tratamientos registrados',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _Paleta.tinta,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Registra la primera desparasitación de $mascotaSeleccionada',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, color: _Paleta.tintaSuave),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // TARJETA DE TRATAMIENTO
  // ===============================================================

  Widget _tarjetaTratamiento(Map<String, String> tratamiento) {
    final pendiente = tratamiento['estado'] == 'Pendiente';
    final colorEstado = pendiente ? _Paleta.pendiente : _Paleta.aplicada;
    final iconoEstado =
        pendiente ? Icons.schedule_rounded : Icons.check_rounded;

    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: _Paleta.verdeMuyClaro,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medication_outlined,
                  color: _Paleta.primarioOscuro,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tratamiento['nombre']!,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: _Paleta.tinta,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: colorEstado.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(iconoEstado, size: 12, color: colorEstado),
                    const SizedBox(width: 3),
                    Text(
                      tratamiento['estado']!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorEstado,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            tratamiento['producto']!,
            style: const TextStyle(fontSize: 12.5, color: _Paleta.tintaSuave),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _Paleta.campo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _filaFecha('Fecha de aplicación', tratamiento['fecha']!),
                const SizedBox(height: 6),
                _filaFecha('Próxima dosis', tratamiento['proxima']!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaFecha(String titulo, String fecha) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(fontSize: 12, color: _Paleta.tintaSuave),
          ),
        ),
        Text(
          fecha,
          style: const TextStyle(
            fontSize: 12,
            color: _Paleta.tinta,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // BOTÓN REGISTRAR
  // ===============================================================

  Widget _botonRegistrar() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => _mostrarFormulario(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Registrar desparasitación',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _Paleta.primario,
          foregroundColor: _Paleta.tinta,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // FORMULARIO (DIÁLOGO)
  // ===============================================================
  void _mostrarFormulario(BuildContext context) {
    final productoController = TextEditingController();
    DateTime? fechaAplicacion;
    DateTime? proximaDosis;
    String mascotaDelFormulario = mascotaSeleccionada;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, actualizarDialogo) {
            String formatearCorta(DateTime? f) {
              if (f == null) return '';
              return '${f.day.toString().padLeft(2, '0')}/'
                  '${f.month.toString().padLeft(2, '0')}/${f.year}';
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nueva desparasitación',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _Paleta.tinta,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Mascota
                      const Text(
                        'Mascota',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _Paleta.tintaSuave,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: mascotas.map((m) {
                          final activa = m == mascotaDelFormulario;
                          return ChoiceChip(
                            label: Text(m),
                            selected: activa,
                            onSelected: (_) => actualizarDialogo(
                                () => mascotaDelFormulario = m),
                            selectedColor: _Paleta.verdeMuyClaro,
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: activa
                                  ? _Paleta.primarioOscuro
                                  : _Paleta.borde,
                            ),
                            labelStyle: const TextStyle(
                              fontSize: 12.5,
                              color: _Paleta.tinta,
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: productoController,
                        decoration: InputDecoration(
                          labelText: 'Nombre del producto',
                          filled: true,
                          fillColor: _Paleta.campo,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      _campoFecha(
                        etiqueta: fechaAplicacion == null
                            ? 'Fecha de aplicación'
                            : formatearCorta(fechaAplicacion),
                        onTap: () async {
                          final fecha = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (fecha != null) {
                            actualizarDialogo(() => fechaAplicacion = fecha);
                          }
                        },
                      ),

                      const SizedBox(height: 10),

                      _campoFecha(
                        etiqueta: proximaDosis == null
                            ? 'Próxima dosis'
                            : formatearCorta(proximaDosis),
                        onTap: () async {
                          final fecha = await showDatePicker(
                            context: context,
                            initialDate: fechaAplicacion ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (fecha != null) {
                            actualizarDialogo(() => proximaDosis = fecha);
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(color: _Paleta.tintaSuave),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _Paleta.primario,
                                foregroundColor: _Paleta.tinta,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                if (productoController.text.trim().isEmpty ||
                                    fechaAplicacion == null ||
                                    proximaDosis == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Completa todos los campos'),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  tratamientos.insert(0, {
                                    'mascota': mascotaDelFormulario,
                                    'nombre': 'Desparasitación',
                                    'producto': productoController.text.trim(),
                                    'fecha': _formatearFecha(fechaAplicacion!),
                                    'proxima': _formatearFecha(proximaDosis!),
                                    'estado': 'Aplicada',
                                  });
                                  mascotaSeleccionada = mascotaDelFormulario;
                                });

                                Navigator.pop(dialogContext);
                                ScaffoldMessenger.of(this.context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Tratamiento registrado correctamente',
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Guardar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _campoFecha({
    required String etiqueta,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: _Paleta.campo,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _Paleta.borde),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              etiqueta,
              style: const TextStyle(fontSize: 14, color: _Paleta.tinta),
            ),
            const Icon(
              Icons.calendar_month_outlined,
              size: 18,
              color: _Paleta.primarioOscuro,
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')} - '
        '${fecha.month.toString().padLeft(2, '0')} - ${fecha.year}';
  }
}

// ================================================================
// PALETA
// ================================================================

class _Paleta {
  static const fondo = Color(0xFFE1F5F2);
  static const primario = Color(0xFF55C8BD);
  static const primarioOscuro = Color(0xFF1F7A70);
  static const verdeMuyClaro = Color(0xFFD1F0EE);
  static const campo = Color(0xFFF4FBFA);
  static const borde = Color(0xFFCBE5E2);
  static const tinta = Color(0xFF16302D);
  static const tintaSuave = Color(0xFF5C7A77);

  static const aplicada = Color(0xFF2E9E5B);
  static const pendiente = Color(0xFFC98A2E);
}