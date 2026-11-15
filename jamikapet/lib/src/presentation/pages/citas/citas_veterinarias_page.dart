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

class _CitasVeterinariasPageState extends State<CitasVeterinariasPage> {
  bool _cargando = true;
  List<Mascota> _mascotas = [];
  int? _mascotaFiltroId; // null = Todas las mascotas

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
        backgroundColor: error ? Colors.red.shade700 : _Paleta.primarioOscuro,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              mascotaId: d.mascota.id,
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

  Future<void> _cambiarEstado(Consulta cita, String estado) async {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Eliminar cita',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '¿Deseas eliminar esta cita veterinaria del historial?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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

  ({Color fondo, Color texto, IconData icono}) _estiloEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmada':
        return (
          fondo: _Paleta.verdeMuyClaro,
          texto: _Paleta.primarioOscuro,
          icono: Icons.event_available_rounded,
        );
      case 'completada':
        return (
          fondo: const Color(0xFFE6F6EC),
          texto: const Color(0xFF2E7D32),
          icono: Icons.check_circle_rounded,
        );
      case 'rechazada':
      case 'cancelada':
        return (
          fondo: Colors.red.shade50,
          texto: Colors.red.shade700,
          icono: Icons.cancel_rounded,
        );
      default:
        return (
          fondo: const Color(0xFFFFF4E5),
          texto: const Color(0xFFD97706),
          icono: Icons.schedule_rounded,
        );
    }
  }

  List<Consulta> _obtenerCitasOrdenadas() {
    final filtradas = _mascotaFiltroId == null
        ? [..._citas]
        : _citas.where((c) => c.mascotaId == _mascotaFiltroId).toList();

    filtradas.sort((a, b) {
      final fechaA = DateTime(a.fecha.year, a.fecha.month, a.fecha.day);
      final fechaB = DateTime(b.fecha.year, b.fecha.month, b.fecha.day);
      final comparacion = fechaA.compareTo(fechaB);
      if (comparacion != 0) return comparacion;
      return a.hora.compareTo(b.hora);
    });

    return filtradas;
  }

  Consulta? _obtenerProximaCita(List<Consulta> ordenadas) {
    final hoy = DateTime.now();
    final inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);

    for (final c in ordenadas) {
      final diaCita = DateTime(c.fecha.year, c.fecha.month, c.fecha.day);
      final est = c.estado.toLowerCase();
      if (!diaCita.isBefore(inicioHoy) &&
          est != 'cancelada' &&
          est != 'completada' &&
          est != 'rechazada') {
        return c;
      }
    }
    return null;
  }

  // ---------------- TARJETA DE CITA ----------------
  Widget _tarjetaCita(Consulta cita) {
    final estilo = _estiloEstado(cita.estado);
    final tieneNotas = cita.notas != null && cita.notas!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          // CABECERA: Ícono + Motivo + Mascota + Estado + Menú
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _Paleta.verdeMuyClaro,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.event_note_rounded,
                  color: _Paleta.primarioOscuro,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cita.motivo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _Paleta.tinta,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _Paleta.cajaInterna,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _Paleta.bordeSuave),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.pets_rounded,
                            size: 12,
                            color: _Paleta.primarioOscuro,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _nombreMascota(cita.mascotaId),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _Paleta.primarioOscuro,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: estilo.fondo,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(estilo.icono, size: 13, color: estilo.texto),
                    const SizedBox(width: 4),
                    Text(
                      cita.estado.isEmpty ? 'Pendiente' : cita.estado,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: estilo.texto,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Opciones',
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: _Paleta.tintaSuave,
                  size: 21,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
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
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined,
                            size: 18, color: _Paleta.primarioOscuro),
                        SizedBox(width: 10),
                        Text('Editar cita'),
                      ],
                    ),
                  ),
                  if (cita.estado.toLowerCase() != 'completada')
                    const PopupMenuItem(
                      value: 'completar',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 18, color: Color(0xFF2E7D32)),
                          SizedBox(width: 10),
                          Text('Marcar completada'),
                        ],
                      ),
                    ),
                  if (cita.estado.toLowerCase() != 'cancelada')
                    const PopupMenuItem(
                      value: 'cancelar',
                      child: Row(
                        children: [
                          Icon(Icons.cancel_outlined,
                              size: 18, color: Color(0xFFD97706)),
                          SizedBox(width: 10),
                          Text('Cancelar cita'),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'eliminar',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 18, color: Colors.red.shade600),
                        const SizedBox(width: 10),
                        Text(
                          'Eliminar',
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // CAJA INTERIOR DE DATOS CLAVE
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _Paleta.cajaInterna,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _filaDetalle(
                  icono: Icons.calendar_today_rounded,
                  etiqueta: 'Fecha',
                  valor: _formatearFecha(cita.fecha),
                ),
                const SizedBox(height: 8),
                _filaDetalle(
                  icono: Icons.access_time_rounded,
                  etiqueta: 'Hora',
                  valor: '${_formatearHora(cita.hora)} hrs',
                ),
                const SizedBox(height: 8),
                _filaDetalle(
                  icono: Icons.medical_services_outlined,
                  etiqueta: 'Veterinario',
                  valor: cita.veterinario.trim().isEmpty
                      ? 'Por confirmar'
                      : cita.veterinario,
                ),
              ],
            ),
          ),

          // NOTAS (Solo si existen)
          if (tieneNotas) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.notes_rounded,
                    size: 15,
                    color: _Paleta.tintaSuave,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    cita.notas!.trim(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: _Paleta.tintaSuave,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _filaDetalle({
    required IconData icono,
    required String etiqueta,
    required String valor,
  }) {
    return Row(
      children: [
        Icon(icono, size: 15, color: _Paleta.primarioOscuro),
        const SizedBox(width: 8),
        Text(
          etiqueta,
          style: const TextStyle(
            fontSize: 13,
            color: _Paleta.tintaSuave,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            valor,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _Paleta.tinta,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- BANNER ENCABEZADO ----------------
  Widget _encabezado(Consulta? proxima) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F7A70), Color(0xFF3AA69B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F7A70).withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agenda Veterinaria',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  proxima != null
                      ? 'Próxima: ${_nombreMascota(proxima.mascotaId)} · ${_formatearFecha(proxima.fecha)} (${_formatearHora(proxima.hora)})'
                      : 'Organiza consultas y revisiones preventivas.',
                  style: TextStyle(
                    fontSize: 13,
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

  // ---------------- SELECTOR FILTRO MASCOTAS ----------------
  Widget _selectorMascotas() {
    if (_mascotas.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chipMascota(
            etiqueta: 'Todas',
            seleccionada: _mascotaFiltroId == null,
            onTap: () => setState(() => _mascotaFiltroId = null),
          ),
          const SizedBox(width: 8),
          for (final m in _mascotas) ...[
            _chipMascota(
              etiqueta: m.nombrePet,
              seleccionada: _mascotaFiltroId == m.id,
              onTap: () => setState(() => _mascotaFiltroId = m.id),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _chipMascota({
    required String etiqueta,
    required bool seleccionada,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: seleccionada ? _Paleta.verdeMuyClaro : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: seleccionada ? _Paleta.primarioOscuro : _Paleta.borde,
            width: seleccionada ? 1.8 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              etiqueta == 'Todas'
                  ? Icons.filter_list_rounded
                  : Icons.pets_rounded,
              size: 16,
              color:
                  seleccionada ? _Paleta.primarioOscuro : _Paleta.tintaSuave,
            ),
            const SizedBox(width: 6),
            Text(
              etiqueta,
              style: TextStyle(
                fontSize: 13,
                fontWeight: seleccionada ? FontWeight.w700 : FontWeight.w500,
                color: seleccionada ? _Paleta.primarioOscuro : _Paleta.tinta,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final citasOrdenadas = _obtenerCitasOrdenadas();
    final proximaCita = _obtenerProximaCita(citasOrdenadas);

    return Scaffold(
      backgroundColor: _Paleta.fondo,
      appBar: const HeaderAppBar(
        titulo: 'Citas',
        mostrarRegreso: true,
        mostrarLogo: true,
        mostrarNotificaciones: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: _Paleta.primarioOscuro,
          onRefresh: _cargarCitas,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            children: [
              _encabezado(proximaCita),
              const SizedBox(height: 18),

              if (_mascotas.length > 1) ...[
                _selectorMascotas(),
                const SizedBox(height: 18),
              ],

              // TÍTULO + CONTADOR + BOTÓN AGENDAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mis citas veterinarias',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _Paleta.tinta,
                          ),
                        ),
                        if (citasOrdenadas.isNotEmpty)
                          Text(
                            '${citasOrdenadas.length} ${citasOrdenadas.length == 1 ? 'consulta registrada' : 'consultas registradas'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _Paleta.tintaSuave,
                            ),
                          ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _abrirModal(),
                    icon: const Icon(Icons.add_rounded,
                        size: 20, color: Colors.white),
                    label: const Text(
                      'Agendar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _Paleta.primarioOscuro,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (_cargando)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: _Paleta.primarioOscuro,
                    ),
                  ),
                )
              else if (_error != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        color: Colors.red.shade400,
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'No se pudieron cargar las citas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: _Paleta.tinta,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _Paleta.tintaSuave,
                        ),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: _cargarCitas,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Intentar nuevamente'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _Paleta.primarioOscuro,
                          side:
                              const BorderSide(color: _Paleta.primarioOscuro),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (citasOrdenadas.isEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          color: _Paleta.verdeMuyClaro,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.event_available_rounded,
                          size: 38,
                          color: _Paleta.primarioOscuro,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Todavía no tienes citas registradas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _Paleta.tinta,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Agenda las próximas consultas de tus mascotas para llevar un historial médico completo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: _Paleta.tintaSuave,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _abrirModal(),
                        icon: const Icon(Icons.add_rounded, color: Colors.white),
                        label: const Text(
                          'Registrar primera cita',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _Paleta.primarioOscuro,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
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

class _Paleta {
  static const Color fondo = Color(0xFFE2F4F1);
  static const Color primarioOscuro = Color(0xFF1F7A70);
  static const Color verdeMuyClaro = Color(0xFFD5F0EB);
  static const Color cajaInterna = Color(0xFFF3FAF8);
  static const Color borde = Color(0xFFB2DFDB);
  static const Color bordeSuave = Color(0xFFD0EBE7);
  static const Color tinta = Color(0xFF1E293B);
  static const Color tintaSuave = Color(0xFF64748B);
}