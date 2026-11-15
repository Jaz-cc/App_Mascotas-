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
  List<Desparasitacion> _tratamientos = []; // historial
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
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
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
    final pendientes = _tratamientosFiltrados
        .where(
          (tratamiento) =>
              tratamiento.estado.toLowerCase() == 'pendiente' &&
              tratamiento.proximaDosis != null,
        )
        .toList()
      ..sort((a, b) => a.proximaDosis!.compareTo(b.proximaDosis!));
    if (pendientes.isNotEmpty) return pendientes.first;

    final hoy = DateTime.now();
    final proximos = _tratamientosFiltrados
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

  // ===============================================================
  // BUILD
  // ===============================================================
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
      body: Container(
        // Fondo con degradado suave para dar profundidad
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_Paleta.fondo, Color(0xFFF3FBFA)],
          ),
        ),
        child: Column(
          children: [
            // Contenido de la pantalla
            Expanded(
              child: SafeArea(
                child: RefreshIndicator(
                  color: _Paleta.primarioOscuro,
                  onRefresh: _cargarInicial,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _encabezadoLogo(),
                        const SizedBox(height: 18),
                        _tarjetaEncabezado(),
                        const SizedBox(height: 20),
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
                          const SizedBox(height: 20),
                          if (_error != null)
                            _estadoError(
                              'No pudimos cargar los tratamientos.',
                              _cargarTratamientos,
                            )
                          else ...[
                            if (_proximoTratamiento != null)
                              _tarjetaProximaDosis(),
                            const SizedBox(height: 24),
                            _tituloSeccion('Historial de tratamientos'),
                            const SizedBox(height: 14),
                            if (_cargandoTratamientos)
                              _estadoCargando()
                            else if (_tratamientosFiltrados.isEmpty)
                              _estadoVacio()
                            else
                              for (int i = 0;
                                  i < _tratamientosFiltrados.length;
                                  i++)
                                _aparecer(
                                  i,
                                  _tarjetaTratamiento(_tratamientosFiltrados[i]),
                                ),
                            const SizedBox(height: 8),
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
      ),
    );
  }

  // Animación de entrada escalonada (fade + sube un poco)
  Widget _aparecer(int indice, Widget hijo) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('${_mascotaSeleccionada?.id}-$indice'),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + (indice.clamp(0, 6) * 70)),
      curve: Curves.easeOutCubic,
      builder: (context, valor, child) => Opacity(
        opacity: valor,
        child: Transform.translate(
          offset: Offset(0, (1 - valor) * 16),
          child: child,
        ),
      ),
      child: hijo,
    );
  }

  Widget _tituloSeccion(String texto) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 22,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_Paleta.primario, _Paleta.primarioOscuro],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          texto,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _Paleta.tinta,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // BANNER CON LA MASCOTA ANIMADA
  // ===============================================================
  Widget _encabezadoLogo() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_Paleta.primario, _Paleta.primarioOscuro],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x401F7A70),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Huellas decorativas
          Positioned(
            top: -14,
            right: -10,
            child: Transform.rotate(
              angle: 0.35,
              child: Icon(
                Icons.pets,
                size: 96,
                color: Colors.white.withValues(alpha: 0.14),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -12,
            child: Transform.rotate(
              angle: -0.4,
              child: Icon(
                Icons.pets,
                size: 70,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 12,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  // Mascota animada
                  child: ClipOval(
                    child: Image.asset(
                      'assets/img/mascota_anim.gif',
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      // Si el archivo no existe o falla, muestra el corazón
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.favorite_rounded,
                        color: _Paleta.primarioOscuro,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mi Mascota',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Bitácora de salud y cuidado',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xE6FFFFFF),
                        ),
                      ),
                    ],
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
  // ENCABEZADO
  // ===============================================================
  Widget _tarjetaEncabezado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F0F3D3A),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_Paleta.verdeClaro, _Paleta.primario],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x4055C8BD),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.health_and_safety_outlined,
              color: Colors.white,
              size: 28,
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
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 12,
          children: _mascotas.map((mascota) {
            final seleccionada = mascota.id == _mascotaSeleccionada?.id;
            return Semantics(
              button: true,
              selected: seleccionada,
              label: 'Ver tratamientos de ${mascota.nombrePet}',
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: seleccionada
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_Paleta.primario, _Paleta.primarioOscuro],
                        )
                      : null,
                  color: seleccionada ? null : Colors.white,
                  border: Border.all(
                    color: seleccionada ? Colors.transparent : _Paleta.borde,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: seleccionada
                          ? const Color(0x551F7A70)
                          : const Color(0x0F0F3D3A),
                      blurRadius: seleccionada ? 14 : 8,
                      offset: Offset(0, seleccionada ? 6 : 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(26),
                    onTap: () => _seleccionarMascota(mascota),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.pets,
                            size: 16,
                            color: seleccionada
                                ? Colors.white
                                : _Paleta.primarioOscuro,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            mascota.nombrePet,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: seleccionada
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color:
                                  seleccionada ? Colors.white : _Paleta.tinta,
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
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFEAF8F6)],
          ),
          border: Border.all(color: _Paleta.borde),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A0F3D3A),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Marca de agua decorativa
            Positioned(
              right: -16,
              bottom: -18,
              child: Icon(
                Icons.calendar_month_rounded,
                size: 88,
                color: _Paleta.primario.withValues(alpha: 0.10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_Paleta.primario, _Paleta.primarioOscuro],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x4D1F7A70),
                          blurRadius: 12,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.calendar_month_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Próxima desparasitación',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _Paleta.tintaSuave,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _formatearFecha(tratamiento.proximaDosis),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _Paleta.tinta,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Recordarme esta fecha',
                    child: Material(
                      color: _Paleta.verdeMuyClaro,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  const Text('Te avisaremos antes de esta fecha'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: _Paleta.primarioOscuro,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // ESTADOS (cargando / error / vacío)
  // ===============================================================
  Widget _estadoCargando() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: CircularProgressIndicator(color: _Paleta.primarioOscuro),
      ),
    );
  }

  Widget _mensajeCard({
    required IconData icono,
    required String titulo,
    String? detalle,
    Widget? accion,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F3D3A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: _Paleta.verdeMuyClaro,
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: 34, color: _Paleta.primarioOscuro),
          ),
          const SizedBox(height: 14),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _Paleta.tinta,
            ),
          ),
          if (detalle != null) ...[
            const SizedBox(height: 6),
            Text(
              detalle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: _Paleta.tintaSuave,
              ),
            ),
          ],
          if (accion != null) ...[
            const SizedBox(height: 14),
            accion,
          ],
        ],
      ),
    );
  }

  Widget _estadoError(String titulo, Future<void> Function() reintentar) {
    return _mensajeCard(
      icono: Icons.cloud_off_rounded,
      titulo: titulo,
      detalle: _error,
      accion: TextButton.icon(
        onPressed: () => reintentar(),
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Reintentar'),
      ),
    );
  }

  Widget _estadoMascotasVacio() {
    return _mensajeCard(
      icono: Icons.pets_rounded,
      titulo: 'Aún no tienes mascotas',
      detalle: 'Registra una mascota para consultar sus desparasitaciones.',
    );
  }

  Widget _estadoVacio() {
    return _mensajeCard(
      icono: Icons.medication_outlined,
      titulo: 'Sin tratamientos registrados',
      detalle:
          'Registra la primera desparasitación de '
          '${_mascotaSeleccionada?.nombrePet ?? 'tu mascota'}',
    );
  }

  // ===============================================================
  // TARJETA DE TRATAMIENTO
  // ===============================================================
  Widget _tarjetaTratamiento(Desparasitacion tratamiento) {
    final pendiente = tratamiento.estado.toLowerCase() == 'pendiente';
    final colorEstado = pendiente ? _Paleta.pendiente : _Paleta.aplicada;
    final iconoEstado =
        pendiente ? Icons.schedule_rounded : Icons.check_rounded;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0F3D3A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: Colors.white,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Franja lateral con el color del estado
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorEstado.withValues(alpha: 0.65),
                        colorEstado,
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _Paleta.verdeMuyClaro,
                                    _Paleta.verdeClaro.withValues(alpha: 0.7),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.medication_outlined,
                                color: _Paleta.primarioOscuro,
                                size: 23,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tratamiento.producto,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: _Paleta.tinta,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            colorEstado.withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            iconoEstado,
                                            size: 13,
                                            color: colorEstado,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            tratamiento.estado,
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: colorEstado,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            _botonAccion(
                              etiqueta: 'Editar tratamiento',
                              icono: Icons.edit_outlined,
                              color: _Paleta.primarioOscuro,
                              fondo: _Paleta.verdeMuyClaro,
                              onTap: () => _abrirModalEditar(tratamiento),
                            ),
                            const SizedBox(width: 6),
                            _botonAccion(
                              etiqueta: 'Eliminar tratamiento',
                              icono: Icons.delete_outline,
                              color: Colors.red,
                              fondo: const Color(0xFFFDECEC),
                              onTap: () => _eliminarTratamiento(tratamiento),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: _Paleta.campo,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _Paleta.borde),
                          ),
                          child: Column(
                            children: [
                              _filaFecha(
                                Icons.event_available_rounded,
                                'Fecha de aplicación',
                                _formatearFecha(tratamiento.fechaAplicacion),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(height: 1, color: _Paleta.borde),
                              ),
                              _filaFecha(
                                Icons.event_repeat_rounded,
                                'Próxima dosis',
                                _formatearFecha(tratamiento.proximaDosis),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Botón circular de acción (editar / eliminar)
  Widget _botonAccion({
    required String etiqueta,
    required IconData icono,
    required Color color,
    required Color fondo,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: etiqueta,
      child: Material(
        color: fondo,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icono, size: 19, color: color),
          ),
        ),
      ),
    );
  }

  Widget _filaFecha(IconData icono, String titulo, String fecha) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icono, size: 16, color: _Paleta.primarioOscuro),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(fontSize: 12.5, color: _Paleta.tintaSuave),
          ),
        ),
        Text(
          fecha,
          style: const TextStyle(
            fontSize: 12.5,
            color: _Paleta.tinta,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // BOTÓN REGISTRAR
  // ===============================================================
  Widget _botonRegistrar() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_Paleta.primario, _Paleta.primarioOscuro],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x551F7A70),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _abrirModalRegistrar,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Registrar desparasitación',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
  static const verdeClaro = Color(0xFFA9DDD8);
  static const verdeMuyClaro = Color(0xFFD1F0EE);
  static const campo = Color(0xFFF4FBFA);
  static const borde = Color(0xFFCBE5E2);
  static const tinta = Color(0xFF16302D);
  static const tintaSuave = Color(0xFF5C7A77);
  static const aplicada = Color(0xFF2E9E5B);
  static const pendiente = Color(0xFFC98A2E);
}