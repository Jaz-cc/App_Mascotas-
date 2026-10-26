import 'package:flutter/material.dart';
import 'package:jamikapet/src/models/mascota.dart';
import 'package:jamikapet/src/models/vacuna.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';
import 'package:jamikapet/src/services/pets_service.dart';
import 'package:jamikapet/src/core/storage/token_storage.dart';
import 'package:jamikapet/src/services/vacuna_service.dart';
import 'package:jamikapet/src/presentation/widgets/modal.dart';

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
      onGuardar: (fecha, estado, observaciones) async {
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
        );
      },
    );
    
    if (!mounted) return;

    if (resultado == true) {
      await _cargarVacunas();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vacuna actualizada correctamente.'),
          backgroundColor: Color(0xFF2E9E5B),
        ),
      );
    }
  }


  // ---------------- BUILD ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Paleta.fondo,
      appBar: const HeaderAppBar(
        titulo: 'Vacunas',
        mostrarLogo: true,
        mostrarRegreso: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: RefreshIndicator(
                color: _Paleta.primarioOscuro,
                onRefresh: _cargarInicial,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _encabezadoLogo(),
                      const SizedBox(height: 22),
                      _tarjetaTitulo(),
                      const SizedBox(height: 18),
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
      const SizedBox(height: 18),
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
        ..._vacunas.map(_tarjetaVacuna),
    ];
  }

  Widget _cargando() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: CircularProgressIndicator(color: _Paleta.primarioOscuro),
        ),
      );

  // ---------------- ENCABEZADO ----------------
  Widget _encabezadoLogo() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
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

  // ---------------- TARJETA TÍTULO ----------------
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
            child: const Icon(Icons.vaccines,
                color: _Paleta.primarioOscuro, size: 27),
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

  // ---------------- SELECTOR DE MASCOTAS ----------------
  IconData _iconoMascota(Mascota m) =>
      m.especie.toLowerCase() == 'gato' ? Icons.pets : Icons.pets;

  Widget _selectorMascotas() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _mascotas.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final m = _mascotas[i];
          final seleccionada = m.id == _seleccionada?.id;

          return Semantics(
            button: true,
            selected: seleccionada,
            label: "Ver vacunas de ${m.nombrePet}",
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => _seleccionarMascota(m),
              child: Container(
                constraints: const BoxConstraints(minWidth: 110),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: seleccionada ? _Paleta.verdeMuyClaro : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: seleccionada ? _Paleta.primarioOscuro : _Paleta.borde,
                    width: seleccionada ? 1.6 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_iconoMascota(m),
                        size: 18, color: _Paleta.primarioOscuro),
                    const SizedBox(width: 8),
                    Text(
                      m.nombrePet,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            seleccionada ? FontWeight.w700 : FontWeight.w500,
                        color: _Paleta.tinta,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- MENSAJES (vacío / error) ----------------
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
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icono, size: 40, color: _Paleta.tintaSuave),
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
          const SizedBox(height: 4),
          Text(
            detalle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, color: _Paleta.tintaSuave),
          ),
          if (accion != null) ...[
            const SizedBox(height: 12),
            accion,
          ],
        ],
      ),
    );
  }

  // ---------------- TARJETA DE VACUNA ----------------
  Widget _tarjetaVacuna(Vacuna vacuna) {
    final estilo = _estiloEstado(vacuna.estado);
    final mascota = _seleccionada!;

    return InkWell(
      onTap: () => _editarVacuna(vacuna),
      borderRadius: BorderRadius.circular(18),
      child: Container(
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
              child: const Icon(Icons.vaccines,
                  color: _Paleta.primarioOscuro, size: 24),
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
                        vacuna.fechaFormateada,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _Paleta.tintaSuave,
                        ),
                      ),
                    ],
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: estilo.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(estilo.icono, size: 13, color: estilo.color),
                            const SizedBox(width: 4),
                            Text(
                              vacuna.estado.etiqueta,
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
                      
                      Icon(_iconoMascota(mascota),
                          size: 14, color: _Paleta.tintaSuave),

                      const SizedBox(width: 4),

                      Text(
                        mascota.nombrePet,
                        style: const TextStyle(
                            fontSize: 12, color: _Paleta.tintaSuave),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: _Paleta.primario, size: 22),
          ],
        ),
      )
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