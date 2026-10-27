import 'package:flutter/material.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';
import 'package:jamikapet/src/presentation/widgets/medicamento_modal.dart';
import 'package:jamikapet/src/models/medicamento.dart';

class MedicamentoPage extends StatefulWidget {
  const MedicamentoPage({super.key});

  @override
  State<MedicamentoPage> createState() => _MedicamentoPageState();
}

class _MedicamentoPageState extends State<MedicamentoPage> {
  // Lista dinámica para almacenar múltiples medicamentos
  List<Map<String, dynamic>> listaMedicamentos = [];

  // AGREGAR UN NUEVO MEDICAMENTO A LA LISTA
  void _abrirModalAgregar() {
    MedicamentoModal.show(
      context,
      esEdicion: false,
      onSave: (datos) {
        setState(() {
          listaMedicamentos.add({
            'nombre': datos['nombre'] ?? 'Medicamento',
            'dosis': datos['dosis'] ?? '',
            'frecuencia': datos['frecuencia'] ?? '',
            'horarios': datos['horarios'] ?? '',
            'inicio': datos['inicio'] ?? '',
            'fin': datos['fin'] ?? '',
            'veterinario': datos['veterinario'] ?? '',
            'indicaciones': datos['indicaciones'] ?? '',
            'esActivo': true,
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Medicamento agregado exitosamente!'),
            backgroundColor: Color(0xFF1F7A70),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  // EDITAR UN MEDICAMENTO ESPECÍFICO DE LA LISTA
  void _abrirModalEditar(int index) {
    final med = listaMedicamentos[index];

    MedicamentoModal.show(
      context,
      esEdicion: true,
      datosIniciales: {
        'nombre': med['nombre'].toString(),
        'dosis': med['dosis'].toString(),
        'frecuencia': med['frecuencia'].toString(),
        'horarios': med['horarios'].toString(),
        'inicio': med['inicio'].toString(),
        'fin': med['fin'].toString(),
        'veterinario': med['veterinario'].toString(),
        'indicaciones': med['indicaciones'].toString(),
      },
      onSave: (datos) {
        setState(() {
          listaMedicamentos[index] = {
            'nombre': datos['nombre'] ?? med['nombre'],
            'dosis': datos['dosis'] ?? med['dosis'],
            'frecuencia': datos['frecuencia'] ?? med['frecuencia'],
            'horarios': datos['horarios'] ?? med['horarios'],
            'inicio': datos['inicio'] ?? med['inicio'],
            'fin': datos['fin'] ?? med['fin'],
            'veterinario': datos['veterinario'] ?? med['veterinario'],
            'indicaciones': datos['indicaciones'] ?? med['indicaciones'],
            'esActivo': med['esActivo'],
          };
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tratamiento actualizado correctamente'),
            backgroundColor: Color(0xFF1F7A70),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  // REGISTRAR TOMA
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

  // EDITAR TRATAMIENTO
  void _mostrarModalEditarTratamiento() {
    
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
              child: SingleChildScrollView(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Editar Tratamiento',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          children: [
                            const Text('Activo', style: TextStyle(fontSize: 13)),
                            Switch(
                              value: activoTemp,
                              activeThumbColor: const Color(0xFF1F7A70),
                              onChanged: (val) {
                                setModalState(() => activoTemp = val);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Divider(height: 16),

                    const SizedBox(height: 8),

                    _buildTextField(nameCtrl, 'Medicamento', Icons.medical_services_outlined),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(dosisCtrl, 'Dosis', Icons.straighten),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(frecCtrl, 'Frecuencia', Icons.repeat),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    _buildTextField(horariosCtrl, 'Horarios de administración', Icons.access_time),
                    
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(inicioCtrl, 'Fecha inicio', Icons.calendar_today),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(finCtrl, 'Fecha fin', Icons.event_available),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildTextField(vetCtrl, 'Veterinario', Icons.person_outline),
                    
                    const SizedBox(height: 12),
                    
                    _buildTextField(indicCtrl, 'Indicaciones', Icons.notes, maxLines: 2),
                    
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                        ),

                        const SizedBox(width: 12),
                        
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F7A70),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                              });

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tratamiento actualizado correctamente'),
                                  backgroundColor: Color(0xFF1F7A70),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: const Text(
                              'Guardar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }

  // ESTRUCTUTRA PRINCIPAL DE LA INTERFAZ
  @override
  Widget build(BuildContext context) {
    const primaryMint = Color(0xFFE2F4F1);
    const darkText = Colors.black87;

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
        children: [ // Contenido de la pantalla
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [                      
                    _tarjetaEncabezado(),
                    const SizedBox(height: 18),  

                    // Tabla de Horarios
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

                    // ENCABEZADO CON BOTÓN AGREGAR
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

                    Container(
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
                              // RENDERIZADO DINÁMICO DE TODOS LOS MEDICAMENTOS DE LA LISTA
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
                          const Divider(height: 20),
                          _buildDetailItem('Dosis:', '1 tableta'),
                          _buildDetailItem('Frecuencia:', 'Cada 8 horas'),
                          _buildDetailItem(
                            'Hora de administración:',
                            '06:00, 14:00, 22:00',
                          ),
                          _buildDetailItem('Fecha de inicio:', '28 - 09 - 2026'),
                          _buildDetailItem('Fecha de finalización:', '05 - 10 - 2026'),
                          _buildDetailItem('Veterinario:', 'Dr. Carlos Mendoza'),
                          _buildDetailItem(
                            'Indicaciones:',
                            'Administrar con alimento para evitar malestar estomacal.',
                          ),
                        ],
                      ),
                    ),
                    
                    
                    const SizedBox(height: 25),

                    // Botones de Acción
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _mostrarModalRegistrarToma,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA8E6CF),
                              foregroundColor: darkText,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFF81C784)),
                              ),
                            ),
                            child: const Text(
                              'Registrar Toma',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _mostrarModalEditarTratamiento,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE0E0E0),
                              foregroundColor: darkText,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFFBDBDBD)),
                              ),
                            ),
                            child: const Text(
                              'Editar',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  
                  ],
                ),                              
              ),
            )
          ),
          
          const SizedBox(height: 12),
          
          // ===============================================================
          // PIE DE PÁGINA / BARRA INFERIOR
          // ===============================================================
          AppBottomNavigation(
            currentIndex: 1,
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

  // ===============================================================
  // ENCABEZADO
  // ===============================================================

  // TARJETA DE CADA MEDICAMENTO
  Widget _buildTarjetaMedicamento(Map<String, dynamic> med, int index) {
    final bool activo = med['esActivo'] ?? true;

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
                med['nombre'].toString(),
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
          _buildDetailItem('Dosis:', med['dosis'].toString()),
          _buildDetailItem('Frecuencia:', med['frecuencia'].toString()),
          _buildDetailItem('Hora de administración:', med['horarios'].toString()),
          _buildDetailItem('Fecha de inicio:', med['inicio'].toString()),
          _buildDetailItem('Fecha de finalización:', med['fin'].toString()),
          _buildDetailItem('Veterinario:', med['veterinario'].toString()),
          _buildDetailItem('Indicaciones:', med['indicaciones'].toString()),
          const SizedBox(height: 14),

          // Botones independientes para cada tarjeta
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _mostrarModalRegistrarToma(
                    med['nombre'].toString(),
                    med['dosis'].toString(),
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
              color: _Paleta.verdeMuyClaro,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medication_outlined,
              color: _Paleta.primarioOscuro,
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
}

class _Paleta {
  static const primarioOscuro = Color(0xFF1F7A70);
  static const verdeMuyClaro = Color(0xFFD1F0EE);
  static const tinta = Color(0xFF16302D);
  static const tintaSuave = Color(0xFF5C7A77);
}
