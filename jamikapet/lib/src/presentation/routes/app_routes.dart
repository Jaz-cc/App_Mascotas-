import 'package:flutter/material.dart';
import 'package:jamikapet/src/presentation/pages/auth/login/login_page.dart';
import 'package:jamikapet/src/presentation/pages/auth/register/register_page.dart';
import 'package:jamikapet/src/presentation/pages/mascotas/registro_mascota.dart';
import 'package:jamikapet/src/presentation/pages/mascotas/pet_page.dart';
import '../pages/home/home_page.dart';
import 'package:jamikapet/src/presentation/pages/vacunas/vacunas_page.dart';
import 'package:jamikapet/src/presentation/pages/usuario/perfil_usuario_page.dart';
import 'package:jamikapet/src/presentation/pages/mascotas/pet_profile_page.dart';
import 'package:jamikapet/src/presentation/pages/menu/menu_page.dart';
import 'package:jamikapet/src/presentation/pages/medicamento/medicamento_page.dart';
import 'package:jamikapet/src/presentation/pages/notificaciones/notificaciones_page.dart';
import 'package:jamikapet/src/presentation/pages/citas/citas_veterinarias_page.dart';
import 'package:jamikapet/src/presentation/pages/desparacitacion/desparacitacion_page.dart';
import 'package:jamikapet/src/presentation/pages/IAchat/ia_chat_page.dart';


class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String registroPet = '/perfil/registro_pet';
  static const String home = '/home';
  static const String pets = '/mascotas';
  static const String petProfile = '/mascotas/perfil';
  static const String perfil = '/perfil';
  static const String menu = '/menu';  
  static const String vacunas = '/menu/vacunas';
  static const String medicamentos = '/menu/medicamentos';
  static const String desparacitacion = '/menu/desparacitantes';  
  static const String citas = '/menu/citas_veterinarias';
  static const String notificaciones = '/notificaciones';
  static const String chatIA = '/jamika_chatIA';


  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
    registroPet: (context) => const RegistroMascotaScreen(),
    home: (context) => const HomePage(),
    pets: (context) => const PetPage(),
    petProfile: (context) {
      final mascotaId = ModalRoute.of(context)!.settings.arguments as int;

      return PetProfilePage(
        mascotaId: mascotaId,
      );
    },       
    perfil: (context) => const PerfilUsuarioPage(),
    menu: (context) => const MenuPage(),
    vacunas: (context) => const VacunasScreen(),
    medicamentos: (context) => const MedicamentoPage(),
    desparacitacion: (context) => const DewormingPage(),
    citas: (context) => const CitasVeterinariasPage(),
    notificaciones: (context) => const NotificacionesPage(),
    chatIA:(context) => const ChatIaPage()
  };
}
