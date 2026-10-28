import 'package:flutter/material.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';

class CitasVeterinariasPage extends StatefulWidget {
  const CitasVeterinariasPage({super.key});

  @override
  State<CitasVeterinariasPage> createState() => _CitasVeterinariasPageState();
}

class _CitasVeterinariasPageState extends State<CitasVeterinariasPage> {
  bool _notificacionActiva = true;

  // Diálogo para registrar una nueva cita o veterinario
  void _mostrarDialogoNuevaCita() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
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
              const Text(
                'Registrar Cita / Veterinario',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nombre del Veterinario',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Clínica Veterinaria',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.local_hospital_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Motivo de Consulta',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.medical_information_outlined),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Fecha y Hora',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00695C),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Cita registrada correctamente!'),
                        backgroundColor: Color(0xFF00695C),
                      ),
                    );
                  },
                  child: const Text(
                    'Guardar Cita',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBackground = Color(0xFFE2F4F1);
    const darkText = Colors.black87;

    return Scaffold(
      backgroundColor: primaryBackground,
      appBar: const HeaderAppBar(
        titulo: 'Citas',
        mostrarRegreso: true,
        mostrarLogo: true,
        mostrarNotificaciones: true,
      ),
      body: Column(
        children: [
          // Contenido de la pantalla
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [                    
                    _tarjetaEncabezado(),
                    const SizedBox(height: 18),
                    // Seccion: Próxima Cita & Notificaciones
                    const Text(
                      'Próxima Cita',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFB2DFDB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
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
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F2F1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.event, color: Color(0xFF00695C)),
                                  ),
                                  const SizedBox(width: 10),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '15 de Octubre, 2026',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        '10:30 AM',
                                        style: TextStyle(color: Colors.black54, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Control de Notificaciones
                              Row(
                                children: [
                                  const Icon(Icons.notifications_active_outlined,
                                      size: 20, color: Colors.teal),
                                  Switch(
                                    value: _notificacionActiva,
                                    activeThumbColor: const Color(0xFF00695C),
                                    onChanged: (val) {
                                      setState(() => _notificacionActiva = val);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildDetailRow('Veterinario:', 'Dr. Carlos Mendoza'),
                          _buildDetailRow('Clínica:', 'Veterinaria Mascotas Sanas'),
                          _buildDetailRow('Motivo:', 'Chequeo General y Control de Peso'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Botón Registrar Nueva Cita / Veterinario
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _mostrarDialogoNuevaCita,
                        icon: const Icon(Icons.add_circle_outline, color: darkText),
                        label: const Text(
                          'Registrar Nueva Cita / Veterinario',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: darkText,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA8E6CF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(color: Color(0xFF81C784)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Sección: Historial de Citas y Notas Posteriores
                    const Text(
                      'Historial de Citas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildHistorialCard(
                      fecha: '20 Sep 2026 - 04:00 PM',
                      veterinario: 'Dra. María Fernández',
                      clinica: 'Hospital Veterinario Central',
                      motivo: 'Vacunación Anual',
                      notas: 'Mascota en excelente estado. Aplicada vacuna sextuple. Se sugiere control en 1 mes.',
                    ),
                    const SizedBox(height: 12),

                    _buildHistorialCard(
                      fecha: '05 Jun 2026 - 11:00 AM',
                      veterinario: 'Dr. Carlos Mendoza',
                      clinica: 'Veterinaria Mascotas Sanas',
                      motivo: 'Limpieza Dental',
                      notas: 'Procedimiento exitoso. Se formuló enjuague bucal antiséptico por 5 días.',
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
              Icons.medical_information_outlined,
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
                  'Citas Veterinarias',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _Paleta.tinta,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Agenda y organiza las citas veterinarias para cuidar la salud de tu mascota.',
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorialCard({
    required String fecha,
    required String veterinario,
    required String clinica,
    required String motivo,
    required String notas,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB2DFDB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                fecha,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00695C),
                  fontSize: 14,
                ),
              ),
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
            ],
          ),
          const Divider(height: 16),
          _buildDetailRow('Veterinario:', veterinario),
          _buildDetailRow('Clínica:', clinica),
          _buildDetailRow('Motivo:', motivo),
          const SizedBox(height: 8),
          
          // Notas Posteriores a la Consulta
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.notes, size: 18, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Notas: $notas',
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
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