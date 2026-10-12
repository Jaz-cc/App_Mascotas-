import 'package:flutter/material.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';  
import 'package:jamikapet/src/presentation/pages/menu/menu_page.dart';

class PerfilUsuarioPage extends StatefulWidget {
  const PerfilUsuarioPage({super.key});

  @override
  State<PerfilUsuarioPage> createState() => _PerfilUsuarioPageState();
}

class _PerfilUsuarioPageState extends State<PerfilUsuarioPage> {

  void cerrarSesion(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    const primaryBackground = Color(0xFFE2F4F1);
    const darkText = Colors.black87;

    return Scaffold(
      backgroundColor: primaryBackground,
      appBar: const HeaderAppBar(
        titulo: 'Perfil de usuario',
        mostrarLogo: true,
        mostrarRegreso: false,
      ),
      body: SafeArea(
        child: Column(
          children: [                         
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    Center(
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: const BoxDecoration(
                          color: Color(0xFF007A8C),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    _buildInfoTile(label: 'Nombre:', value: 'Usuario12'),

                    const SizedBox(height: 16),

                    _buildInfoTile(label: 'Correo:', value: 'usuario12@gmail.com'),

                    const SizedBox(height: 30),

                    const Text(
                      'Mascota:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 12),

                    InkWell(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.menu,);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFB2DFDB)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.pets,
                                size: 36,
                                color: Colors.orangeAccent,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              'Perro',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: darkText,
                              ),
                            ),         
                          ],
                        ),
                      ),
                    ), 

                    const SizedBox(height: 12),
                    
                    // ===============================================================
                    // BOTON CIERRE DE SESIÓN
                    // ===============================================================
                    SizedBox(
                      width: 250,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          cerrarSesion(context);
                        },
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
                          backgroundColor: const Color(0xFF4FC3B8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),           
                  ],
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

  Widget _buildInfoTile({required String label, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
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