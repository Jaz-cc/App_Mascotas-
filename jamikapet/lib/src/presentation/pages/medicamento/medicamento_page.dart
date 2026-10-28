import 'package:flutter/material.dart';
import 'package:jamikapet/src/models/medicamento.dart';
import 'package:jamikapet/src/services/medicamento_service.dart';
import 'package:jamikapet/src/presentation/pages/menu/menu_page.dart';
import 'package:jamikapet/src/presentation/pages/usuario/perfilUsuario_page.dart';
import 'package:jamikapet/src/presentation/pages/IAchat/ia_chat_page.dart';
import 'package:jamikapet/src/presentation/widgets/medicamento_modal.dart';

class MedicamentoPage extends StatefulWidget {
  const MedicamentoPage({super.key});

  @override
  State<MedicamentoPage> createState() => _MedicamentoPageState();
}

class _MedicamentoPageState extends State<MedicamentoPage> {
  int _selectedIndex = 1;
  bool _cargando = true;
  List<Medicamento> listaMedicamentos = [];

  @override
  void initState() {
    super.initState();
    _cargarMedicamentos();
  }

  Future<void> _cargarMedicamentos() async {
    setState(() => _cargando = true);
    try {
      final medicamentos = await MedicamentoService.obtenerMedicamentos();
      setState(() {
        listaMedicamentos = medicamentos;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar medicamentos: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MenuPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PerfilUsuarioPage()),
      );
    } else if (index == 0) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  void _abrirModalAgregar() {
    MedicamentoModal.show(
      context,
      esEdicion: false,
      onSave: (datos) async {
        final nuevo = Medicamento(
          mascotaId: '1',
          nombre: datos['nombre'] ?? '',
          dosis: datos['dosis'] ?? '',
          frecuencia: datos['frecuencia'] ?? '',
          horaAdministracion: datos['horarios'] ?? '',
          fechaInicio: DateTime.tryParse(datos['inicio'] ?? '') ?? DateTime.now(),
          fechaFinalizacion: DateTime.tryParse(datos['fin'] ?? '') ?? DateTime.now(),
          indicaciones: datos['indicaciones'] ?? '',
          veterinario: datos['veterinario'] ?? '',
        );

        try {
          await MedicamentoService.registrarMedicamento(nuevo);
          _cargarMedicamentos();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Medicamento agregado exitosamente!'),
              backgroundColor: Color(0xFF1F7A70),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al registrar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

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
        final editado = Medicamento(
          id: med.id,
          mascotaId: med.mascotaId,
          nombre: datos['nombre'] ?? med.nombre,
          dosis: datos['dosis'] ?? med.dosis,
          frecuencia: datos['frecuencia'] ?? med.frecuencia,
          horaAdministracion: datos['horarios'] ?? med.horaAdministracion,
          fechaInicio: DateTime.tryParse(datos['inicio'] ?? '') ?? med.fechaInicio,
          fechaFinalizacion: DateTime.tryParse(datos['fin'] ?? '') ?? med.fechaFinalizacion,
          indicaciones: datos['indicaciones'] ?? med.indicaciones,
          veterinario: datos['veterinario'] ?? med.veterinario,
        );

        try {
          await MedicamentoService.actualizarMedicamento(editado);
          _cargarMedicamentos();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tratamiento actualizado correctamente'),
              backgroundColor: Color(0xFF1F7A70),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  void _mostrarModalRegistrarToma(String medicamentoNombre, String dosis) {
    final TextEditingController notasController = TextEditingController();
    TimeOfDay horaSeleccionada = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
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
                      const Icon(Icons.medication, color: Color(0xFF1F7A70), size: 28),
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
                      color: const Color(0xFFD1F0EE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Dosis programada:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          dosis,
                          style: const TextStyle(
                            color: Color(0xFF1F7A70),
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
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: horaSeleccionada,
                        );
                        if (picked != null) {
                          setModalState(() {
                            horaSeleccionada = picked;
                          });
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
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '¡Toma de $medicamentoNombre registrada con éxito!',
                            ),
                            backgroundColor: const Color(0xFF1F7A70),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text(
                        'Confirmar Toma',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  @override
  Widget build(BuildContext context) {
    const primaryMint = Color(0xFFE2F4F1);
    const headerMint = Color(0xFFC5ECE5);
    const darkText = Colors.black87;

    return Scaffold(
      backgroundColor: primaryMint,
      appBar: AppBar(
        backgroundColor: headerMint,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: darkText),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        centerTitle: true,
        title: const Text(
          'Medicamentos',
          style: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF1F7A70)))
            : RefreshIndicator(
                onRefresh: _cargarMedicamentos,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _tarjetaEncabezado(),
                      const SizedBox(height: 18),

                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDF3EC),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFFB2DFDB)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFFC7EAE1),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(14),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Próxima Dispensación',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    'Horario',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
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
                      ),
                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Detalle del Tratamiento',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkText,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _abrirModalAgregar,
                            icon: const Icon(Icons.add, size: 18, color: Colors.white),
                            label: const Text(
                              'Agregar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F7A70),
                              elevation: 1,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (listaMedicamentos.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'No hay medicamentos registrados.',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ),
                        )
                      else
                        ...listaMedicamentos.asMap().entries.map((entry) {
                          final index = entry.key;
                          final med = entry.value;

                          return _buildTarjetaMedicamento(med, index);
                        }),
                    ],
                  ),
                ),
              ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1F7A70),
        elevation: 4,
        tooltip: 'Asistente IA',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatIaPage(),
            ),
          );
        },
        child: const Icon(
          Icons.smart_toy_outlined,
          color: Colors.white,
          size: 28,
        ),
      ),

      bottomNavigationBar: _buildStandardBottomNavigationBar(),
    );
  }

  Widget _buildTarjetaMedicamento(Medicamento med, int index) {
    return Container(
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
              Text(
                med.nombre,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: med.esActivo ? const Color(0xFFE8F5E9) : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  med.esActivo ? 'Activo' : 'Inactivo',
                  style: TextStyle(
                    fontSize: 12,
                    color: med.esActivo ? Colors.green : Colors.red,
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
          _buildDetailItem('Fecha de inicio:', med.fechaInicio.toIso8601String().split('T').first),
          _buildDetailItem('Fecha de finalización:', med.fechaFinalizacion.toIso8601String().split('T').first),
          _buildDetailItem('Veterinario:', med.veterinario),
          _buildDetailItem('Indicaciones:', med.indicaciones),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _mostrarModalRegistrarToma(
                    med.nombre,
                    med.dosis,
                  ),
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
                  child: const Text(
                    'Registrar Toma',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                  child: const Text(
                    'Editar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
              color: Color(0xFFD1F0EE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medication_outlined,
              color: Color(0xFF1F7A70),
              size: 27,
            ),
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
                    color: Color(0xFF16302D),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Consulta y administra los medicamentos de tu mascota de forma fácil y organizada.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Color(0xFF5C7A77),
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
          Text(
            day,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
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

  Widget _buildStandardBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE2F4F1),
        border: Border(top: BorderSide(color: Color(0xFFB2DFDB), width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFFE2F4F1),
        selectedItemColor: const Color(0xFF00695C),
        unselectedItemColor: const Color(0xFF616161),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 26,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            activeIcon: Icon(Icons.pets),
            label: 'Mascotas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}