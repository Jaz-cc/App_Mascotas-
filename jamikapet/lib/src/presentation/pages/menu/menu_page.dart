import 'package:flutter/material.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';
import 'package:jamikapet/src/presentation/pages/medicamento/medicamento_page.dart';
import 'package:jamikapet/src/presentation/pages/usuario/perfilUsuario_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    const primaryBackground = Color(0xFFE2F4F1);
    const darkText = Colors.black87;

    return Scaffold(
      backgroundColor: primaryBackground,
      appBar: const HeaderAppBar(
        titulo: 'Menu',
        mostrarLogo: true,
        mostrarRegreso: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 140,
                        height: 120,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                size: 80,
                                color: Colors.teal.shade400,
                              ),
                              const Icon(
                                Icons.pets,
                                size: 38,
                                color: Colors.teal,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pets, size: 28, color: darkText),
                        SizedBox(width: 8),
                        Text(
                          'Salud',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),

                    //VACUNAS
                    _buildMenuOption(
                      icon: Icons.clean_hands_outlined,
                      title: 'Vacunas',
                      onTap: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.vacunas);
                      },
                    ),

                    const SizedBox(height: 12),
                    
                    //DESPARASITACIÓN
                    _buildMenuOption(
                      icon: Icons.bug_report_outlined,
                      title: 'Desparasitación',
                      onTap: () {
                        //Navigator.pushReplacementNamed(context, AppRoutes.desparasitacion);
                      },
                    ),

                    const SizedBox(height: 12),

                    //MEDICAMENTOS 
                    _buildMenuOption(
                      icon: Icons.medication_outlined,
                      title: 'Medicamentos',
                      onTap: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.medicamentos);
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildMenuOption(
                      icon: Icons.event_available_outlined,
                      title: 'Citas Veterinarias',
                      onTap: () {
                        //Navigator.pushReplacementNamed(context, AppRoutes.citas);
                      },
                    ),
                    
                    const SizedBox(height: 20),
                  
                  ]
                )
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
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFB2DFDB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: Colors.teal.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF80CBC4),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

}

