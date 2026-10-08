import 'package:flutter/material.dart';

  // ===============================================================
  // BARRA INFERIOR
  // ===============================================================
// class AppFooter extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 68,
//       width: double.infinity,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Color(0x140F3D3A),
//             blurRadius: 14,
//             offset: Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _itemBarra(icono: Icons.home_outlined, label: "Inicio", activo: false),
//           _itemBarra(icono: Icons.pets, label: "Mascotas", activo: false),
//           _itemBarra(
//               icono: Icons.person_outline, label: "Perfil", activo: false),
//         ],
//       ),
//     );
//   }

//   Widget _itemBarra({
//     required IconData icono,
//     required String label,
//     required bool activo,
//   }) {
//     final color = activo ? _Paleta.primarioOscuro : _Paleta.tintaSuave;

//     return Semantics(
//       button: true,
//       selected: activo,
//       label: label,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(14),
//         onTap: () {},
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(icono, size: 22, color: color),
//               const SizedBox(height: 3),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 10.5,
//                   fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
//                   color: color,
//                 ),
//               ),
//               const SizedBox(height: 3),
//               Container(
//                 width: 16,
//                 height: 2.5,
//                 decoration: BoxDecoration(
//                   color: activo ? _Paleta.primarioOscuro : Colors.transparent,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


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
            icono: Icons.pets,
            label: 'Mascotas',
            index: 1,
          ),

          _itemBarra(
            icono: Icons.person_outline,
            label: 'Perfil',
            index: 2,
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
                      ? primarioOscuro
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

class _Paleta {
  static const fondo = Color(0xFFE1F5F2);
  static const primario = Color(0xFF55C8BD);
  static const primarioOscuro = Color(0xFF1F7A70);
  static const verdeClaro = Color(0xFFA9DDD8);
  static const verdeMuyClaro = Color(0xFFD1F0EE);
  static const borde = Color(0xFFCBE5E2);
  static const tinta = Color(0xFF16302D);
  static const tintaSuave = Color(0xFF5C7A77);

  static const aplicada = Color(0xFF2E9E5B);
  static const proxima = Color(0xFF2E7BC9);
  static const pendiente = Color(0xFFC94F4F);
}

