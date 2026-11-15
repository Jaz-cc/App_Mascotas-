import 'package:flutter/material.dart';
import 'package:jamikapet/src/models/mascota.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_animaciones.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';
import 'package:jamikapet/src/services/pets_service.dart';


class PetPage extends StatefulWidget {
  const PetPage({super.key});

  static const Color fondo = Color(0xFFE1F5F2);
  static const Color primario = Color(0xFF1F7A70);
  static const Color tinta = Color(0xFF16302D);
  static const Color tintaSuave = Color(0xFF5C7A77);

  // Tonos derivados del primario para degradados y fondos suaves.
  static final Color primarioClaro =
      Color.lerp(primario, Colors.white, 0.28)!;
  static final Color primarioPastel =
      Color.lerp(primario, Colors.white, 0.88)!;

  @override
  State<PetPage> createState() => _PetPageState();
}

class _PetPageState extends State<PetPage> {
  List<Mascota> _mascotas = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarMascotas();
  }

  Future<void> _cargarMascotas() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final lista = await PetsService.obtenerMascotas();

      if (!mounted) return;

      setState(() {
        _mascotas = lista;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  Future<void> _irARegistro() async {
    final creada = await Navigator.pushNamed(context, AppRoutes.registroPet);
    if (creada is Mascota) _cargarMascotas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PetPage.fondo,
      appBar: const HeaderAppBar(
        titulo: 'Mis Mascotas',
        mostrarLogo: true,
        mostrarRegreso: false,
        icon: Icons.pets_sharp,
      ),

      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: KeyedSubtree(
            key: ValueKey('$_cargando-${_error != null}-${_mascotas.length}'),
            child: _contenido(),
          ),
        ),
      ),

      // Barra de navegación abajo
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 2,
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

      // Botón flotante con degradado
      floatingActionButton: PresionAnimada(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [PetPage.primarioClaro, PetPage.primario],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: PetPage.primario.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: _irARegistro,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            highlightElevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Agregar',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _contenido() {
    if (_cargando) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: PetPage.primario.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: const CircularProgressIndicator(
                color: PetPage.primario,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Buscando a tus mascotas...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: PetPage.tintaSuave,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return _mensajeCentral(
        icono: Icons.cloud_off_rounded,
        titulo: 'No pudimos cargar tus mascotas',
        detalle: _error!,
        accion: ElevatedButton.icon(
          onPressed: _cargarMascotas,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Reintentar'),
          style: _estiloBoton(),
        ),
      );
    }

    if (_mascotas.isEmpty) {
      return _mensajeCentral(
        icono: Icons.pets_rounded,
        titulo: 'Aún no tienes mascotas',
        detalle: 'Registra a tu primera mascota para verla aquí.',
        accion: ElevatedButton.icon(
          onPressed: _irARegistro,
          icon: const Icon(Icons.add),
          label: const Text('Registrar mascota'),
          style: _estiloBoton(),
        ),
      );
    }

    return RefreshIndicator(
      color: PetPage.primario,
      onRefresh: _cargarMascotas,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.82,
        ),
        itemCount: _mascotas.length,
        itemBuilder: (_, i) => EntradaAnimada(
          indice: i,
          child: _TarjetaMascota(
            mascota: _mascotas[i],
            onRegresar: _cargarMascotas,
          ),
        ),
      ),
    );
  }

  ButtonStyle _estiloBoton() => ElevatedButton.styleFrom(
    backgroundColor: PetPage.primario,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
    textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

  Widget _mensajeCentral({
    required IconData icono,
    required String titulo,
    required String detalle,
    required Widget accion,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: EntradaAnimada(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (_, escala, child) =>
                    Transform.scale(scale: escala, child: child),
                child: Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        PetPage.primarioPastel,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: PetPage.primario.withValues(alpha: 0.16),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Icon(
                    icono,
                    size: 60,
                    color: PetPage.primario.withValues(alpha: 0.8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: PetPage.tinta,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                detalle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: PetPage.tintaSuave,
                ),
              ),
              const SizedBox(height: 26),
              accion,
            ],
          ),
        ),
      ),
    );
  }
}


class _TarjetaMascota extends StatelessWidget {
  final Mascota mascota;
  final Future<void> Function() onRegresar;

  const _TarjetaMascota({required this.mascota, required this.onRegresar,});

  @override
  Widget build(BuildContext context) {
    final foto = PetsService.urlFoto(mascota.image);
    final emoji =
        mascota.especie.toLowerCase() == 'gato' ? '🐱' : '🐶';

    final sinFoto = Container(
      color: PetPage.primarioPastel,
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 56)),
    );

    return PresionAnimada(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () async{
            final resultado = await Navigator.pushNamed(
              context,
              AppRoutes.petProfile,
              arguments: mascota.id,
            );
            if (resultado == true){
              await onRegresar();
            }
          },
          borderRadius: BorderRadius.circular(24),
          splashColor: PetPage.primario.withValues(alpha: 0.08),
          highlightColor: PetPage.primario.withValues(alpha: 0.04),
          child: Ink(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x140F3D3A),
                  blurRadius: 22,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Hero(
                      tag: 'mascota-foto-${mascota.id}',
                      child: SizedBox.expand(
                        child: foto != null
                            ? Image.network(
                                foto,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progreso) {
                                  if (progreso == null) return child;
                                  return Container(
                                    color: PetPage.primarioPastel,
                                    alignment: Alignment.center,
                                    child: const SizedBox(
                                      width: 26,
                                      height: 26,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: PetPage.primario,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (_, _, _) => sinFoto,
                              )
                            : sinFoto,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    mascota.nombrePet,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: PetPage.tinta,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
