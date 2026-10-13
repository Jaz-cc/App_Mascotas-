import 'package:flutter/material.dart';

// ===============================================================
// BARRA INFERIOR
// ===============================================================
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  static const Color primarioOscuro = Color(0xFF1F7A70);
  static const Color tintaSuave = Color(0xFF5C7A77);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x140F3D3A),
            blurRadius: 14,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _itemBarra(
            icono: Icons.home_outlined,
            label: 'Inicio',
            index: 0,
          ),
          
          _itemBarra(
            icono: Icons.menu,
            label: 'Menú',
            index: 1,
          ),

          _itemBarra(
            icono: Icons.pets,
            label: 'Mascotas',
            index: 2,
          ),

          _itemBarra(
            icono: Icons.person_outline,
            label: 'Perfil',
            index: 3,
          ),
        ],
      ),
    );
  }

  Widget _itemBarra({
    required IconData icono,
    required String label,
    required int index,
  }) {
    final bool activo = currentIndex == index;

    final Color color =
        activo ? primarioOscuro : tintaSuave;

    return Semantics(
      button: true,
      selected: activo,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onItemSelected(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icono,
                size: 22,
                color: color,
              ),

              const SizedBox(height: 3),

              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight:
                      activo ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),

              const SizedBox(height: 3),

              Container(
                width: 16,
                height: 2.5,
                decoration: BoxDecoration(
                  color: activo
                      ? const Color.fromARGB(255, 31, 42, 122)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


