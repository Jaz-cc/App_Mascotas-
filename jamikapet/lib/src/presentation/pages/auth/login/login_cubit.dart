import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jamikapet/src/services/auth_service.dart';
import 'package:jamikapet/src/core/storage/token_storage.dart';

// ============================================================
// ESTADOS
// ============================================================

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final Map<String, dynamic> user;
  final String token;
  final String message;

  LoginSuccess({
    required this.user,
    required this.token,
    required this.message,
  });
}

class LoginFailure extends LoginState {
  /// Mensaje general (siempre presente).
  final String errorMessage;

  /// Errores por campo (solo cuando el problema está en un campo concreto).
  final String? emailError;
  final String? passwordError;

  LoginFailure({
    required this.errorMessage,
    this.emailError,
    this.passwordError,
  });

  /// true cuando el error pertenece a un campo y no es un error general.
  bool get esDeCampo => emailError != null || passwordError != null;
}

// ============================================================
// CUBIT
// ============================================================

class LoginCubit extends Cubit<LoginState> {
  final AuthService _authService;

  LoginCubit({AuthService? authService})
      : _authService = authService ?? AuthService(),
        super(LoginInitial());

  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  /// Quita los errores en pantalla (por ejemplo, cuando el usuario escribe).
  void limpiarError() {
    if (state is LoginFailure) emit(LoginInitial());
  }

  Future<void> login(
    String email,
    String password,
  ) async {
    // ----------------------------------------------------------
    // VALIDACIÓN POR CAMPO
    // ----------------------------------------------------------
    final correo = email.trim();
    String? errorEmail;
    String? errorPassword;

    if (correo.isEmpty) {
      errorEmail = 'Ingresa tu e-mail.';
    } else if (!_emailRegex.hasMatch(correo)) {
      errorEmail = 'Escribe un e-mail válido (ej. nombre@correo.com).';
    }

    if (password.isEmpty) {
      errorPassword = 'Ingresa tu contraseña.';
    }

    if (errorEmail != null || errorPassword != null) {
      emit(
        LoginFailure(
          errorMessage: 'Revisa los campos marcados.',
          emailError: errorEmail,
          passwordError: errorPassword,
        ),
      );
      return;
    }

    emit(LoginLoading());

    try {
      final response = await _authService
          .iniciarSesion(
            email: correo,
            password: password,
          )
          .timeout(const Duration(seconds: 20));

      // Obtener usuario y token de la respuesta de NestJS.
      final dynamic userData = response['user'] ?? response['usuario'];

      final dynamic tokenData = response['token'] ?? response['access_token'];

      if (userData is! Map ||
          tokenData is! String ||
          tokenData.trim().isEmpty) {
        throw const AuthException(
          'La respuesta del servidor no contiene el usuario '
          'y el token de autenticación.',
        );
      }

      final user = Map<String, dynamic>.from(userData);
      final token = tokenData;

      // Guardar token y datos del usuario.
      await TokenStorage.saveToken(token);
      await TokenStorage.saveUser(user);

      emit(
        LoginSuccess(
          user: user,
          token: token,
          message: response['message']?.toString() ??
              'Inicio de sesión exitoso.',
        ),
      );
    } on AuthException catch (e) {
      emit(_desdeMensajeDelServidor(e.mensaje));
    } on TimeoutException {
      emit(
        LoginFailure(
          errorMessage: 'El servidor tardó demasiado en responder. '
              'Revisa tu conexión e inténtalo de nuevo.',
        ),
      );
    } catch (e) {
      emit(LoginFailure(errorMessage: _mensajeDeRed(e)));
    }
  }

  // ----------------------------------------------------------
  // Convierte el mensaje del servidor en un error claro.
  // ----------------------------------------------------------
  LoginFailure _desdeMensajeDelServidor(String mensaje) {
    final texto = mensaje.toLowerCase();

    // Credenciales incorrectas
    if (texto.contains('credencial') ||
        texto.contains('invalid') ||
        texto.contains('incorrect') ||
        texto.contains('unauthorized') ||
        texto.contains('contraseña')) {
      return LoginFailure(
        errorMessage: 'El e-mail o la contraseña son incorrectos. '
            'Verifica tus datos e inténtalo de nuevo.',
        passwordError: 'Verifica tu contraseña.',
      );
    }

    // Cuenta inexistente
    if (texto.contains('no existe') ||
        texto.contains('no encontr') ||
        texto.contains('not found')) {
      return LoginFailure(
        errorMessage: 'No encontramos una cuenta con ese e-mail.',
        emailError: 'No hay una cuenta con este e-mail.',
      );
    }

    // Cuenta bloqueada / desactivada
    if (texto.contains('bloquead') ||
        texto.contains('desactivad') ||
        texto.contains('inactiv') ||
        texto.contains('suspendid')) {
      return LoginFailure(
        errorMessage: 'Tu cuenta no está activa. Contacta a soporte.',
      );
    }

    // Cualquier otro mensaje del servidor se muestra tal cual.
    return LoginFailure(errorMessage: mensaje);
  }

  // ----------------------------------------------------------
  // Errores de red / inesperados
  // ----------------------------------------------------------
  String _mensajeDeRed(Object e) {
    final texto = e.toString().toLowerCase();

    if (texto.contains('socketexception') ||
        texto.contains('failed host lookup') ||
        texto.contains('clientexception') ||
        texto.contains('connection refused') ||
        texto.contains('network')) {
      return 'No hay conexión con el servidor. '
          'Revisa tu internet e inténtalo de nuevo.';
    }

    if (texto.contains('formatexception')) {
      return 'El servidor respondió de forma inesperada. '
          'Inténtalo más tarde.';
    }

    return 'No fue posible iniciar sesión. Intenta nuevamente.';
  }
}