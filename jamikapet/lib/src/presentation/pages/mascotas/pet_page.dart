import 'package:flutter/material.dart';
import 'package:jamikapet/src/models/mascota.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';
import 'package:jamikapet/src/services/pets_service.dart';


class PetPage extends StatefulWidget {
  const PetPage({super.key});

  static const Color fondo = Color(0xFFE1F5F2);
  static const Color primario = Color(0xFF1F7A70);
  static const Color tinta = Color(0xFF16302D);
  static const Color tintaSuave = Color(0xFF5C7A77);

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
        child: _contenido(),
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

      // Botón flotante
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _irARegistro,
        backgroundColor: PetPage.primario,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
    );
  }
    
  Widget _contenido() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: PetPage.primario),
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
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
        itemCount: _mascotas.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (_, i) => _TarjetaMascota(
          mascota: _mascotas[i],
          onRegresar: _cargarMascotas,
        ),
      ),
    );
  }

  ButtonStyle _estiloBoton() => ElevatedButton.styleFrom(
    backgroundColor: PetPage.primario,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );

  Widget _mensajeCentral({
    required IconData icono,
    required String titulo,
    required String detalle,
    required Widget accion,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icono,
              size: 72,
              color: PetPage.primario.withValues(alpha: 0.65),
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: PetPage.tinta,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              detalle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: PetPage.tintaSuave,
              ),
            ),
            const SizedBox(height: 24),
            accion,
          ],
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

    return InkWell(
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140F3D3A),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: const Color(0xFFE0F3F1),
              backgroundImage:
                  foto != null ? NetworkImage(foto) : null,
              onBackgroundImageError:
                  foto != null ? (_, _) {} : null,
              child: foto == null
                  ? Text(
                      emoji,
                      style: const TextStyle(fontSize: 32),
                    )
                  : null,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mascota.nombrePet,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: PetPage.tinta,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
