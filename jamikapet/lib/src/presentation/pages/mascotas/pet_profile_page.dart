import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_animaciones.dart';
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
        _snack('Foto de la mascota actualizada correctamente.'),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        _snack('No se pudo actualizar la foto: $e', esError: true),
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

  Future<void> _editarMascota(Mascota mascota) async {
    // El diálogo maneja sus propios controladores y los libera al cerrarse.
    final datos = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _EditarMascotaDialog(mascota: mascota),
    );

    if (datos == null || !mounted) return;

    try {
      await PetsService.actualizarMascota(
        id: mascota.id,
        nombre: datos['nombre'],
        especie: datos['especie'],
        raza: datos['raza'],
        sexo: datos['sexo'],
        edad: datos['edad'],
        peso: datos['peso'],
      );

      if (!mounted) return;

      setState(() {
        _mascotaFuture = _cargarMascota();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        _snack('Información actualizada correctamente 🐾'),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        _snack('Error al actualizar: $e', esError: true),
      );
    }
  }


  Future<void> _eliminarMascota(Mascota mascota) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        icon: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.delete_outline_rounded,
            size: 32,
            color: Colors.red.shade600,
          ),
        ),
        title: const Text(
          '¿Eliminar mascota?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: _Paleta.tinta,
          ),
        ),
        content: Text(
          '¿Estás segura de que deseas eliminar a ${mascota.nombrePet}? '
          'Esta acción no se puede deshacer.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: _Paleta.tintaSuave, height: 1.4),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: _Paleta.tintaSuave,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await PetsService.eliminarMascota(id: mascota.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        _snack('Mascota eliminada correctamente 🐾'),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        _snack('Error al eliminar: $e', esError: true),
      );
    }
  }

  SnackBar _snack(String texto, {bool esError = false}) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      backgroundColor: esError ? Colors.red.shade700 : _Paleta.primarioOscuro,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      content: Text(texto),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Mascota>(
      future: _mascotaFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: _Paleta.fondo,
            body: Center(
              child: CircularProgressIndicator(
                color: _Paleta.primarioOscuro,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: _Paleta.fondo,
            appBar: const HeaderAppBar(
              titulo: 'Perfil Pet',
              mostrarLogo: true,
              mostrarRegreso: true,
              icon: Icons.pets_outlined,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: EntradaAnimada(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _Paleta.primarioOscuro
                                  .withValues(alpha: 0.15),
                              blurRadius: 26,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.pets_outlined,
                          size: 48,
                          color: _Paleta.primarioOscuro,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: _Paleta.tintaSuave,
                        ),
                      ),
                      const SizedBox(height: 22),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _Paleta.primarioOscuro,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          // Sin ID no tiene caso reintentar: regresa a la lista
                          if (widget.mascotaId == null) {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.pets,
                            );
                            return;
                          }
                          setState(() {
                            _mascotaFuture = _cargarMascota();
                          });
                        },
                        icon: Icon(
                          widget.mascotaId == null
                              ? Icons.pets_rounded
                              : Icons.refresh_rounded,
                        ),
                        label: Text(
                          widget.mascotaId == null
                              ? 'Ver mis mascotas'
                              : 'Reintentar',
                        ),
                      ),
                    ],
                  ),
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
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Column(
            children: [
              EntradaAnimada(child: _encabezadoMascota(mascota)),
              const SizedBox(height: 22),
              EntradaAnimada(
                indice: 2,
                child: _botonEditar(mascota),
              ),
              const SizedBox(height: 12),
              EntradaAnimada(
                indice: 3,
                child: _botonEliminar(mascota),
              ),
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
  }


  // Encabezado con portada en degradado, foto y datos rápidos
  Widget _encabezadoMascota(Mascota mascota) {
    final sexo = mascota.sexo.toLowerCase();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0F3D3A),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 184,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Portada
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 104,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      gradient: LinearGradient(
                        colors: [_Paleta.primarioOscuro, _Paleta.primarioClaro],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 14,
                          top: 10,
                          child: Icon(
                            Icons.pets_rounded,
                            size: 34,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        Positioned(
                          right: 20,
                          bottom: 8,
                          child: Icon(
                            Icons.pets_rounded,
                            size: 58,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Foto con botón para cambiarla
                Positioned(
                  top: 40,
                  child: SizedBox(
                    width: 142,
                    height: 142,
                    child: Stack(
                      children: [
                        Container(
                          width: 132,
                          height: 132,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(34),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x260F3D3A),
                                blurRadius: 18,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(5),
                          child: Hero(
                            tag: 'mascota-foto-${mascota.id}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(29),
                              child: Container(
                                color: _Paleta.verdeMuyClaro,
                                child: mascota.image != null
                                    ? Image.network(
                                        mascota.image!,
                                        width: 122,
                                        height: 122,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, progreso) {
                                          if (progreso == null) return child;
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: _Paleta.primarioOscuro,
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Center(
                                            child: Icon(
                                              Icons.pets,
                                              size: 48,
                                              color: _Paleta.primarioOscuro,
                                            ),
                                          );
                                        },
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.pets,
                                          size: 48,
                                          color: _Paleta.primarioOscuro,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Semantics(
                            button: true,
                            label: 'Editar foto de ${mascota.nombrePet}',
                            child: PresionAnimada(
                              escala: 0.88,
                              child: Material(
                                color: _Paleta.primarioOscuro,
                                shape: const CircleBorder(
                                  side: BorderSide(color: Colors.white, width: 3),
                                ),
                                elevation: 3,
                                shadowColor: _Paleta.primarioOscuro
                                    .withValues(alpha: 0.4),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: _subiendoFoto
                                      ? null
                                      : () => _seleccionarFoto(mascota),
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: _subiendoFoto
                                          ? const Padding(
                                              key: ValueKey('subiendo'),
                                              padding: EdgeInsets.all(11),
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.photo_camera_rounded,
                                              key: ValueKey('camara'),
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              mascota.nombrePet,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: _Paleta.tinta,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              _chip(
                icono: Icons.pets_rounded,
                texto: mascota.especie,
              ),
              if (mascota.raza.isNotEmpty)
                _chip(
                  icono: Icons.auto_awesome_rounded,
                  texto: mascota.raza,
                ),
            ],
          ),

          const SizedBox(height: 18),

          // Datos rápidos
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
            child: Row(
              children: [
                Expanded(
                  child: _estadistica(
                    icono: Icons.monitor_weight_outlined,
                    valor: '${mascota.peso}',
                    unidad: 'kg',
                    etiqueta: 'Peso',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _estadistica(
                    icono: Icons.cake_outlined,
                    valor: '${mascota.edad}',
                    unidad: mascota.edad == 1 ? 'año' : 'años',
                    etiqueta: 'Edad',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _estadistica(
                    icono: sexo == 'macho'
                        ? Icons.male_rounded
                        : sexo == 'hembra'
                            ? Icons.female_rounded
                            : Icons.question_mark_rounded,
                    valor: mascota.sexo.isEmpty ? '—' : mascota.sexo,
                    etiqueta: 'Sexo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({required IconData icono, required String texto}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: _Paleta.verdeMuyClaro,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: _Paleta.primarioOscuro),
          const SizedBox(width: 5),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: _Paleta.primarioOscuro,
            ),
          ),
        ],
      ),
    );
  }

  Widget _estadistica({
    required IconData icono,
    required String valor,
    required String etiqueta,
    String? unidad,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: _Paleta.verdeMuyClaro.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: 18, color: _Paleta.primarioOscuro),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text.rich(
              TextSpan(
                text: valor,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _Paleta.tinta,
                ),
                children: [
                  if (unidad != null)
                    TextSpan(
                      text: ' $unidad',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _Paleta.tintaSuave,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            etiqueta,
            style: const TextStyle(
              fontSize: 11.5,
              color: _Paleta.tintaSuave,
            ),
          ),
        ],
      ),
    );
  }


  Widget _botonEditar(Mascota mascota) {
    return PresionAnimada(
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [_Paleta.primarioOscuro, _Paleta.primarioClaro],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _Paleta.primarioOscuro.withValues(alpha: 0.3),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () => _editarMascota(mascota),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.edit_rounded, size: 20),
            label: const Text(
              'Editar información',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _botonEliminar(Mascota mascota) {
    return PresionAnimada(
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: OutlinedButton.icon(
          onPressed: () => _eliminarMascota(mascota),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red.shade600,
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.red.shade200, width: 1.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: const Icon(Icons.delete_outline_rounded, size: 21),
          label: const Text(
            'Eliminar mascota',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

// Paleta
class _Paleta {
  static const fondo = Color(0xFFE1F5F2);
  static const primarioOscuro = Color(0xFF1F7A70);
  static const verdeMuyClaro = Color(0xFFD1F0EE);
  static const tinta = Color(0xFF16302D);
  static const tintaSuave = Color(0xFF5C7A77);

  // Tono derivado del primario para los degradados
  static final primarioClaro =
      Color.lerp(primarioOscuro, Colors.white, 0.3)!;
}

class _EditarMascotaDialog extends StatefulWidget {
  const _EditarMascotaDialog({required this.mascota});

  final Mascota mascota;

  @override
  State<_EditarMascotaDialog> createState() => _EditarMascotaDialogState();
}

class _EditarMascotaDialogState extends State<_EditarMascotaDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombre;
  late final TextEditingController _raza;
  late final TextEditingController _edad;
  late final TextEditingController _peso;

  late String especie;
  late String sexo;

  @override
  void initState() {
    super.initState();
    final mascota = widget.mascota;

    _nombre = TextEditingController(text: mascota.nombrePet);
    _raza = TextEditingController(text: mascota.raza);
    _edad = TextEditingController(text: mascota.edad.toString());
    _peso = TextEditingController(text: mascota.peso.toString());

    especie = mascota.especie.toLowerCase() == 'gato' ? 'Gato' : 'Perro';
    sexo = mascota.sexo.toLowerCase() == 'hembra' ? 'Hembra' : 'Macho';
  }

  // Se llama cuando el diálogo ya terminó de cerrarse.
  @override
  void dispose() {
    _nombre.dispose();
    _raza.dispose();
    _edad.dispose();
    _peso.dispose();
    super.dispose();
  }

  InputDecoration _decoracion(String etiqueta, IconData icono, {String? sufijo}) {
    OutlineInputBorder borde(Color color, [double ancho = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: ancho),
      );
    }

    return InputDecoration(
      labelText: etiqueta,
      suffixText: sufijo,
      prefixIcon: Icon(icono, color: _Paleta.primarioOscuro, size: 20),
      filled: true,
      fillColor: _Paleta.verdeMuyClaro.withValues(alpha: 0.35),
      labelStyle: const TextStyle(color: _Paleta.tintaSuave),
      floatingLabelStyle: const TextStyle(
        color: _Paleta.primarioOscuro,
        fontWeight: FontWeight.w600,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: borde(Colors.transparent),
      enabledBorder: borde(Colors.transparent),
      focusedBorder: borde(_Paleta.primarioOscuro, 1.6),
      errorBorder: borde(Colors.red.shade400),
      focusedErrorBorder: borde(Colors.red.shade400, 1.6),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
      ),
      titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 6),
      contentPadding: const EdgeInsets.fromLTRB(22, 12, 22, 4),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _Paleta.verdeMuyClaro,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.edit_rounded,
              size: 20,
              color: _Paleta.primarioOscuro,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Editar mascota',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: _Paleta.tinta,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombre,
                decoration: _decoracion('Nombre', Icons.pets),
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Escribe el nombre'
                        : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: especie,
                borderRadius: BorderRadius.circular(14),
                dropdownColor: Colors.white,
                decoration: _decoracion('Tipo de mascota', Icons.category_outlined),
                items: ['Perro', 'Gato']
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => especie = v);
                  }
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _raza,
                decoration: _decoracion('Raza', Icons.pets_outlined),
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Escribe la raza'
                        : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: sexo,
                borderRadius: BorderRadius.circular(14),
                dropdownColor: Colors.white,
                decoration: _decoracion('Sexo', Icons.wc),
                items: ['Macho', 'Hembra']
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => sexo = v);
                  }
                },
              ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _edad,
                      keyboardType: TextInputType.number,
                      decoration: _decoracion(
                        'Edad',
                        Icons.cake_outlined,
                        sufijo: 'años',
                      ),
                      validator: (v) {
                        final edad = int.tryParse(v ?? '');
                        if (edad == null || edad < 0) {
                          return 'Edad no válida';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _peso,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _decoracion(
                        'Peso',
                        Icons.monitor_weight_outlined,
                        sufijo: 'kg',
                      ),
                      validator: (v) {
                        final peso = double.tryParse(
                          (v ?? '').replaceAll(',', '.'),
                        );
                        if (peso == null || peso <= 0) {
                          return 'Peso no válido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: _Paleta.tintaSuave,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: () =>
              Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _Paleta.primarioOscuro,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            Navigator.pop(context, {
              'nombre': _nombre.text.trim(),
              'especie': especie,
              'raza': _raza.text.trim(),
              'sexo': sexo,
              'edad': int.parse(_edad.text),
              'peso': double.parse(
                _peso.text.replaceAll(',', '.'),
              ),
            });
          },
          child: const Text('Guardar cambios'),
        ),
      ],
    );
  }
}
