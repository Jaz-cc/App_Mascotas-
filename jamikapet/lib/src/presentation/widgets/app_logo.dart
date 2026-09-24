import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double width;
  final double height;

  const AppLogo({
    super.key,
    this.width = 172,
    this.height = 172,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),

      padding: const EdgeInsets.all(12),

      child: Image.asset(
        'assets/icons/icon_App.jpg',
        fit: BoxFit.contain,
      ),
    );
  }
}