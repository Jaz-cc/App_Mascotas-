import 'package:flutter/material.dart';
import 'package:jamikapet/src/presentation/pages/auth/login/login_page.dart';
import 'package:jamikapet/src/presentation/pages/auth/register/register_page.dart';
import 'package:jamikapet/src/presentation/pages/mascotas/registro_mascota.dart';
import 'package:jamikapet/src/presentation/pages/mascotas/pet_page.dart';
import '../pages/home/home_page.dart';
import 'package:jamikapet/src/presentation/pages/vacunas/vacunas.dart';
import 'package:jamikapet/src/presentation/pages/usuario/perfilUsuario_page.dart';
import 'package:jamikapet/src/presentation/pages/menu/menu_page.dart';
import 'package:jamikapet/src/presentation/pages/medicamento/medicamento_page.dart';
import 'package:jamikapet/src/presentation/pages/notificaciones/notificaciones_page.dart';


class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String registro_mascota = '/mascotas/registro';
  static const String home = '/home';
  static const String petProfile = '/mascotas/perfil';
  static const String perfil = '/perfil';
  static const String menu = '/menu';  
  static const String vacunas = '/menu/vacunas';
  static const String medicamentos = '/menu/medicamentos';
  // static const String desparacitacion = '/menu/desparacitantes';  
  // static const String citas = '/menu/citasVeterinarias';
  static const String notificaciones = '/notificaciones';


  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
    registro_mascota: (context) => const RegistroMascotaScreen(),
    home: (context) => const HomePage(),
    petProfile: (context) => const PetProfilePage(),        
    perfil: (context) => const PerfilUsuarioPage(),
    menu: (context) => const MenuPage(),
    vacunas: (context) => const VacunasScreen(),
    medicamentos: (context) => const MedicamentoPage(),
    // desparacitantes: (context) => const DesparacitantesScreen(),
    // citas: (context) => const CitasMedicasScreen(),
    notificaciones: (context) => const NotificacionesPage(),
  };
}
