import 'package:flutter/material.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';
import 'package:jamikapet/src/presentation/widgets/cita_modal.dart';
import 'package:jamikapet/src/models/mascota.dart';
import 'package:jamikapet/src/models/consulta.dart';
import 'package:jamikapet/src/services/citas_service.dart';
import 'package:jamikapet/src/services/pets_service.dart';

class CitasVeterinariasPage extends StatefulWidget {
  const CitasVeterinariasPage({super.key});

  @override
  State<CitasVeterinariasPage> createState() => _CitasVeterinariasPageState();
}

class _CitasVeterinariasPageState
    extends State<CitasVeterinariasPage> {
  bool _cargando = true;
  List<Mascota> _mascotas = [];

  String? _error;
  List<Consulta> _citas = [];

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  Future<void> _cargarCitas() async {
    if (mounted) {
      setState(() {
        _cargando = true;
        _error = null;
      });
    }

    try {
      final resultados = await Future.wait([
        CitasService.obtenerCitas(),
        PetsService.obtenerMascotas(),
      ]);

      if (!mounted) return;

      setState(() {
        _citas = resultados[0] as List<Consulta>;
        _mascotas = resultados[1] as List<Mascota>;
        _cargando = false;
      });

    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  void _mensaje(String mensaje, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: error
            ? Colors.red.shade700
            : const Color(0xFF00695C),
      ),
    );
  }

  Future<void> _abrirModal([Consulta? cita]) async {
    if (_mascotas.isEmpty) {
      _mensaje('Primero registra una mascota.', error: true);
      return;
    }

    await CitaModal.show(
      context,
      mascotas: _mascotas,
      cita: cita,
      onSave: (d) async {

        if (cita == null) {
          await CitasService.registrarCita(
            Consulta(
              mascotaId: d.mascota.id, // se muestra el nombre, se guarda el id
              veterinario: d.veterinario,
              motivo: d.motivo,
              fecha: d.fecha,
              hora: d.hora,
              estado: d.estado,
              notas: d.notas,
            ),
          );
        } else {
          await CitasService.actualizarCita(cita.id!, {
            'mascotaId': d.mascota.id,
            'veterinario': d.veterinario,
            'motivo': d.motivo,
            'fecha': d.fecha.toIso8601String().split('T').first,
            'hora': d.hora,
            'estado': d.estado,
            'notas': d.notas,
          });
        }

        if (!mounted) return;

        await _cargarCitas();
      },
    );
  }

  Future<void> _cambiarEstado(
    Consulta cita,
    String estado,
  ) async {
    if (cita.id == null) return;

    try {
      await CitasService.actualizarCita(
        cita.id!,
        {'estado': estado},
      );

      _mensaje('Estado actualizado: $estado');
      await _cargarCitas();
    } catch (e) {
      _mensaje(
        'No se pudo actualizar el estado: $e',
        error: true,
      );
    }
  }

  Future<void> _eliminarCita(Consulta cita) async {
    if (cita.id == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar cita'),
        content: const Text(
          '¿Deseas eliminar esta cita veterinaria?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await CitasService.eliminarCita(cita.id!);

      _mensaje('Cita eliminada correctamente.');
      await _cargarCitas();
    } catch (e) {
      _mensaje(
        'No se pudo eliminar la cita: $e',
        error: true,
      );
    }
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  String _formatearHora(String hora) {
    return hora.length >= 5 ? hora.substring(0, 5) : hora;
  }

  String _nombreMascota(int id) {
    return _mascotas.where((m) => m.id == id).firstOrNull?.nombrePet ??
        'Mascota #$id';
  }

  // Color _colorEstado(String estado) {
  //   switch (estado) {
  //     case 'Confirmada':
  //       return const Color(0xFF00695C);
  //     case 'Completada':
  //       return Colors.green;
  //     case 'Rechazada':
  //     case 'Cancelada':
  //       return Colors.red;
  //     default: // Pendiente = esperando respuesta del veterinario
  //       return Colors.orange.shade800;
  //   }
  // }

  Widget _tarjetaCita(Consulta cita) {
    // final colorEstado = _colorEstado(cita.estado);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFB2DFDB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.event_note,
                  color: Color(0xFF00695C),
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cita.motivo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${_formatearFecha(cita.fecha)} · ${_formatearHora(cita.hora)}',
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Acciones',
                  onSelected: (accion) {
                    switch (accion) {
                      case 'editar':
                        _abrirModal(cita);
                        break;
                      case 'completar':
                        _cambiarEstado(cita, 'Completada');
                        break;
                      case 'cancelar':
                        _cambiarEstado(cita, 'Cancelada');
                        break;
                      case 'eliminar':
                        _eliminarCita(cita);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: Text('Editar cita'),
                    ),                    
                    const PopupMenuItem(
                      value: 'eliminar',
                      child: Text('Eliminar cita'),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 22),
            _detalle('Mascota:', _nombreMascota(cita.mascotaId)),
            _detalle('Veterinario:', cita.veterinario),
            _detalle('Notas:', cita.notas ?? 'Sin notas'),
          ],
        ),
      ),
    );
  }

  Widget _detalle(
    String etiqueta,
    String valor, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: '$etiqueta ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: valor,
              style: TextStyle(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _encabezado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(
            Icons.medical_information_outlined,
            color: Color(0xFF00695C),
            size: 40,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Citas Veterinarias',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16302D),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Agenda y organiza las consultas de tus mascotas.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5C7A77),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final citasOrdenadas = [..._citas]
      ..sort((a, b) {
        final fechaA = DateTime(
          a.fecha.year,
          a.fecha.month,
          a.fecha.day,
        );
        final fechaB = DateTime(
          b.fecha.year,
          b.fecha.month,
          b.fecha.day,
        );

        final comparacion = fechaA.compareTo(fechaB);

        if (comparacion != 0) return comparacion;

        return a.hora.compareTo(b.hora);
      });

    return Scaffold(
      backgroundColor: const Color(0xFFE2F4F1),
      appBar: const HeaderAppBar(
        titulo: 'Citas',
        mostrarRegreso: true,
        mostrarLogo: true,
        mostrarNotificaciones: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _cargarCitas,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              _encabezado(),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mis citas veterinarias',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16302D),
                    ),
                  ),
                  IconButton(
                    onPressed: _cargarCitas,
                    tooltip: 'Actualizar',
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _abrirModal(),
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar nueva cita'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA8E6CF),
                    foregroundColor: const Color(0xFF16302D),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              if (_cargando)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_error != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.cloud_off,
                          color: Colors.red,
                          size: 36,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'No se pudieron cargar las citas.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _cargarCitas,
                          child: const Text('Intentar nuevamente'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (citasOrdenadas.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 45,
                          color: Color(0xFF00695C),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Todavía no tienes citas registradas.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...citasOrdenadas.map(_tarjetaCita),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 1,
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
    );
  }
}
