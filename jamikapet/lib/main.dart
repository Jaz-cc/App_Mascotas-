import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

      // Configuración de idioma
      locale: const Locale('es', 'MX'),

      supportedLocales: const [
        Locale('es', 'MX'),
        Locale('en', 'US'),
      ],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4FC3B8),
        ),
        useMaterial3: true,
      ),

      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
