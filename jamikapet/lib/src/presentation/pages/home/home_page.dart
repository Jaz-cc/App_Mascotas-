import 'package:flutter/material.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/widgets/app_footer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void cerrarSesion(BuildContext context) {
    Navigator.pushReplacementNamed(
      context,
      '/register',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 181, 211, 241),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'JAMIKA PET',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Icon(
                Icons.pets,
                size: 100,
                color: Color(0xFF4FC3B8),
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
                      Navigator.pushReplacementNamed(context, AppRoutes.petProfile,);
                      break;

                    case 2:
                      Navigator.pushReplacementNamed(context, AppRoutes.vacunas,);
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}