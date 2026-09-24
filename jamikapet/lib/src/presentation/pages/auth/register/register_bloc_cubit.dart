import 'dart:async';

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
  String _password = '';
  String _confirmPassword = '';

  // ============================================================
  // STREAMS
  // ============================================================
  Stream<String> get nameStream => _nameController.stream;

  Stream<String> get lastnameStream => _lastnameController.stream;

  Stream<String> get emailStream => _emailController.stream;

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
  void changelastname(String value) {

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

    // También debemos comprobar nuevamente la confirmación de contraseña.
    if (_confirmPassword.isNotEmpty) {

      final confirmError =
          _validateConfirmPassword(
        _password,
        _confirmPassword,
      );

      if (confirmError != null) {
        _confirmPasswordController
            .addError(confirmError);
      } else {
        _confirmPasswordController
            .add(_confirmPassword);
      }
    }

    _validateForm();
  }


  // ============================================================
  // CONFIRMAR CONTRASEÑA
  // ============================================================
  void changeConfirmPassword(String value) {

    _confirmPassword = value;

    final error = _validateConfirmPassword(
      _password,
      _confirmPassword,
    );

    if (error != null) {
      _confirmPasswordController.addError(error);
    } else {
      _confirmPasswordController
          .add(_confirmPassword);
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

    if (value.length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }

    if (value.length > 50) {
      return 'El nombre no puede superar los 50 caracteres';
    }

    final regex = RegExp(
      r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$',
    );

    if (!regex.hasMatch(value)) {
      return 'El nombre solo puede contener letras';
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

    if (value.length < 3) {
      return 'El apellido debe tener al menos 3 caracteres';
    }

    if (value.length > 50) {
      return 'El apellido no puede superar los 50 caracteres';
    }

    final regex = RegExp(
      r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$',
    );

    if (!regex.hasMatch(value)) {
      return 'El apellido solo puede contener letras';
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

    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!regex.hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
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

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Debe contener al menos una mayúscula';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Debe contener al menos una minúscula';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Debe contener al menos un número';
    }

    return null;
  }


  // ============================================================
  // VALIDAR CONFIRMACIÓN
  // ============================================================

  String? _validateConfirmPassword(
    String password,
    String confirmPassword,
  ) {

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
    final validPassword = _validatePassword(_password) == null;
    final validConfirmPassword = _validateConfirmPassword(
          _password, _confirmPassword) == null;

    final valid =
        validName &&
        validLastname &&
        validEmail &&
        validPassword &&
        validConfirmPassword;
  
    print('--- VALIDACIÓN ---');
    print('Nombre: $validName ($_name)');
    print('Apellido: $validLastname ($_lastname)');
    print('Email: $validEmail ($_email)');
    print('Password: $validPassword ($_password)');
    print('Confirmar: $validConfirmPassword ($_confirmPassword)');
    print('FORMULARIO: $valid');

    _validateFormController.add(valid);
  }


  // ============================================================
  // REGISTRO
  // ============================================================

  Future<void> register() async {

    // Validación final antes de registrar.

    if (_validateName(_name) != null ||
        _validateLastname(_lastname) != null ||
        _validateEmail(_email) != null ||
        _validatePassword(_password) != null ||
        _validateConfirmPassword(
          _password,
          _confirmPassword,
        ) != null) {

      return;
    }


    // Por ahora solamente mostramos los datos.
    // Posteriormente aquí conectaremos RegisterService.

    print('========== REGISTRO ==========');
    print('Nombre: $_name');
    print('Apellido: $_lastname');
    print('Email: $_email');
    print('Contraseña: $_password');
    print('==============================');
  }


  // ============================================================
  // OBTENER DATOS DEL FORMULARIO
  // ============================================================

  Map<String, dynamic> get registerData {

    return {
      'nombre': _name,
      'apellido': _lastname,
      'email': _email,
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
    _passwordController.close();
    _confirmPasswordController.close();
    _validateFormController.close();
  }
}