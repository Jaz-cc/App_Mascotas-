import 'package:flutter_bloc/flutter_bloc.dart';

// ============================================================
// ESTADOS
// ============================================================

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginFailure extends LoginState {
  final String errorMessage;

  LoginFailure({
    required this.errorMessage,
  });
}

// ============================================================
// CUBIT
// ============================================================

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  Future<void> login(
    String email,
    String password,
  ) async {
    // ========================================================
    // VALIDAR CAMPOS
    // ========================================================

    if (email.isEmpty || password.isEmpty) {
      emit(
        LoginFailure(
          errorMessage: 'Por favor llena todos los campos',
        ),
      );

      return;
    }

    // ========================================================
    // ESTADO DE CARGA
    // ========================================================

    emit(LoginLoading());

    try {
      // Simulación de conexión con el servidor
      await Future.delayed(
        const Duration(seconds: 1),
      );

      // ======================================================
      // LOGIN EXITOSO
      // ======================================================

      emit(LoginSuccess());
    } catch (e) {
      // ======================================================
      // ERROR
      // ======================================================

      emit(
        LoginFailure(
          errorMessage: e.toString(),
        ),
      );
    }
  }
}