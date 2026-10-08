import 'package:flutter/material.dart';
import 'package:jamikapet/src/presentation/pages/auth/login/login_page.dart';
import 'package:jamikapet/src/presentation/pages/auth/register/register_page.dart';
import 'package:jamikapet/src/presentation/pages/mascotas/registro_mascota.dart';
import 'package:jamikapet/src/presentation/pages/mascotas/pet_page.dart';
import '../pages/home/home_page.dart';
import 'package:jamikapet/src/presentation/pages/vacunas/vacunas.dart';


class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String registro_mascota = '/mascotas/registro';
  static const String petProfile = '/mascotas/perfil';
  static const String home = '/home';
  static const String vacunas = '/vacunas';
  //static const String perfil = '/perfil';

  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginPage(),
        register: (context) => const RegisterPage(),
        registro_mascota: (context) => const RegistroMascotaScreen(),
        petProfile: (context) => const PetProfilePage(),
        home: (context) => const HomePage(),
        vacunas: (context) => const VacunasScreen(),
      };
}
