import 'package:flutter/material.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';  
import 'package:jamikapet/src/core/storage/token_storage.dart';
import 'package:jamikapet/src/models/usuario.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jamikapet/src/services/users_service.dart'; // ajusta la ruta a tu proyecto

class PerfilUsuarioPage extends StatefulWidget {
  const PerfilUsuarioPage({
    super.key,
    this.userId,
  });

  final int? userId;

  @override
  State<PerfilUsuarioPage> createState() =>
      _PerfilUsuarioPageState();
}

class _PerfilUsuarioPageState extends State<PerfilUsuarioPage> {

  Usuario? usuario;
  bool cargando = true;
  String? error;

  final ImagePicker _picker = ImagePicker();
  bool subiendoFoto = false;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<ImageSource?> _elegirOrigen() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar una foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cambiarFoto() async {
    final actual = usuario;
    if (actual == null || subiendoFoto) return;

    if (actual.id == null) {
      _mostrarMensaje('No se pudo identificar al usuario.');
      return;
    }

    final origen = await _elegirOrigen();
    if (origen == null) return;

    final imagen = await _picker.pickImage(
      source: origen,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (imagen == null) return;

    setState(() => subiendoFoto = true);

    try {
      // 1. Subir a Cloudinary y obtener la URL
      final url = await UsersService.subirImagenUsuario(imagen: imagen);

      // 2. Guardar la URL en el backend
      await UsersService.actualizarUsuario(
        id: actual.id!,
        nombre: actual.nombre,
        apellido: actual.apellido,
        email: actual.email,
        phone: actual.phone,
        imagenUrl: url,
      );

      // 3. Actualizar el usuario guardado localmente
      final actualizado = Usuario(
        id: actual.id,
        nombre: actual.nombre,
        apellido: actual.apellido,
        email: actual.email,
        phone: actual.phone,
        image: url,
        notificationToken: actual.notificationToken,
      );

      await TokenStorage.saveUser(actualizado.toJson()); // ver nota abajo

      if (!mounted) return;
      setState(() => usuario = actualizado);
      _mostrarMensaje('Foto de perfil actualizada.');
    } on UsersServiceException catch (e) {
      _mostrarMensaje(e.message);
    } catch (_) {
      _mostrarMensaje('Ocurrió un error al actualizar la foto.');
    } finally {
      if (mounted) setState(() => subiendoFoto = false);
    }
  }

  void _mostrarMensaje(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _cargarUsuario() async {
    try {
      final datos = await TokenStorage.getUser();

      if (datos == null) {
        throw Exception(
          'No se encontraron los datos del usuario. '
          'Cierra sesión e inicia sesión nuevamente.',
        );
      }

      if (!mounted) return;

      setState(() {
        usuario = Usuario.fromJson(datos);
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        cargando = false;
      });
    }
  }

  Future<void> cerrarSesion() async {
    await TokenStorage.clearToken();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }


  @override
  Widget build(BuildContext context) {
    const primaryBackground = Color(0xFFE2F4F1);
    // const darkText = Colors.black87;

    return Scaffold(
      backgroundColor: primaryBackground,
      appBar: const HeaderAppBar(
        titulo: 'Perfil de usuario',
        mostrarLogo: true,
        mostrarRegreso: false,
        icon: Icons.person,
      ),
      body: Column(
      children: [
        Expanded(
          child: SafeArea(
            child: cargando
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(error!),
                        ),
                      )
                    : usuario == null
                        ? const Center(
                            child: Text('No se encontró el usuario.'),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),

                                Center(
                                  child: Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 55,
                                        backgroundColor: const Color(0xFF007A8C),
                                        backgroundImage: usuario?.image != null
                                            ? NetworkImage(usuario!.image!)
                                            : null,
                                        child: usuario?.image == null
                                            ? const Icon(Icons.person, size: 70, color: Colors.white)
                                            : null,
                                      ),

                                      // Indicador de carga mientras se sube
                                      if (subiendoFoto)
                                        Positioned.fill(
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black38,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Center(
                                              child: SizedBox(
                                                width: 28,
                                                height: 28,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 3,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                      // Botón de editar
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Material(
                                          color: const Color(0xFF4FC3B8),
                                          shape: const CircleBorder(
                                            side: BorderSide(color: Colors.white, width: 3),
                                          ),
                                          child: InkWell(
                                            customBorder: const CircleBorder(),
                                            onTap: subiendoFoto ? null : _cambiarFoto,
                                            child: const Padding(
                                              padding: EdgeInsets.all(9),
                                              child: Icon(Icons.camera_alt, size: 20, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 35),

                                _buildInfoTile(
                                  label: 'Nombre:',
                                  value:
                                      '${usuario!.nombre} ${usuario!.apellido}',
                                ),

                                const SizedBox(height: 16),

                                _buildInfoTile(
                                  label: 'Correo:',
                                  value: usuario!.email,
                                ),

                                const SizedBox(height: 30),

                                Center(
                                  child: SizedBox(
                                    width: 250,
                                    height: 52,
                                    child: ElevatedButton.icon(
                                      onPressed: cerrarSesion,
                                      icon: const Icon(
                                        Icons.logout,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'Cerrar sesión',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF4FC3B8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
            ),
          ),

          // ===============================================================
          // PIE DE PÁGINA / BARRA INFERIOR
          // ===============================================================
          AppBottomNavigation(
            currentIndex: 3,
            onItemSelected: (index) {
              switch (index) {
                case 0:
                  Navigator.pushNamed(context, AppRoutes.home,);
                  break;

                case 1:
                  Navigator.pushNamed(context, AppRoutes.menu,);
                  break;

                case 2:
                  Navigator.pushNamed(context, AppRoutes.pets,);
                  break;

                case 3:
                  Navigator.pushNamed(context, AppRoutes.perfil,);
                  break;
              }
            },
          ),
        ]
      )
    );
  }

  Widget _buildInfoTile({required String label, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFB2DFDB)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}