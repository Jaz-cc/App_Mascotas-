import 'package:flutter/material.dart';
import 'package:jamikapet/src/models/notificacion.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/services/notification_service.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  FiltroNotificacion _filtro = FiltroNotificacion.todas;
  final NotificacionService _service = NotificacionService();
  List<Notificacion> _notificaciones = [];
  final Set<int> _procesando = {};
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final notificaciones = await _service.obtenerNotificaciones();
      if (!mounted) return;
      setState(() => _notificaciones = notificaciones);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  int get _pendientes => _notificaciones.where((n) => !n.atendida).length;

  List<Notificacion> get _notificacionesFiltradas {
    switch (_filtro) {
      case FiltroNotificacion.pendientes:
        return _notificaciones.where((n) => !n.atendida).toList();

      case FiltroNotificacion.atendidas:
        return _notificaciones.where((n) => n.atendida).toList();

      case FiltroNotificacion.todas:
        return List.of(_notificaciones);
    }
  }

  Future<void> _marcarAtendida(Notificacion notificacion) async {
    if (!_procesando.add(notificacion.id)) return;
    setState(() {});

    try {
      final actualizada = await _service.actualizarEstado(
        id: notificacion.id,
        atendida: !notificacion.atendida,
      );
      if (!mounted) return;
      setState(() {
        final index = _notificaciones.indexWhere(
          (item) => item.id == notificacion.id,
        );
        if (index != -1) _notificaciones[index] = actualizada;
      });
    } catch (error) {
      if (!mounted) return;
      _mostrarError(error.toString());
    } finally {
      _procesando.remove(notificacion.id);
      if (mounted) setState(() {});
    }
  }

  Future<void> _eliminar(Notificacion notificacion) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar notificación'),
        content: const Text('¿Deseas eliminar esta notificación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      try {
        await _service.eliminarNotificacion(notificacion.id);
        if (!mounted) return;
        setState(() {
          _notificaciones.removeWhere((n) => n.id == notificacion.id);
        });
      } catch (error) {
        if (!mounted) return;
        _mostrarError(error.toString());
      }
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    final notificaciones = _notificacionesFiltradas;

    return Scaffold(
      backgroundColor: _Colores.fondo,
      appBar: const HeaderAppBar(
        titulo: 'Notificaciones',
        mostrarRegreso: true,
        mostrarLogo: true,
        mostrarNotificaciones: false,
        icon: Icons.notifications_none_outlined,
      ),
      body: Column(
        children: [
          // Contenido de la pantalla
          Expanded(
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: _cargarNotificaciones,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    _resumen(),
                    const SizedBox(height: 22),
                    const Text(
                      'Tus notificaciones',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: _Colores.tinta,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _filtros(),
                    const SizedBox(height: 16),
                    if (_cargando)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null)
                      _estadoError()
                    else if (notificaciones.isEmpty)
                      _estadoVacio()
                    else
                      ...notificaciones.map((n) => _tarjetaNotificacion(n)),
                    const SizedBox(height: 12),
                    const Text(
                      'Mantén actualizados los registros de '
                      'salud de tus mascotas para recibir '
                      'recordatorios relevantes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: _Colores.textoSuave,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumen() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F7A70), Color(0xFF55C8BD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: Colors.white,
              size: 29,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tienes $_pendientes recordatorios pendientes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _pendientes == 0
                      ? '¡Todo está al día!'
                      : 'Revisa los cuidados de tus mascotas.',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filtros() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chipFiltro('Todas', FiltroNotificacion.todas),
          const SizedBox(width: 8),
          _chipFiltro('Pendientes', FiltroNotificacion.pendientes),
          const SizedBox(width: 8),
          _chipFiltro('Atendidas', FiltroNotificacion.atendidas),
        ],
      ),
    );
  }

  Widget _chipFiltro(String texto, FiltroNotificacion filtro) {
    final seleccionado = _filtro == filtro;

    return ChoiceChip(
      label: Text(texto),
      selected: seleccionado,
      showCheckmark: false,
      onSelected: (_) {
        setState(() => _filtro = filtro);
      },
      selectedColor: _Colores.primarioOscuro,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: seleccionado ? Colors.white : _Colores.tinta,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      side: BorderSide(
        color: seleccionado ? _Colores.primarioOscuro : _Colores.borde,
      ),
    );
  }

  Widget _estadoError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 40,
            color: _Colores.primarioOscuro,
          ),
          const SizedBox(height: 10),
          const Text(
            'No pudimos cargar las notificaciones',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: _Colores.tinta,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: _Colores.textoSuave),
          ),
          TextButton.icon(
            onPressed: _cargarNotificaciones,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaNotificacion(Notificacion n) {
    final color = _colorTipo(n.tipo);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: n.tipo == TipoNotificacion.anomalia && !n.atendida
              ? const Color(0xFFF0CACA)
              : Colors.transparent,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F3D3A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_iconoTipo(n.tipo), color: color, size: 23),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.titulo,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: n.atendida
                            ? _Colores.textoSuave
                            : _Colores.tinta,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      n.descripcion,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: _Colores.textoSuave,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 6,
                      runSpacing: 5,
                      children: [
                        _etiqueta(Icons.pets, n.mascota),
                        _etiqueta(Icons.schedule_rounded, n.fecha),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: _Colores.borde),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                n.atendida ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 16,
                color: n.atendida
                    ? _Colores.primarioOscuro
                    : _Colores.textoSuave,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  n.atendida ? 'Atendida' : 'Pendiente',
                  style: TextStyle(
                    fontSize: 11,
                    color: n.atendida
                        ? _Colores.primarioOscuro
                        : _Colores.textoSuave,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: _procesando.contains(n.id)
                    ? null
                    : () => _marcarAtendida(n),
                child: _procesando.contains(n.id)
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(n.atendida ? 'Reabrir' : 'Atender'),
              ),
              IconButton(
                tooltip: 'Eliminar notificación',
                visualDensity: VisualDensity.compact,
                onPressed: _procesando.contains(n.id)
                    ? null
                    : () => _eliminar(n),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 21,
                  color: _Colores.textoSuave,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _etiqueta(IconData icono, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _Colores.fondo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 12, color: _Colores.primarioOscuro),
          const SizedBox(width: 4),
          Text(
            texto,
            style: const TextStyle(fontSize: 10, color: _Colores.tinta),
          ),
        ],
      ),
    );
  }

  Widget _estadoVacio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.notifications_off_outlined,
            size: 42,
            color: _Colores.primarioOscuro,
          ),
          const SizedBox(height: 12),
          const Text(
            'No hay notificaciones',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _Colores.tinta,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _filtro == FiltroNotificacion.pendientes
                ? 'No tienes recordatorios pendientes.'
                : 'No hay avisos en esta categoría.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: _Colores.textoSuave),
          ),
        ],
      ),
    );
  }

  Color _colorTipo(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.vacuna:
        return const Color(0xFF3985C6);
      case TipoNotificacion.medicamento:
        return const Color(0xFF8A61BE);
      case TipoNotificacion.cita:
        return const Color(0xFF218B78);
      case TipoNotificacion.desparasitacion:
        return const Color(0xFFB78332);
      case TipoNotificacion.anomalia:
        return const Color(0xFFD34F4F);
    }
  }

  IconData _iconoTipo(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.vacuna:
        return Icons.vaccines_outlined;
      case TipoNotificacion.medicamento:
        return Icons.medication_outlined;
      case TipoNotificacion.cita:
        return Icons.local_hospital_outlined;
      case TipoNotificacion.desparasitacion:
        return Icons.pest_control_outlined;
      case TipoNotificacion.anomalia:
        return Icons.warning_amber_rounded;
    }
  }
}

class _Colores {
  static const fondo = Color(0xFFE1F5F2);
  static const primarioOscuro = Color(0xFF1F7A70);
  static const borde = Color(0xFFCBE5E2);
  static const tinta = Color(0xFF16302D);
  static const textoSuave = Color(0xFF5C7A77);
}
