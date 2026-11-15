import 'package:flutter/material.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';
import 'package:jamikapet/src/presentation/widgets/medicamento_modal.dart';
import 'package:jamikapet/src/models/medicamento.dart';
import 'package:jamikapet/src/models/mascota.dart';
import 'package:jamikapet/src/services/medicamento_service.dart';
import 'package:jamikapet/src/services/pets_service.dart';

class MedicamentoPage extends StatefulWidget {
  /// Mascota que se preselecciona al abrir la pantalla (opcional).
  final int? mascotaId;

  const MedicamentoPage({super.key, this.mascotaId});

  @override
  State<MedicamentoPage> createState() => _MedicamentoPageState();
}

class _MedicamentoPageState extends State<MedicamentoPage> {
  // ---------------- ESTADO ----------------
  List<Mascota> _mascotas = [];
  Mascota? _seleccionada;
  bool _cargandoMascotas = true;

  List<Medicamento> listaMedicamentos = [];
  bool cargando = false;
  String? errorCarga;

  // Evita que una respuesta lenta pise a una más reciente
  int _peticion = 0;

  int? get _mascotaId =>
      _seleccionada == null ? null : int.tryParse(_seleccionada!.id.toString());

  @override
  void initState() {
    super.initState();
    _cargarMascotas();
  }

  // ---------------- CARGAR MASCOTAS ----------------
  Future<void> _cargarMascotas() async {
    setState(() {
      _cargandoMascotas = true;
      errorCarga = null;
    });

    try {
      final mascotas = await PetsService.obtenerMascotas();
      if (!mounted) return;

      Mascota? inicial;
      if (mascotas.isNotEmpty) {
        inicial = mascotas.firstWhere(
          (m) => int.tryParse(m.id.toString()) == widget.mascotaId,
          orElse: () => mascotas.first,
        );
      }

      setState(() {
        _mascotas = mascotas;
        _seleccionada = inicial;
        _cargandoMascotas = false;
      });

      if (inicial != null) _cargarMedicamentos();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorCarga = e.toString();
        _cargandoMascotas = false;
      });
    }
  }

  // ---------------- CARGAR MEDICAMENTOS DE LA MASCOTA ----------------
  Future<void> _cargarMedicamentos() async {
    final id = _mascotaId;
    if (id == null) return;

    final actual = ++_peticion;

    setState(() {
      cargando = true;
      errorCarga = null;
    });

    try {
      final medicamentos =
          await MedicamentoService.obtenerPorMascota(id.toString());

      if (!mounted || actual != _peticion) return;

      setState(() {
        listaMedicamentos = medicamentos;
        cargando = false;
      });
    } catch (e) {
      if (!mounted || actual != _peticion) return;
      setState(() {
        errorCarga = e.toString();
        cargando = false;
      });
    }
  }

  // ---------------- SELECCIONAR MASCOTA ----------------
  void _seleccionarMascota(Mascota m) {
    if (m.id == _seleccionada?.id) return;
    setState(() {
      _seleccionada = m;
      listaMedicamentos = [];
    });
    _cargarMedicamentos();
  }

  // ---------------- HELPERS ----------------
  DateTime _convertirFecha(dynamic valor) {
    if (valor is DateTime) return valor;

    final texto = valor?.toString() ?? '';
    final fecha = DateTime.tryParse(texto);

    if (fecha == null) {
      throw FormatException('Fecha inválida: "$texto". Usa el formato AAAA-MM-DD.');
    }
    return fecha;
  }

  String _texto(dynamic valor) => valor?.toString().trim() ?? '';

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _fmtFechaHora(DateTime d) {
    final local = d.toLocal();
    return '${_fmt(local)} · ${_horaAmPm(local)}';
  }

  void _snack(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ---------------- AGREGAR ----------------
  Future<void> _abrirModalAgregar() async {
    final mascotaId = _mascotaId;
    if (mascotaId == null) {
      _snack('Selecciona una mascota antes de registrar un medicamento.');
      return;
    }

    MedicamentoModal.show(
      context,
      esEdicion: false,
      onSave: (datos) async {
        try {
          final medicamento = Medicamento(
            mascotaId: mascotaId,
            nombre: _texto(datos['nombre']),
            dosis: _texto(datos['dosis']),
            frecuencia: _texto(datos['frecuencia']),
            horaAdministracion:
                _texto(datos['horarios'] ?? datos['horaAdministracion']),
            fechaInicio: _convertirFecha(datos['inicio'] ?? datos['fechaInicio']),
            fechaFinalizacion:
                _convertirFecha(datos['fin'] ?? datos['fechaFinalizacion']),
            veterinario: _texto(datos['veterinario']),
            indicaciones: _texto(datos['indicaciones']),
          );

          final guardado =
              await MedicamentoService.registrarMedicamento(medicamento);

          if (!mounted) return;

          if (_mascotaId == mascotaId) {
            setState(() => listaMedicamentos.add(guardado));
          }

          _snack('Medicamento guardado.', color: _Paleta.primarioOscuro);
        } catch (e) {
          if (!mounted) return;
          _snack('No se pudo guardar: $e', color: Colors.red);
        }
      },
    );
  }

  // ---------------- EDITAR ----------------
  void _abrirModalEditar(int index) {
    final med = listaMedicamentos[index];

    MedicamentoModal.show(
      context,
      esEdicion: true,
      datosIniciales: {
        'nombre': med.nombre,
        'dosis': med.dosis,
        'frecuencia': med.frecuencia,
        'horarios': med.horaAdministracion,
        'inicio': med.fechaInicio.toIso8601String().split('T').first,
        'fin': med.fechaFinalizacion.toIso8601String().split('T').first,
        'veterinario': med.veterinario,
        'indicaciones': med.indicaciones,
      },
      onSave: (datos) async {
        try {
          String conDefecto(dynamic nuevo, String actual) =>
              _texto(nuevo).isEmpty ? actual : _texto(nuevo);

          final actualizado = Medicamento(
            id: med.id,
            mascotaId: med.mascotaId,
            nombre: conDefecto(datos['nombre'], med.nombre),
            dosis: conDefecto(datos['dosis'], med.dosis),
            frecuencia: conDefecto(datos['frecuencia'], med.frecuencia),
            horaAdministracion: conDefecto(
              datos['horarios'] ?? datos['horaAdministracion'],
              med.horaAdministracion,
            ),
            fechaInicio: _convertirFecha(
              datos['inicio'] ?? datos['fechaInicio'] ?? med.fechaInicio,
            ),
            fechaFinalizacion: _convertirFecha(
              datos['fin'] ?? datos['fechaFinalizacion'] ?? med.fechaFinalizacion,
            ),
            veterinario: conDefecto(datos['veterinario'], med.veterinario),
            indicaciones: conDefecto(datos['indicaciones'], med.indicaciones),
            esActivo: med.esActivo,
          );

          final resultado =
              await MedicamentoService.actualizarMedicamento(actualizado);

          if (!mounted) return;

          setState(() => listaMedicamentos[index] = resultado);
          _snack('Tratamiento actualizado correctamente.',
              color: _Paleta.primarioOscuro);
        } catch (e) {
          if (!mounted) return;
          _snack('No se pudo actualizar: $e', color: Colors.red);
        }
      },
    );
  }

  // ---------------- ELIMINAR ----------------
  Future<void> _eliminarMedicamento(int index) async {
    final med = listaMedicamentos[index];

    if (med.id == null) {
      _snack('El medicamento no tiene un ID válido.');
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Eliminar medicamento',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('¿Deseas eliminar "${med.nombre}" del historial?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await MedicamentoService.eliminarMedicamento(med.id!);
      if (!mounted) return;
      setState(() => listaMedicamentos.removeAt(index));
      _snack('Medicamento eliminado correctamente.',
          color: _Paleta.primarioOscuro);
    } catch (e) {
      if (!mounted) return;
      _snack('No se pudo eliminar: $e', color: Colors.red);
    }
  }

  // ---------------- REGISTRAR TOMA ----------------
  void _mostrarModalRegistrarToma(Medicamento med) {
    final medicamentoNombre = med.nombre;
    final dosis = med.dosis;
    final notasController = TextEditingController();
    TimeOfDay horaSeleccionada = TimeOfDay.now();
    bool guardando = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 16,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _Paleta.verdeMuyClaro,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.medication_rounded,
                          color: _Paleta.primarioOscuro,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Registrar Toma',
                              style: TextStyle(
                                fontSize: 13,
                                color: _Paleta.tintaSuave,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              medicamentoNombre,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _Paleta.tinta,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _Paleta.cajaInterna,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _Paleta.bordeSuave),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Dosis programada',
                          style: TextStyle(
                            color: _Paleta.tintaSuave,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          dosis,
                          style: const TextStyle(
                            color: _Paleta.primarioOscuro,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: horaSeleccionada,
                      );
                      if (picked != null) {
                        setModalState(() => horaSeleccionada = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              color: _Paleta.primarioOscuro),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hora de administración',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _Paleta.tintaSuave,
                                  ),
                                ),
                                Text(
                                  horaSeleccionada.format(context),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: _Paleta.tinta,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            'Cambiar',
                            style: TextStyle(
                              color: _Paleta.primarioOscuro,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: notasController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Observaciones (Opcional)',
                      hintText: 'Ej. Administrado junto con su alimento',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      prefixIcon: const Icon(Icons.notes_rounded,
                          color: _Paleta.primarioOscuro),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: guardando
                          ? const SizedBox.shrink()
                          : const Icon(Icons.check_circle_outline, size: 20),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _Paleta.primarioOscuro,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: guardando || med.id == null
                          ? null
                          : () async {
                              setModalState(() => guardando = true);

                              final ahora = DateTime.now();
                              final fechaToma = DateTime(
                                ahora.year,
                                ahora.month,
                                ahora.day,
                                horaSeleccionada.hour,
                                horaSeleccionada.minute,
                              );

                              try {
                                final atendio =
                                    await MedicamentoService.registrarToma(
                                  medicamentoId: med.id!,
                                  fechaToma: fechaToma,
                                  notas: notasController.text,
                                );

                                if (!mounted) return;
                                Navigator.pop(sheetContext);
                                _snack(
                                  atendio
                                      ? '¡Toma de $medicamentoNombre registrada! Recordatorio atendido.'
                                      : '¡Toma de $medicamentoNombre registrada con éxito!',
                                  color: _Paleta.primarioOscuro,
                                );
                                _cargarMedicamentos();
                              } catch (e) {
                                if (!mounted) return;
                                setModalState(() => guardando = false);
                                _snack(
                                  e.toString().replaceFirst('Exception: ', ''),
                                  color: Colors.red,
                                );
                              }
                            },
                      label: guardando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Confirmar Toma',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Paleta.fondo,
      appBar: const HeaderAppBar(
        titulo: 'Medicamentos',
        mostrarRegreso: true,
        mostrarLogo: true,
        mostrarNotificaciones: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _tarjetaEncabezado(),
                    const SizedBox(height: 18),

                    const Text(
                      'Selecciona tu mascota',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _Paleta.tinta,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // SELECTOR DE MASCOTAS
                    if (_cargandoMascotas)
                      const Center(child: CircularProgressIndicator())
                    else if (_mascotas.isEmpty)
                      const Text(
                        'Aún no tienes mascotas registradas.',
                        style: TextStyle(color: _Paleta.tintaSuave),
                      )
                    else
                      _selectorMascotas(),

                    const SizedBox(height: 20),

                    if (_seleccionada != null) ...[
                      if (listaMedicamentos.isNotEmpty) ...[
                        _tablaHorarios(),
                        const SizedBox(height: 24),
                      ],

                      // ENCABEZADO + BOTÓN AGREGAR
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tratamientos de ${_seleccionada!.nombrePet}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _Paleta.tinta,
                                  ),
                                ),
                                if (listaMedicamentos.isNotEmpty)
                                  Text(
                                    '${listaMedicamentos.length} ${listaMedicamentos.length == 1 ? 'medicamento registrado' : 'medicamentos registrados'}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: _Paleta.tintaSuave,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _abrirModalAgregar,
                            icon: const Icon(Icons.add_rounded,
                                size: 20, color: Colors.white),
                            label: const Text(
                              'Agregar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _Paleta.primarioOscuro,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _contenidoMedicamentos(),
                    ],
                  ],
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

  // ---------------- TARJETA ENCABEZADO ----------------
  Widget _tarjetaEncabezado() {
    final activos = listaMedicamentos.where((m) => m.esActivo).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F7A70), Color(0xFF3AA69B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F7A70).withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medication_liquid_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Control de Medicamentos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _seleccionada == null
                      ? 'Organiza dosis, frecuencias y horarios.'
                      : activos == 0
                          ? 'Sin tratamientos activos para ${_seleccionada!.nombrePet}.'
                          : 'Tienes $activos ${activos == 1 ? 'tratamiento activo' : 'tratamientos activos'} para ${_seleccionada!.nombrePet}.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- CONTENIDO SEGÚN ESTADO ----------------
  Widget _contenidoMedicamentos() {
    if (cargando) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 36),
        child: Center(
          child: CircularProgressIndicator(color: _Paleta.primarioOscuro),
        ),
      );
    }

    if (errorCarga != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline_rounded,
                size: 38, color: Colors.red.shade400),
            const SizedBox(height: 8),
            Text(
              errorCarga!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _cargarMedicamentos,
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
      );
    }

    if (listaMedicamentos.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: _Paleta.verdeMuyClaro,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medication_outlined,
                size: 36,
                color: _Paleta.primarioOscuro,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '${_seleccionada!.nombrePet} no tiene medicamentos registrados',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _Paleta.tinta,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Registra sus tratamientos para recibir recordatorios puntuales de cada toma.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _Paleta.tintaSuave, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _abrirModalAgregar,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'Agregar primer medicamento',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _Paleta.primarioOscuro,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < listaMedicamentos.length; i++)
          _buildTarjetaMedicamento(listaMedicamentos[i], i),
      ],
    );
  }

  // ---------------- SELECTOR DE MASCOTAS ----------------
  Widget _selectorMascotas() {
    return SizedBox(
      height: 44,
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
            label: 'Ver medicamentos de ${m.nombrePet}',
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => _seleccionarMascota(m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                constraints: const BoxConstraints(minWidth: 105),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: seleccionada ? _Paleta.verdeMuyClaro : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color:
                        seleccionada ? _Paleta.primarioOscuro : _Paleta.borde,
                    width: seleccionada ? 1.8 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pets_rounded,
                      size: 17,
                      color: seleccionada
                          ? _Paleta.primarioOscuro
                          : _Paleta.tintaSuave,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      m.nombrePet,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            seleccionada ? FontWeight.w700 : FontWeight.w500,
                        color: seleccionada
                            ? _Paleta.primarioOscuro
                            : _Paleta.tinta,
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

  // ---------------- TABLA DE HORARIOS ----------------
  List<({DateTime fecha, String nombre})> _proximasDispensaciones() {
    final tomas = <({DateTime fecha, String nombre})>[];

    for (final med in listaMedicamentos) {
      if (!med.esActivo) continue;
      for (final fecha in med.proximasTomas) {
        tomas.add((fecha: fecha.toLocal(), nombre: med.nombre));
      }
    }

    tomas.sort((a, b) => a.fecha.compareTo(b.fecha));
    return tomas.take(5).toList();
  }

  String _etiquetaDia(DateTime fecha) {
    final hoy = DateTime.now();
    final dia = DateTime(fecha.year, fecha.month, fecha.day);
    final diferencia =
        dia.difference(DateTime(hoy.year, hoy.month, hoy.day)).inDays;

    if (diferencia == 0) return 'Hoy';
    if (diferencia == 1) return 'Mañana';

    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(fecha.day)}/${dos(fecha.month)}';
  }

  String _horaAmPm(DateTime fecha) {
    final h = fecha.hour % 12 == 0 ? 12 : fecha.hour % 12;
    final m = fecha.minute.toString().padLeft(2, '0');
    return '$h:$m ${fecha.hour < 12 ? 'am' : 'pm'}';
  }

  Widget _tablaHorarios() {
    final tomas = _proximasDispensaciones();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _Paleta.bordeSuave),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: _Paleta.verdeMuyClaro,
              borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
            ),
            child: const Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 18, color: _Paleta.primarioOscuro),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Próxima Dispensación',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _Paleta.primarioOscuro,
                    ),
                  ),
                ),
                Text(
                  'Horario',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _Paleta.primarioOscuro,
                  ),
                ),
              ],
            ),
          ),
          if (tomas.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                'No hay tomas pendientes en los tratamientos activos.',
                style: TextStyle(fontSize: 13, color: _Paleta.tintaSuave),
              ),
            )
          else
            for (var i = 0; i < tomas.length; i++) ...[
              if (i > 0) Divider(height: 1, color: Colors.grey.shade200),
              _buildRowHorario(
                dia: _etiquetaDia(tomas[i].fecha),
                medicamento: tomas[i].nombre,
                hora: _horaAmPm(tomas[i].fecha),
              ),
            ],
        ],
      ),
    );
  }

  Widget _buildRowHorario({
    required String dia,
    required String medicamento,
    required String hora,
  }) {
    final esHoy = dia == 'Hoy';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: esHoy ? const Color(0xFFE6F6EC) : _Paleta.cajaInterna,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              dia,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: esHoy ? const Color(0xFF2E7D32) : _Paleta.primarioOscuro,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              medicamento,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _Paleta.tinta,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            hora,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: esHoy ? _Paleta.primarioOscuro : _Paleta.tintaSuave,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- TARJETA DE MEDICAMENTO ----------------
  Widget _buildTarjetaMedicamento(Medicamento med, int index) {
    final bool activo = med.esActivo;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: activo ? _Paleta.bordeSuave : Colors.grey.shade200,
        ),
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
          // CABECERA: Ícono + Nombre/Dosis + Estado + Acciones
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: activo
                      ? _Paleta.verdeMuyClaro
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.medication_rounded,
                  color: activo ? _Paleta.primarioOscuro : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _Paleta.tinta,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dosis: ${med.dosis}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _Paleta.primarioOscuro,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: activo
                      ? const Color(0xFFE6F6EC)
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      activo ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      size: 13,
                      color: activo
                          ? const Color(0xFF2E7D32)
                          : Colors.red.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activo ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        fontSize: 12,
                        color: activo
                            ? const Color(0xFF2E7D32)
                            : Colors.red.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _abrirModalEditar(index),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: _Paleta.primarioOscuro,
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _eliminarMedicamento(index),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: Colors.red.shade400,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // CAJA DE DATOS CLAVE (Estilo Desparasitación)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _Paleta.cajaInterna,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _buildDetailItem('Frecuencia', med.frecuencia),
                const SizedBox(height: 6),
                _buildDetailItem('Horarios', med.horaAdministracion),
                if (activo && med.proximaDosis != null) ...[
                  const SizedBox(height: 6),
                  _buildDetailItem(
                    'Próxima dosis',
                    _fmtFechaHora(med.proximaDosis!),
                    destacado: true,
                  ),
                ],
                const SizedBox(height: 6),
                _buildDetailItem(
                  'Vigencia',
                  '${_fmt(med.fechaInicio)} al ${_fmt(med.fechaFinalizacion)}',
                ),
              ],
            ),
          ),

          // DATOS ADICIONALES (Solo si existen)
          if (med.veterinario.isNotEmpty || med.indicaciones.isNotEmpty) ...[
            const SizedBox(height: 12),
            if (med.veterinario.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.medical_services_outlined,
                        size: 15, color: _Paleta.tintaSuave),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Vet: ${med.veterinario}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: _Paleta.tintaSuave,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (med.indicaciones.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.info_outline_rounded,
                        size: 15, color: _Paleta.tintaSuave),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      med.indicaciones,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _Paleta.tintaSuave,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
          ],

          // BOTÓN REGISTRAR TOMA
          if (activo) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _mostrarModalRegistrarToma(med),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 19),
                label: const Text(
                  'Registrar toma',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _Paleta.botonSecundario,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {bool destacado = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: _Paleta.tintaSuave,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: destacado ? FontWeight.bold : FontWeight.w600,
              color: destacado ? _Paleta.primarioOscuro : _Paleta.tinta,
            ),
          ),
        ),
      ],
    );
  }
}

class _Paleta {
  static const Color fondo = Color(0xFFE2F4F1);
  static const Color primarioOscuro = Color(0xFF1F7A70);
  static const Color botonSecundario = Color(0xFF4DB6AC);
  static const Color verdeMuyClaro = Color(0xFFD5F0EB);
  static const Color cajaInterna = Color(0xFFF3FAF8);
  static const Color borde = Color(0xFFB2DFDB);
  static const Color bordeSuave = Color(0xFFD0EBE7);
  static const Color tinta = Color(0xFF1E293B);
  static const Color tintaSuave = Color(0xFF64748B);
}