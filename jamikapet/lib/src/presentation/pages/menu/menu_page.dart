import 'package:flutter/material.dart';
import 'package:jamikapet/src/presentation/pages/medicamento/medicamento_page.dart';
import 'package:jamikapet/src/presentation/pages/usuario/perfilUsuario_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final int _selectedIndex = 1; // Índice 1 es Mascotas / Salud

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // Si ya estamos aquí, no hace nada

    if (index == 2) {
      // Ir al Perfil de Usuario
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PerfilUsuarioPage()),
      );
    } else if (index == 0) {
      // Ir al Inicio
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBackground = Color(0xFFE2F4F1);
    const headerColor = Color(0xFFC5ECE5);
    const darkText = Colors.black87;

    return Scaffold(
      backgroundColor: primaryBackground,
      appBar: AppBar(
        backgroundColor: headerColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: darkText),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
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
              const SizedBox(height: 24),
              _buildMenuOption(
                icon: Icons.assignment_outlined,
                title: 'Informacion General',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildMenuOption(
                icon: Icons.clean_hands_outlined,
                title: 'Vacunas',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildMenuOption(
                icon: Icons.bug_report_outlined,
                title: 'Desparasitación',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildMenuOption(
                icon: Icons.medication_outlined,
                title: 'Medicamentos',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MedicamentoPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildMenuOption(
                icon: Icons.event_available_outlined,
                title: 'Citas Veterinarias',
                onTap: () {},
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildStandardBottomNavigationBar(),
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