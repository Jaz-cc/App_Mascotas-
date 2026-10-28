import 'package:flutter/material.dart';
import 'package:jamikapet/src/models/desparasitacion.dart';
import 'package:jamikapet/src/models/mascota.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';
import 'package:jamikapet/src/services/desparacitacion_service.dart';
import 'package:jamikapet/src/services/pets_service.dart';
import 'package:jamikapet/src/presentation/widgets/desparactacion_modal.dart';

class DewormingPage extends StatefulWidget {
  const DewormingPage({super.key});

  @override
  State<DewormingPage> createState() => _DewormingPageState();
}

class _DewormingPageState extends State<DewormingPage> {
  List<Mascota> _mascotas = [];
  Mascota? _mascotaSeleccionada;
  List<Desparasitacion> _tratamientos = [];        // historial  <- FALTABA
  List<ProductoDesparasitante> _productos = []; 
  bool _cargandoMascotas = true;
  bool _cargandoTratamientos = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarInicial();
  }

  void _snack(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  // REGISTRAR
  Future<void> _abrirModalRegistrar() {
    return DesparasitacionModal.show(
      context,
      mascotas: _mascotas,
      productos: _productos,
      mascotaInicial: _mascotaSeleccionada,
      onSave: (d) async {
        await DesparasitacionService.registrar(
          mascotaId: d.mascota.id,
          productoId: d.producto.id,
          fechaAplicacion: d.fechaAplicacion,
          proximaDosis: d.proximaDosis,
          estado: d.estado,
        );

        if (!mounted) return;
        setState(() => _mascotaSeleccionada = d.mascota);
        _cargarTratamientos(); // sin await: el modal se cierra de inmediato
        _snack('Tratamiento registrado correctamente');
      },
    );
  }

  // ACTUALIZAR
  Future<void> _abrirModalEditar(Desparasitacion tratamiento) {
    final id = tratamiento.id;

    return DesparasitacionModal.show(
      context,
      mascotas: _mascotas,
      productos: _productos,
      mascotaInicial: _mascotaSeleccionada,
      tratamiento: tratamiento,
      onSave: (d) async {
        await DesparasitacionService.actualizar(
          id: id,
          productoId: d.producto.id,
          fechaAplicacion: d.fechaAplicacion,
          proximaDosis: d.proximaDosis,
          estado: d.estado,
        );

        if (!mounted) return;
        _cargarTratamientos();
        _snack('Tratamiento actualizado correctamente');
      },
    );
  }

  // ELIMINAR DESPARACITACION
  Future<void> _eliminarTratamiento(Desparasitacion tratamiento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar desparasitación'),
        content: Text(
          '¿Deseas eliminar "${tratamiento.producto}" del historial de '
          '${_mascotaSeleccionada?.nombrePet ?? 'tu mascota'}? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await DesparasitacionService.eliminar(tratamiento.id);

      if (!mounted) return;
      setState(() => _tratamientos.removeWhere((t) => t.id == tratamiento.id));
      _snack('Tratamiento eliminado correctamente');
    } catch (error) {
      if (!mounted) return;
      _snack(error.toString());
    }
  }

  // CARGA MASCOTAS
  Future<void> _cargarInicial() async {
    setState(() {
      _cargandoMascotas = true;
      _error = null;
    });

    try {
      
      final resultados = await Future.wait([
        PetsService.obtenerMascotas(),
        DesparasitacionService.obtenerProductos(),
      ]);
      final mascotas = resultados[0] as List<Mascota>;
      final productos = resultados[1] as List<ProductoDesparasitante>;
      if (!mounted) return;

      setState(() {
        _mascotas = mascotas;
        _productos = productos;
        _mascotaSeleccionada = mascotas.isEmpty
            ? null
            : mascotas.firstWhere(
                (mascota) => mascota.id == _mascotaSeleccionada?.id,
                orElse: () => mascotas.first,
              );
        _tratamientos = [];
      });

      if (_mascotaSeleccionada != null) {
        await _cargarTratamientos();
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _cargandoMascotas = false);
    }
  }

  Future<void> _cargarTratamientos() async {
    final mascota = _mascotaSeleccionada;
    if (mascota == null) return;

    setState(() {
      _cargandoTratamientos = true;
      _error = null;
    });

    try {
      final tratamientos =
          await DesparasitacionService.obtenerPorMascota(mascota.id);

      if (!mounted || _mascotaSeleccionada?.id != mascota.id) return;
      setState(() => _tratamientos = tratamientos);
    } catch (error) {
      if (!mounted || _mascotaSeleccionada?.id != mascota.id) return;
      setState(() {
        _tratamientos = [];
        _error = error.toString();
      });
    } finally {
      if (mounted && _mascotaSeleccionada?.id == mascota.id) {
        setState(() => _cargandoTratamientos = false);
      }
    }
  }

  void _seleccionarMascota(Mascota mascota) {
    if (mascota.id == _mascotaSeleccionada?.id) return;
    setState(() {
      _mascotaSeleccionada = mascota;
      _tratamientos = [];
    });
    _cargarTratamientos();
  }

  List<Desparasitacion> get _tratamientosFiltrados => _tratamientos;

  Desparasitacion? get _proximoTratamiento {
    final pendientes =
        _tratamientosFiltrados
            .where(
              (tratamiento) =>
                  tratamiento.estado.toLowerCase() == 'pendiente' &&
                  tratamiento.proximaDosis != null,
            )
            .toList()
          ..sort((a, b) => a.proximaDosis!.compareTo(b.proximaDosis!));
    if (pendientes.isNotEmpty) return pendientes.first;

    final hoy = DateTime.now();
    final proximos =
        _tratamientosFiltrados
            .where(
              (tratamiento) =>
                  tratamiento.proximaDosis != null &&
                  !tratamiento.proximaDosis!.isBefore(
                    DateTime(hoy.year, hoy.month, hoy.day),
                  ),
            )
            .toList()
          ..sort((a, b) => a.proximaDosis!.compareTo(b.proximaDosis!));
    return proximos.isEmpty ? null : proximos.first;
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
      body: Column(
        children: [
          // Contenido de la pantalla
          Expanded(
            child: SafeArea(
              child: RefreshIndicator(
                color: _Paleta.primarioOscuro,
                onRefresh: _cargarInicial,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _tarjetaEncabezado(),
                      const SizedBox(height: 18),
                      if (_cargandoMascotas)
                        _estadoCargando()
                      else if (_mascotas.isEmpty)
                        _error != null
                            ? _estadoError(
                                'No pudimos cargar tus mascotas.',
                                _cargarInicial,
                              )
                            : _estadoMascotasVacio()
                      else ...[
                        _selectorMascotas(),
                        const SizedBox(height: 18),
                        if (_error != null)
                          _estadoError(
                            'No pudimos cargar los tratamientos.',
                            _cargarTratamientos,
                          )
                        else ...[
                          if (_proximoTratamiento != null)
                            _tarjetaProximaDosis(),
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
                          if (_cargandoTratamientos)
                            _estadoCargando()
                          else if (_tratamientosFiltrados.isEmpty)
                            _estadoVacio()
                          else
                            ..._tratamientosFiltrados.map(_tarjetaTratamiento),
                          const SizedBox(height: 6),
                          _botonRegistrar(),
                        ],
                      ],
                    ],
                  ),
                ),
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
          children: _mascotas.map((mascota) {
            final seleccionada = mascota.id == _mascotaSeleccionada?.id;
            return Semantics(
              button: true,
              selected: seleccionada,
              label: 'Ver tratamientos de ${mascota.nombrePet}',
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => _seleccionarMascota(mascota),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: seleccionada ? _Paleta.verdeMuyClaro : Colors.white,
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
                      Icon(Icons.pets, size: 15, color: _Paleta.primarioOscuro),
                      const SizedBox(width: 6),
                      Text(
                        mascota.nombrePet,
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
          '${tratamiento.nombre}, '
          '${_formatearFecha(tratamiento.proximaDosis)}',
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
                    _formatearFecha(tratamiento.proximaDosis),
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

  Widget _estadoCargando() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: CircularProgressIndicator(color: _Paleta.primarioOscuro),
      ),
    );
  }

  Widget _estadoError(String titulo, Future<void> Function() reintentar) {
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
            size: 38,
            color: _Paleta.tintaSuave,
          ),
          const SizedBox(height: 10),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _Paleta.tinta,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, color: _Paleta.tintaSuave),
          ),
          TextButton.icon(
            onPressed: () => reintentar(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _estadoMascotasVacio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(Icons.pets_rounded, size: 38, color: _Paleta.tintaSuave),
          SizedBox(height: 10),
          Text(
            'Aún no tienes mascotas',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _Paleta.tinta,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Registra una mascota para consultar sus desparasitaciones.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: _Paleta.tintaSuave),
          ),
        ],
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
          const Icon(
            Icons.medication_outlined,
            size: 38,
            color: _Paleta.tintaSuave,
          ),
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
            'Registra la primera desparasitación de '
            '${_mascotaSeleccionada?.nombrePet ?? 'tu mascota'}',
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
  Widget _tarjetaTratamiento(Desparasitacion tratamiento) {
    final pendiente = tratamiento.estado.toLowerCase() == 'pendiente';
    final colorEstado = pendiente ? _Paleta.pendiente : _Paleta.aplicada;
    final iconoEstado = pendiente
        ? Icons.schedule_rounded
        : Icons.check_rounded;

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
                  tratamiento.producto,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: _Paleta.tinta,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
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
                      tratamiento.estado,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorEstado,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 4),
              
              Semantics(
                button: true,
                label: 'Editar tratamiento',
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _abrirModalEditar(tratamiento),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: _Paleta.primarioOscuro,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 2),
              
              Semantics(
                button: true,
                label: 'Eliminar tratamiento',
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _eliminarTratamiento(tratamiento),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
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
                _filaFecha(
                  'Fecha de aplicación',
                  _formatearFecha(tratamiento.fechaAplicacion),
                ),
                const SizedBox(height: 6),
                _filaFecha(
                  'Próxima dosis',
                  _formatearFecha(tratamiento.proximaDosis),
                ),
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
  Widget _botonRegistrar() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _abrirModalRegistrar,
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
  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'Pendiente';
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
