import 'package:flutter/material.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_barra_superior.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';
import 'package:jamikapet/src/presentation/widgets/app_logo.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE2F4F1),
      appBar: const HeaderAppBar(
        titulo: 'Inicio',
        mostrarLogo: true,
        mostrarRegreso: false,
        icon: Icons.home_outlined,        
      ),
      body: Column(
        children: [
          // Contenido de la pantalla
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // ===========================================
                    // LOGO
                    // ===========================================
                    const AppLogo(
                      width: 250,
                      height: 250,
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      '¡Bienvenido a JAMIKA PET!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Todo lo que necesitas para cuidar y mantener '
                      'el bienestar de tu mascota.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),

          // ===============================================================
          // PIE DE PÁGINA / BARRA INFERIOR
          // ===============================================================
          AppBottomNavigation(
            currentIndex: 0,
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
}