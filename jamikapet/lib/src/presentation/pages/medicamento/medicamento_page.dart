import 'package:flutter/material.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';

class MedicamentoPage extends StatefulWidget {
  const MedicamentoPage({super.key});

  @override
  State<MedicamentoPage> createState() => _MedicamentoPageState();
}

class _MedicamentoPageState extends State<MedicamentoPage> {

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
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [                    
                    const SizedBox(height: 20),

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

                    // Ficha Técnica del Tratamiento
                    const Text(
                      'Detalle del Tratamiento',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
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
                              const Text(
                                'Amoxicilina 250mg',
                                style: TextStyle(
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
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Activo',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
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
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('¡Toma de medicamento registrada!'),
                                  backgroundColor: Colors.teal,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
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
                            onPressed: () {},
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
            ),

            // ===============================================================
            // PIE DE PÁGINA / BARRA INFERIOR
            // ===============================================================
            AppBottomNavigation(
              currentIndex: 1,
              onItemSelected: (index) {
                switch (index) {
                  case 0:
                    Navigator.pushReplacementNamed(context, AppRoutes.home,);
                    break;

                  case 1:
                    Navigator.pushReplacementNamed(context, AppRoutes.menu,);
                    break;

                  case 2:
                    Navigator.pushReplacementNamed(context, AppRoutes.petProfile,);
                    break;
                  
                  case 3:
                    Navigator.pushReplacementNamed(context, AppRoutes.perfil,);
                    break;
                }
              },
            ),
          ]
        )
      )
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