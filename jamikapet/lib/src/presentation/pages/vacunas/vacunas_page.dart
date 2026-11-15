import 'package:flutter/material.dart';
import 'package:jamikapet/src/models/mascota.dart';
import 'package:jamikapet/src/models/vacuna.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';
import 'package:jamikapet/src/services/pets_service.dart';
import 'package:jamikapet/src/core/storage/token_storage.dart';
import 'package:jamikapet/src/services/vacuna_service.dart';
import 'package:jamikapet/src/presentation/widgets/vacuna_modal.dart';

class VacunasScreen extends StatefulWidget {
  const VacunasScreen({super.key});

  @override
  State<VacunasScreen> createState() => _VacunasScreenState();
}

class _VacunasScreenState extends State<VacunasScreen> {
  List<Mascota> _mascotas = [];
  Mascota? _seleccionada;
  List<Vacuna> _vacunas = [];

  bool _cargandoMascotas = true;
  bool _cargandoVacunas = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarInicial();
  }

  Future<String?> _obtenerToken() async {
    return await TokenStorage.getToken();
  }

  Future<void> _cargarInicial() async {
    setState(() {
      _cargandoMascotas = true;
      _error = null;
    });

    try {
      final mascotas = await PetsService.obtenerMascotas();

      if (!mounted) return;

      setState(() {
        _mascotas = mascotas;

        _seleccionada = mascotas.isEmpty
            ? null
            : mascotas.firstWhere(
                (m) => m.id == _seleccionada?.id,
                orElse: () => mascotas.first,
              );

        _vacunas = [];
      });

      if (_seleccionada != null) {
        await _cargarVacunas();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _cargandoMascotas = false;
        });
      }
    }
  }

  Future<void> _cargarVacunas() async {
    final mascota = _seleccionada;
    if (mascota == null) return;

    setState(() {
      _cargandoVacunas = true;
      _error = null;
    });

    try {
      final service = VacunaService(token: await _obtenerToken());
      final lista = await service.obtenerVacunas(mascota.id);
      if (!mounted || _seleccionada?.id != mascota.id) return; // cambió de mascota
      setState(() => _vacunas = lista);
    } catch (e) {
      if (!mounted || _seleccionada?.id != mascota.id) return;
      setState(() {
        _vacunas = [];
        _error = e.toString();
      });
    } finally {
      if (mounted && _seleccionada?.id == mascota.id) {
        setState(() => _cargandoVacunas = false);
      }
    }
  }

  void _seleccionarMascota(Mascota m) {
    if (m.id == _seleccionada?.id) return;
    setState(() {
      _seleccionada = m;
      _vacunas = [];
    });
    _cargarVacunas();
  }

  Future<void> _editarVacuna(Vacuna vacuna) async {
    final resultado = await VacunaUpdateModal.show(
      context,
      fechaInicial: vacuna.fecha,
      estadoInicial: vacuna.estado.etiqueta,
      observacionesIniciales: vacuna.observaciones ?? '',
      proximaDosisInicial: vacuna.proximaDosis,
      onGuardar: (fecha, estado, observaciones, proximaDosis) async {
        final token = await _obtenerToken();

        if (token == null || token.isEmpty) {
          throw Exception(
            'No hay una sesión activa. Inicia sesión nuevamente.',
          );
        }

        final service = VacunaService(token: token);

        await service.actualizarVacuna(
          registroId: vacuna.id,
          fecha: fecha,
          estado: estado,
          observaciones: observaciones,
          proximaDosis: proximaDosis,
        );
      },
    );

    if (!mounted) return;

    if (resultado == true) {
      await _cargarVacunas();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vacuna actualizada correctamente.'),
          backgroundColor: const Color(0xFF2E9E5B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  // Build

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Paleta.fondo,
      appBar: const HeaderAppBar(
        titulo: 'Vacunas',
        mostrarLogo: true,
        mostrarRegreso: true,
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
                        _tarjetaTitulo(),
                        const SizedBox(height: 20),
                        ..._contenido(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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

  List<Widget> _contenido() {
    if (_cargandoMascotas) {
      return [_cargando()];
    }

    if (_error != null && _mascotas.isEmpty) {
      return [
        _mensajeCard(
          icono: Icons.cloud_off_rounded,
          titulo: 'No pudimos cargar la información',
          detalle: _error!,
          accion: TextButton.icon(
            onPressed: _cargarInicial,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ),
      ];
    }

    if (_mascotas.isEmpty) {
      return [
        _mensajeCard(
          icono: Icons.pets_rounded,
          titulo: 'Aún no tienes mascotas',
          detalle: 'Registra una mascota para ver su esquema de vacunación.',
        ),
      ];
    }

    return [
      _selectorMascotas(),
      const SizedBox(height: 20),
      if (_cargandoVacunas)
        _cargando()
      else if (_error != null)
        _mensajeCard(
          icono: Icons.cloud_off_rounded,
          titulo: 'No pudimos cargar las vacunas',
          detalle: _error!,
          accion: TextButton.icon(
            onPressed: _cargarVacunas,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        )
      else if (_vacunas.isEmpty)
        _mensajeCard(
          icono: Icons.vaccines_outlined,
          titulo: 'Sin vacunas registradas',
          detalle: 'Aún no hay vacunas para ${_seleccionada!.nombrePet}.',
        )
      else
        for (int i = 0; i < _vacunas.length; i++)
          _aparecer(i, _tarjetaVacuna(_vacunas[i])),
    ];
  }

  // Animación de entrada escalonada (fade + sube un poco)
  Widget _aparecer(int indice, Widget hijo) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('${_seleccionada?.id}-$indice'),
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

  Widget _cargando() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: CircularProgressIndicator(color: _Paleta.primarioOscuro),
        ),
      );

  // Encabezado
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
                  // Mascota animada (reemplaza el corazón)
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
                        "Mi Mascota",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Bitácora de salud y cuidado",
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

  // Tarjeta título
  Widget _tarjetaTitulo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white),
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
            child: const Icon(Icons.vaccines, color: Colors.white, size: 28),
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

  // Selector de mascotas
  IconData _iconoMascota(Mascota m) =>
      m.especie.toLowerCase() == 'gato' ? Icons.pets : Icons.pets;

  Widget _selectorMascotas() {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: _mascotas.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final m = _mascotas[i];
          final seleccionada = m.id == _seleccionada?.id;

          return Semantics(
            button: true,
            selected: seleccionada,
            label: "Ver vacunas de ${m.nombrePet}",
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
                  onTap: () => _seleccionarMascota(m),
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 110),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _iconoMascota(m),
                          size: 18,
                          color: seleccionada
                              ? Colors.white
                              : _Paleta.primarioOscuro,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          m.nombrePet,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: seleccionada
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: seleccionada ? Colors.white : _Paleta.tinta,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Mensajes (vacío / error)
  Widget _mensajeCard({
    required IconData icono,
    required String titulo,
    required String detalle,
    Widget? accion,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
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
          if (accion != null) ...[
            const SizedBox(height: 14),
            accion,
          ],
        ],
      ),
    );
  }

  // Tarjeta de vacuna
  Widget _tarjetaVacuna(Vacuna vacuna) {
    final estilo = _estiloEstado(vacuna.estado);
    final mascota = _seleccionada!;

    return Container(
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
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: () => _editarVacuna(vacuna),
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
                          estilo.color.withValues(alpha: 0.65),
                          estilo.color,
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
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
                              Icons.vaccines,
                              color: _Paleta.primarioOscuro,
                              size: 25,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vacuna.nombre,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: _Paleta.tinta,
                                  ),
                                ),
                                if (vacuna.descripcion.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    vacuna.descripcion,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      height: 1.3,
                                      color: _Paleta.tintaSuave,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_rounded,
                                      size: 13,
                                      color: _Paleta.tintaSuave,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      vacuna.fechaFormateada,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: _Paleta.tintaSuave,
                                      ),
                                    ),
                                  ],
                                ),
                                if (vacuna.estado == EstadoVacuna.aplicada &&
                                    vacuna.proximaDosis != null) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.notifications_active_outlined,
                                        size: 14,
                                        color: _Paleta.primarioOscuro,
                                      ),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          'Próxima dosis: '
                                          '${vacuna.proximaDosisFormateada}',
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: _Paleta.primarioOscuro,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 10),
                                const Divider(
                                  height: 1,
                                  color: _Paleta.borde,
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
                                        color: estilo.color
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            estilo.icono,
                                            size: 14,
                                            color: estilo.color,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            vacuna.estado.etiqueta,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: estilo.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      _iconoMascota(mascota),
                                      size: 14,
                                      color: _Paleta.tintaSuave,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        mascota.nombrePet,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: _Paleta.tintaSuave,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Padding(
                            padding: EdgeInsets.only(top: 14),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: _Paleta.primario,
                              size: 24,
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
      ),
    );
  }

  _EstiloEstado _estiloEstado(EstadoVacuna estado) {
    switch (estado) {
      case EstadoVacuna.aplicada:
        return const _EstiloEstado(_Paleta.aplicada, Icons.check_rounded);
      case EstadoVacuna.proximaDosis:
        return const _EstiloEstado(_Paleta.proxima, Icons.schedule_rounded);
      case EstadoVacuna.noAplicada:
        return const _EstiloEstado(_Paleta.pendiente, Icons.error_rounded);
    }
  }
}

class _EstiloEstado {
  final Color color;
  final IconData icono;
  const _EstiloEstado(this.color, this.icono);
}

// Paleta
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