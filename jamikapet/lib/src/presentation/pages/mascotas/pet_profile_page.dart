import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';
import 'package:jamikapet/src/models/mascota.dart';
import 'package:jamikapet/src/services/pets_service.dart';

class PetProfilePage extends StatefulWidget {
  const PetProfilePage({
    super.key,
    this.mascotaId,
  });

  final int? mascotaId;

  @override
  State<PetProfilePage> createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage> {
  late Future<Mascota> _mascotaFuture;

  final ImagePicker _picker = ImagePicker();

  bool _subiendoFoto = false;

  Future<void> _seleccionarFoto(Mascota mascota) async {
    try {
      final XFile? imagenSeleccionada = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      // El usuario canceló la selección.
      if (imagenSeleccionada == null) return;

      if (!mounted) return;

      setState(() {
        _subiendoFoto = true;
      });

      // Actualiza la mascota y sube la nueva imagen.
      await PetsService.actualizarMascota(
        id: mascota.id,
        nombre: mascota.nombrePet,
        especie: mascota.especie,
        raza: mascota.raza,
        sexo: mascota.sexo,
        edad: mascota.edad,
        peso: mascota.peso,
        nuevaImagen: imagenSeleccionada,
      );

      if (!mounted) return;

      // Recarga la información para mostrar la foto actualizada.
      setState(() {
        _mascotaFuture = _cargarMascota();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto de la mascota actualizada correctamente.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo actualizar la foto: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _subiendoFoto = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _mascotaFuture = _cargarMascota();
  }

  Future<Mascota> _cargarMascota() async {
    final mascotas = await PetsService.obtenerMascotas();

    if (mascotas.isEmpty) {
      throw Exception('Todavía no tienes mascotas registradas.');
    }

    final idSeleccionado = widget.mascotaId;

    if (idSeleccionado == null) {
      throw Exception('No se recibió el ID de la mascota seleccionada.');
    }

    return mascotas.firstWhere(
      (mascota) => mascota.id == idSeleccionado,
      orElse: () => throw Exception(
        'No se encontró la mascota con ID $idSeleccionado.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Mascota>(
      future: _mascotaFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: const HeaderAppBar(
              titulo: 'Perfil Pet',
              mostrarLogo: true,
              mostrarRegreso: true,
              icon: Icons.pets_outlined,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.pets_outlined,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _mascotaFuture = _cargarMascota();
                        });
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final mascota = snapshot.data!;

        return _construirPerfil(context, mascota);
      },
    );
  }


  Widget _construirPerfil(
      BuildContext context,
      Mascota mascota,
    ) {
      // Aquí colocaremos tu Scaffold original y los widgets existentes.
      return Scaffold(
        backgroundColor: _Paleta.fondo,
        appBar: const HeaderAppBar(
          titulo: 'Perfil Pet',
          mostrarLogo: true,
          mostrarRegreso: true,
          icon: Icons.pets_outlined,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            child: Column(
              children: [
                _encabezadoMascota(mascota),
                const SizedBox(height: 18),
                _tarjetaInformacionGeneral(context, mascota),
              ],              
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
      );
    }    // Mueve aquí los métodos visuales de tu clase actual.
  

  // ===============================================================
  // ENCABEZADO DE LA MASCOTA
  // ===============================================================
  Widget _encabezadoMascota(Mascota mascota) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A0F3D3A),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: mascota.image != null
                    ? Image.network(
                        mascota.image!,
                        width: 128,
                        height: 128,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.pets,
                            size: 48,
                            color: _Paleta.primarioOscuro,
                          );
                        },
                      )
                    : Icon(
                        Icons.pets,
                        size: 48,
                        color: _Paleta.primarioOscuro,
                      ),
                
              ),
            ),
            Positioned(
              bottom: -4,
              right: -4,
              child: Semantics(
                button: true,
                label: 'Editar foto de ${mascota.nombrePet}',
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _subiendoFoto
                      ? null
                      : () => _seleccionarFoto(mascota),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: _Paleta.primarioOscuro,
                      shape: BoxShape.circle,
                    ),
                    child: _subiendoFoto
                        ? const Padding(
                            padding: EdgeInsets.all(7),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.edit_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          mascota.nombrePet,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _Paleta.tinta,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _Paleta.verdeMuyClaro,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            mascota.especie,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: _Paleta.primarioOscuro,
            ),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // TARJETA DE INFORMACIÓN GENERAL
  // ===============================================================
  Widget _tarjetaInformacionGeneral(BuildContext context, Mascota mascota,) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Información general",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _Paleta.tinta,
            ),
          ),

          const SizedBox(height: 14),

          // ---------------- DATOS ----------------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: _Paleta.verdeMuyClaro.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _datoMascota(
                  icono: Icons.monitor_weight_outlined,
                  titulo: 'Peso',
                  valor: '${mascota.peso} kg',
                ),
                _separador(),
                _datoMascota(
                  icono: Icons.pets_outlined,
                  titulo: 'Raza',
                  valor: mascota.raza.isEmpty ? 'No especificada' : mascota.raza,
                ),
                _separador(),
                _datoMascota(
                  icono: Icons.cake_outlined,
                  titulo: 'Edad',
                  valor: '${mascota.edad} años',
                ),
                _separador(),
                _datoMascota(
                  icono: mascota.sexo.toLowerCase() == 'macho'
                    ? Icons.male
                    : mascota.sexo.toLowerCase() == 'hembra'
                        ? Icons.female_outlined
                        : Icons.male_outlined,
                  titulo: 'Sexo',
                  valor: mascota.sexo.isEmpty ? 'No especificado' : mascota.sexo,
                ),

                _separador(),
              ],
            ),
          ),

          const SizedBox(height: 16),

        ],
      ),
    );
  }

  // ===============================================================
  // DATO DE LA MASCOTA
  // ===============================================================
  Widget _datoMascota({
    required IconData icono,
    required String titulo,
    required String? valor,
    String? subtitulo,
    Color? subtituloColor,
    Widget? accion,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: 19, color: _Paleta.primarioOscuro),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: _Paleta.tintaSuave,
                  ),
                ),
                const SizedBox(height: 2),
                if (valor != null)
                  Text(
                    valor,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: _Paleta.tinta,
                    ),
                  ),
                if (subtitulo != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: subtituloColor ?? _Paleta.tintaSuave,
                    ),
                  ),
                ],
              ],
            ),
          ),
          //if (accion != null) accion,
          ?accion,
        ],
      ),
    );
  }

  Widget _separador() {
    return Divider(
      height: 1, 
      color: Colors.white.withValues(alpha: 0.9)
    );
  }
}

// ================================================================
// PALETA
// ================================================================
class _Paleta {
  static const fondo = Color(0xFFE1F5F2);
  static const primarioOscuro = Color(0xFF1F7A70);
  static const verdeMuyClaro = Color(0xFFD1F0EE);
  static const tinta = Color(0xFF16302D);
  static const tintaSuave = Color(0xFF5C7A77);
}