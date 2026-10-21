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
  final String errorMessage;

  LoginFailure({required this.errorMessage});
}

// ============================================================
// CUBIT
// ============================================================

class LoginCubit extends Cubit<LoginState> {
  final AuthService _authService;

  LoginCubit({AuthService? authService})
      : _authService = authService ?? AuthService(),
        super(LoginInitial());

  Future<void> login(
    String email,
    String password,
  ) async {
    // Validar campos
    if (email.trim().isEmpty || password.isEmpty) {
      emit(
        LoginFailure(
          errorMessage: 'Por favor llena todos los campos.',
        ),
      );
      return;
    }

    emit(LoginLoading());

    try {
      // Petición real al backend NestJS
      final response = await _authService.iniciarSesion(
        email: email.trim(),
        password: password,
      );

      final dynamic userData =
          response['user'] ?? response['usuario'];

      final dynamic tokenData =
          response['token'] ?? response['access_token'];

      if (userData is! Map ||
          tokenData is! String ||
          tokenData.trim().isEmpty) {
        throw const AuthException(
          'La respuesta del servidor no contiene el usuario '
          'y el token de autenticación.',
        );
      }

      await TokenStorage.saveToken(tokenData);
      emit(
        LoginSuccess(
          user: Map<String, dynamic>.from(userData),
          token: tokenData,
          message: response['message']?.toString() ??
              'Inicio de sesión exitoso.',
        ),
      );
    } on AuthException catch (e) {
      emit(LoginFailure(errorMessage: e.mensaje));
    } catch (_) {
      emit(
        LoginFailure(
          errorMessage:
              'No fue posible iniciar sesión. Intenta nuevamente.',
        ),
      );
    }
  }
}

