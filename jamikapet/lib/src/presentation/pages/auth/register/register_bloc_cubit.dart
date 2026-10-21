import 'dart:async';
import 'package:jamikapet/src/models/usuario.dart';
import 'package:jamikapet/src/services/auth_service.dart';

class RegisterBlocCubit {
  // ============================================================
  // CONTROLLERS
  // ============================================================
  final StreamController<String> _nameController =
      StreamController<String>.broadcast();

  final StreamController<String> _lastnameController =
      StreamController<String>.broadcast();

  final StreamController<String> _emailController =
      StreamController<String>.broadcast();

  final StreamController<String> _phoneController =
      StreamController<String>.broadcast();

  final StreamController<String> _passwordController =
      StreamController<String>.broadcast();

  final StreamController<String> _confirmPasswordController =
      StreamController<String>.broadcast();

  final StreamController<bool> _validateFormController =
      StreamController<bool>.broadcast();

  // ============================================================
  // VALORES
  // ============================================================
  String _name = '';
  String _lastname = '';
  String _email = '';
  String _phone = '';
  String _password = '';
  String _confirmPassword = '';

  // ============================================================
  // STREAMS
  // ============================================================
  Stream<String> get nameStream => _nameController.stream;

  Stream<String> get lastnameStream => _lastnameController.stream;

  Stream<String> get emailStream => _emailController.stream;

  Stream<String> get phoneStream => _phoneController.stream;

  Stream<String> get passwordStream => _passwordController.stream;

  Stream<String> get confirmPasswordStream => _confirmPasswordController.stream;

  Stream<bool> get validateForm => _validateFormController.stream;

  // ============================================================
  // NOMBRE
  // ============================================================
  void changeName(String value) {
    _name = value.trim();

    final error = _validateName(_name);

    if (error != null) {
      _nameController.addError(error);
    } else {
      _nameController.add(_name);
    }

    _validateForm();
  }

  // ============================================================
  // APELLIDO
  // ============================================================
  void changeLastname(String value) {
    _lastname = value.trim();

    final error = _validateLastname(_lastname);

    if (error != null) {
      _lastnameController.addError(error);
    } else {
      _lastnameController.add(_lastname);
    }

    _validateForm();
  }

  // ============================================================
  // EMAIL
  // ============================================================
  void changeEmail(String value) {
    _email = value.trim();

    final error = _validateEmail(_email);

    if (error != null) {
      _emailController.addError(error);
    } else {
      _emailController.add(_email);
    }

    _validateForm();
  }

  // ============================================================
  // TELÉFONO
  // ============================================================
  void changePhone(String value) {
    _phone = value.trim();

    final error = _validatePhone(_phone);
    if (error != null) {
      _phoneController.addError(error);
    } else {
      _phoneController.add(_phone);
    }

    _validateForm();
  }

  // ============================================================
  // CONTRASEÑA
  // ============================================================
  void changePassword(String value) {
    _password = value;

    final error = _validatePassword(_password);

    if (error != null) {
      _passwordController.addError(error);
    } else {
      _passwordController.add(_password);
    }

    // Validar nuevamente la confirmación de contraseña.
    if (_confirmPassword.isNotEmpty) {
      final confirmError = _validateConfirmPassword(
        _password,
        _confirmPassword,
      );

      if (confirmError != null) {
        _confirmPasswordController.addError(confirmError);
      } else {
        _confirmPasswordController.add(_confirmPassword);
      }
    }

    _validateForm();
  }

  // ============================================================
  // CONFIRMAR CONTRASEÑA
  // ============================================================
  void changeConfirmPassword(String value) {
    _confirmPassword = value;

    final error = _validateConfirmPassword(_password, _confirmPassword);

    if (error != null) {
      _confirmPasswordController.addError(error);
    } else {
      _confirmPasswordController.add(_confirmPassword);
    }

    _validateForm();
  }

  // ============================================================
  // VALIDAR NOMBRE
  // ============================================================
  String? _validateName(String value) {
    if (value.isEmpty) {
      return 'El nombre es obligatorio';
    }
    return null;
  }

  // ============================================================
  // VALIDAR APELLIDO
  // ============================================================
  String? _validateLastname(String value) {
    if (value.isEmpty) {
      return 'El apellido es obligatorio';
    }
    return null;
  }

  // ============================================================
  // VALIDAR EMAIL
  // ============================================================
  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'El correo electrónico es obligatorio';
    }

    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!regex.hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }

    return null;
  }

  String? _validatePhone(String value) {
    if (value.isEmpty) {
      return 'El teléfono es obligatorio';
    }
    return null;
  }

  // ============================================================
  // VALIDAR CONTRASEÑA
  // ============================================================
  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'La contraseña es obligatoria';
    }

    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    return null;
  }

  // ============================================================
  // VALIDAR CONFIRMACIÓN
  // ============================================================
  String? _validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Confirma tu contraseña';
    }

    if (password != confirmPassword) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  // ============================================================
  // VALIDAR FORMULARIO COMPLETO
  // ============================================================
  void _validateForm() {
    final validName = _validateName(_name) == null;
    final validLastname = _validateLastname(_lastname) == null;
    final validEmail = _validateEmail(_email) == null;
    final validPhone = _validatePhone(_phone) == null;
    final validPassword = _validatePassword(_password) == null;

    final validConfirmPassword =
        _validateConfirmPassword(_password, _confirmPassword) == null;

    final valid =
        validName &&
        validLastname &&
        validEmail &&
        validPhone &&
        validPassword &&
        validConfirmPassword;

    _validateFormController.add(valid);
  }

  // ============================================================
  // REGISTRO
  // ============================================================
  Future<Usuario> register() async {
    if (_validateName(_name) != null ||
        _validateLastname(_lastname) != null ||
        _validateEmail(_email) != null ||
        _validatePhone(_phone) != null ||
        _validatePassword(_password) != null ||
        _validateConfirmPassword(_password, _confirmPassword) != null) {
      throw const AuthException('Verifica los datos ingresados.');
    }

    return AuthService().registrarUsuario(
      nombre: _name,
      apellido: _lastname,
      email: _email,
      phone: _phone,
      password: _password,
    );
  }
  // ============================================================
  // OBTENER DATOS DEL FORMULARIO
  // ============================================================
  Map<String, dynamic> get registerData {
    return {
      'nombre': _name,
      'apellido': _lastname,
      'email': _email,
      'phone': _phone,
      'password': _password,
    };
  }

  // ============================================================
  // DISPOSE
  // ============================================================
  void dispose() {
    _nameController.close();
    _lastnameController.close();
    _emailController.close();
    _phoneController.close();
    _passwordController.close();
    _confirmPasswordController.close();
    _validateFormController.close();
  }
}
