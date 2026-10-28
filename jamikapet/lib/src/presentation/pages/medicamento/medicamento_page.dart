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
      final mascotas = await PetsService.obtenerMascotas(); // AJUSTA
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

      if (!mounted || actual != _peticion) return; // respuesta vieja

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
      listaMedicamentos = []; // limpia la lista anterior
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

  void _snack(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
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
            mascotaId: mascotaId, // la mascota seleccionada
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

          // Solo lo agrega si el usuario sigue viendo la misma mascota
          if (_mascotaId == mascotaId) {
            setState(() => listaMedicamentos.add(guardado));
          }

          _snack('Medicamento guardado.', color: const Color(0xFF1F7A70));
        } catch (e) {
          if (!mounted) return;
          _snack('No se pudo guardar: $e');
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
              color: const Color(0xFF1F7A70));
        } catch (e) {
          if (!mounted) return;
          _snack('No se pudo actualizar: $e');
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
        title: const Text('Eliminar medicamento'),
        content: Text('¿Deseas eliminar "${med.nombre}"?'),
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
      await MedicamentoService.eliminarMedicamento(med.id!);
      if (!mounted) return;
      setState(() => listaMedicamentos.removeAt(index));
      _snack('Medicamento eliminado correctamente.');
    } catch (e) {
      if (!mounted) return;
      _snack('No se pudo eliminar: $e');
    }
  }

  // ---------------- REGISTRAR TOMA ----------------
  void _mostrarModalRegistrarToma(String medicamentoNombre, String dosis) {
    final notasController = TextEditingController();
    TimeOfDay horaSeleccionada = TimeOfDay.now();

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
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.medication,
                          color: _Paleta.primarioOscuro, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Registrar Toma de $medicamentoNombre',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _Paleta.verdeMuyClaro,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Dosis programada:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          dosis,
                          style: const TextStyle(
                            color: _Paleta.primarioOscuro,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.access_time, color: Colors.teal),
                    title: const Text('Hora de administración'),
                    subtitle: Text(horaSeleccionada.format(context)),
                    trailing: TextButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: horaSeleccionada,
                        );
                        if (picked != null) {
                          setModalState(() => horaSeleccionada = picked);
                        }
                      },
                      child: const Text('Cambiar'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: notasController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Observaciones (Opcional)',
                      hintText: 'Ej. Administrado con comida',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.notes),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA8E6CF),
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFF81C784)),
                        ),
                      ),
                      onPressed: () {
                        // Guardar la toma en el backend
                        Navigator.pop(sheetContext);
                        _snack(
                          '¡Toma de $medicamentoNombre registrada con éxito!',
                          color: _Paleta.primarioOscuro,
                        );
                      },
                      child: const Text(
                        'Confirmar Toma',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(notasController.dispose);
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    const primaryMint = Color(0xFFE2F4F1);

    return Scaffold(
      backgroundColor: primaryMint,
      appBar: const HeaderAppBar(
        titulo: 'Medicamentos',
        mostrarRegreso: true,
        mostrarLogo: true,
        mostrarNotificaciones: true,
        icon: Icons.medication_outlined,
      ),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _tarjetaEncabezado(),
                    const SizedBox(height: 16),

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

                    const SizedBox(height: 18),

                    if (_seleccionada != null) ...[
                      // Calcular estos horarios desde los medicamentos reales
                      if (listaMedicamentos.isNotEmpty) ...[
                        _tablaHorarios(),
                        const SizedBox(height: 25),
                      ],

                      // ENCABEZADO + BOTÓN AGREGAR
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Tratamiento de ${_seleccionada!.nombrePet}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _abrirModalAgregar,
                            icon: const Icon(Icons.add,
                                size: 18, color: Colors.white),
                            label: const Text(
                              'Agregar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _Paleta.primarioOscuro,
                              elevation: 1,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _contenidoMedicamentos(),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
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

  // ---------------- CONTENIDO SEGÚN ESTADO ----------------
  Widget _contenidoMedicamentos() {
    if (cargando) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorCarga != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(errorCarga!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _cargarMedicamentos,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (listaMedicamentos.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Icon(Icons.medication_outlined,
                size: 40, color: _Paleta.primarioOscuro),
            const SizedBox(height: 10),
            Text(
              '${_seleccionada!.nombrePet} no tiene medicamentos registrados.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _Paleta.tintaSuave, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _abrirModalAgregar,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Agregar el primero',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _Paleta.primarioOscuro,
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
            label: 'Ver medicamentos de ${m.nombrePet}',
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.pets,
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

  // ---------------- TABLA DE HORARIOS (datos de ejemplo) ----------------
  Widget _tablaHorarios() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFDDF3EC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFB2DFDB)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFC7EAE1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Próxima Dispensación',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('Horario',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
          _buildRow('Hoy', '2:00 pm', isHighlight: true),
          const Divider(height: 1, color: Color(0xFFB2DFDB)),
          _buildRow('Hoy', '10:00 pm', isHighlight: true),
          const Divider(height: 1, color: Color(0xFFB2DFDB)),
          _buildRow('Mañana', '6:00 am', isHighlight: false),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  med.nombre,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: activo ? const Color(0xFFE8F5E9) : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  activo ? 'Activo' : 'Inactivo',
                  style: TextStyle(
                    fontSize: 12,
                    color: activo ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildDetailItem('Dosis:', med.dosis),
          _buildDetailItem('Frecuencia:', med.frecuencia),
          _buildDetailItem('Hora de administración:', med.horaAdministracion),
          _buildDetailItem('Fecha de inicio:', _fmt(med.fechaInicio)),
          _buildDetailItem('Fecha de finalización:', _fmt(med.fechaFinalizacion)),
          _buildDetailItem('Veterinario:', med.veterinario),
          _buildDetailItem('Indicaciones:', med.indicaciones),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      _mostrarModalRegistrarToma(med.nombre, med.dosis),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA8E6CF),
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFF81C784)),
                    ),
                  ),
                  child: const Text('Registrar Toma',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _abrirModalEditar(index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0E0E0),
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFBDBDBD)),
                    ),
                  ),
                  child: const Text('Editar',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Eliminar',
                onPressed: () => _eliminarMedicamento(index),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- ENCABEZADO ----------------
  Widget _tarjetaEncabezado() {
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
            child: const Icon(Icons.medication_outlined,
                color: _Paleta.primarioOscuro, size: 27),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medicamentos',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _Paleta.tinta,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Consulta y administra los medicamentos de tu mascota de forma fácil y organizada.',
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

  Widget _buildRow(String day, String time, {required bool isHighlight}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          Text(
            time,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Colors.teal.shade800 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          children: [
            TextSpan(
              text: '$title ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _Paleta {
  static const primarioOscuro = Color(0xFF1F7A70);
  static const verdeMuyClaro = Color(0xFFD1F0EE);
  static const tinta = Color(0xFF16302D);
  static const tintaSuave = Color(0xFF5C7A77);
  static const borde = Color(0xFFB2DFDB); // faltaba en tu archivo
}