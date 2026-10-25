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
      final response = await _authService.iniciarSesion(
        email: email,
        password: password,
      );

      // Obtener usuario y token de la respuesta de NestJS.
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

