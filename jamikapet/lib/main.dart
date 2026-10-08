
import 'package:flutter/material.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';

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

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4FC3B8),
        ),
        useMaterial3: true,
      ),

      initialRoute: AppRoutes.vacunas,
      routes: AppRoutes.routes,
    );
  }
}
