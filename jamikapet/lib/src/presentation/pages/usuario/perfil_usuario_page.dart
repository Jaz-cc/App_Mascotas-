import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jamikapet/src/core/storage/token_storage.dart';
import 'package:jamikapet/src/models/usuario.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';
import 'package:jamikapet/src/services/users_service.dart';

class PerfilUsuarioPage extends StatefulWidget {
  const PerfilUsuarioPage({
    super.key,
    this.userId,
  });

  final int? userId;

  @override
  State<PerfilUsuarioPage> createState() => _PerfilUsuarioPageState();
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cambiar foto de perfil',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: _Paleta.tinta,
                ),
              ),
              const SizedBox(height: 16),
              _opcionOrigenFoto(
                icono: Icons.photo_library_outlined,
                titulo: 'Elegir de la galería',
                subtitulo: 'Selecciona una imagen guardada en tu dispositivo',
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 10),
              _opcionOrigenFoto(
                icono: Icons.photo_camera_outlined,
                titulo: 'Tomar una foto',
                subtitulo: 'Usa la cámara para capturar una nueva foto',
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _opcionOrigenFoto({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _Paleta.cajaInterna,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _Paleta.bordeSuave),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: _Paleta.verdeMuyClaro,
                shape: BoxShape.circle,
              ),
              child: Icon(icono, color: _Paleta.primarioOscuro, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _Paleta.tinta,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _Paleta.tintaSuave,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: _Paleta.tintaSuave,
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
      _mostrarMensaje('No se pudo identificar al usuario.', esError: true);
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

      await TokenStorage.saveUser(actualizado.toJson());

      if (!mounted) return;
      setState(() => usuario = actualizado);
      _mostrarMensaje('Foto de perfil actualizada.');
    } on UsersServiceException catch (e) {
      _mostrarMensaje(e.message, esError: true);
    } catch (_) {
      _mostrarMensaje('Ocurrió un error al actualizar la foto.', esError: true);
    } finally {
      if (mounted) setState(() => subiendoFoto = false);
    }
  }

  void _mostrarMensaje(String texto, {bool esError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          backgroundColor:
              esError ? Colors.red.shade700 : _Paleta.primarioOscuro,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  Future<void> _cargarUsuario() async {
    setState(() {
      cargando = true;
      error = null;
    });

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
        error = e.toString().replaceFirst('Exception: ', '');
        cargando = false;
      });
    }
  }

  Future<void> _confirmarCerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cerrar sesión',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '¿Seguro que deseas salir de tu cuenta en JamikaPet?',
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
              backgroundColor: _Paleta.primarioOscuro,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await cerrarSesion();
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
    return Scaffold(
      backgroundColor: _Paleta.fondo,
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
                      child: CircularProgressIndicator(
                        color: _Paleta.primarioOscuro,
                      ),
                    )
                  : error != null
                      ? _vistaError()
                      : usuario == null
                          ? const Center(
                              child: Text('No se encontró el usuario.'),
                            )
                          : SingleChildScrollView(
                              padding:
                                  const EdgeInsets.fromLTRB(18, 16, 18, 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _tarjetaCabeceraUsuario(),
                                  const SizedBox(height: 20),
                                  _tarjetaInformacionPersonal(),
                                  const SizedBox(height: 24),
                                  _botonCerrarSesion(),
                                ],
                              ),
                            ),
            ),
          ),
          AppBottomNavigation(
            currentIndex: 3,
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

  // ---------------- TARJETA CABECERA CON AVATAR ----------------
  Widget _tarjetaCabeceraUsuario() {
    final nombreCompleto = '${usuario!.nombre} ${usuario!.apellido}'.trim();
    final tieneFoto =
        usuario?.image != null && usuario!.image!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F7A70), Color(0xFF3AA69B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F7A70).withValues(alpha: 0.24),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.85),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  backgroundImage:
                      tieneFoto ? NetworkImage(usuario!.image!) : null,
                  child: !tieneFoto
                      ? const Icon(
                          Icons.person_rounded,
                          size: 62,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
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
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: subiendoFoto ? null : _cambiarFoto,
                    child: const Padding(
                      padding: EdgeInsets.all(9),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 19,
                        color: _Paleta.primarioOscuro,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            nombreCompleto.isEmpty ? 'Usuario JamikaPet' : nombreCompleto,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- TARJETA DE DATOS PERSONALES ----------------
  Widget _tarjetaInformacionPersonal() {
    final nombreCompleto = '${usuario!.nombre} ${usuario!.apellido}'.trim();
    final telefono = (usuario!.phone as String?)?.trim() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
          const Row(
            children: [
              Icon(
                Icons.badge_outlined,
                size: 20,
                color: _Paleta.primarioOscuro,
              ),
              SizedBox(width: 8),
              Text(
                'Información personal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _Paleta.tinta,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _Paleta.cajaInterna,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _filaDato(
                  icono: Icons.person_outline_rounded,
                  etiqueta: 'Nombre completo',
                  valor: nombreCompleto.isEmpty
                      ? 'Sin especificar'
                      : nombreCompleto,
                ),
                Divider(height: 22, color: Colors.grey.shade200),
                _filaDato(
                  icono: Icons.email_outlined,
                  etiqueta: 'Correo electrónico',
                  valor: usuario!.email,
                ),
                Divider(height: 22, color: Colors.grey.shade200),
                _filaDato(
                  icono: Icons.phone_outlined,
                  etiqueta: 'Teléfono',
                  valor: telefono.isEmpty ? 'No registrado' : telefono,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaDato({
    required IconData icono,
    required String etiqueta,
    required String valor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: _Paleta.verdeMuyClaro,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icono, size: 19, color: _Paleta.primarioOscuro),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiqueta,
                style: const TextStyle(
                  fontSize: 12,
                  color: _Paleta.tintaSuave,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _Paleta.tinta,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- BOTÓN CERRAR SESIÓN ----------------
  Widget _botonCerrarSesion() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _confirmarCerrarSesion,
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text(
          'Cerrar sesión',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _Paleta.primarioOscuro,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ---------------- VISTA ERROR ----------------
  Widget _vistaError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.shade100),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 10),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: _Paleta.tinta,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _cargarUsuario,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reintentar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _Paleta.primarioOscuro,
                  side: const BorderSide(color: _Paleta.primarioOscuro),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Paleta {
  static const Color fondo = Color(0xFFE2F4F1);
  static const Color primarioOscuro = Color(0xFF1F7A70);
  static const Color verdeMuyClaro = Color(0xFFD5F0EB);
  static const Color cajaInterna = Color(0xFFF3FAF8);
  static const Color bordeSuave = Color(0xFFD0EBE7);
  static const Color tinta = Color(0xFF1E293B);
  static const Color tintaSuave = Color(0xFF64748B);
}