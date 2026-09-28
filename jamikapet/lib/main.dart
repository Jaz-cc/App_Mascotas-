import 'package:flutter/material.dart';
import 'package:jamikapet/src/presentation/pages/auth/register/register_page.dart';
import 'package:jamikapet/src/presentation/pages/home/home_page.dart';

void main() {
  runApp(const JamikaPetApp());
}

class JamikaPetApp extends StatelessWidget {
  const JamikaPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JAMIKA PET',
      debugShowCheckedModeBanner: false,

      // Tema de la aplicación
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4FC3B8),
        ),
        useMaterial3: true,
      ),

      // Pantalla inicial
      home: const RegisterPage(),
    );
  }
}

