import 'package:flutter/material.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/pages/auth/register/register_bloc_cubit.dart';
import 'package:jamikapet/src/presentation/widgets/app_text_field.dart';
import 'package:jamikapet/src/presentation/widgets/app_password_field.dart';
import 'package:jamikapet/src/presentation/widgets/app_button.dart';
import 'package:jamikapet/src/presentation/widgets/app_terms_checkbox.dart';
import 'package:jamikapet/src/presentation/widgets/dog_mascota.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const Color _backgroundColor = Color(0xFFE0F6F6);
  static const Color _accentColor = Color(0xFF00897B);
  static const Color _errorColor = Color(0xFFD32F2F);

  // BLOC
  final RegisterBlocCubit bloc = RegisterBlocCubit();

  // CONTROLADORES
  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmarPasswordController = TextEditingController();

  // VARIABLES
  bool aceptarTerminos = false;
  bool isLoading = false;

  // Se pone en true cuando el usuario presiona "Registrarse":
  // desde ese momento se muestran TODOS los errores.
  bool _intentoRegistrar = false;

  // Campos que el usuario ya tocó
  final Set<String> _tocados = {};

  // Campo que tiene el cursor en este momento
  String? _campoActivo;

  // =========================================================
  // VALIDACIONES POR CAMPO (null = el campo está bien)
  // =========================================================
  String? get _errorNombre =>
      nombreController.text.trim().isEmpty ? 'Ingresa tu nombre' : null;

  String? get _errorApellido =>
      apellidoController.text.trim().isEmpty ? 'Ingresa tu apellido' : null;

  String? get _errorTelefono {
    final texto = phoneController.text.trim();
    if (texto.isEmpty) return 'Ingresa tu teléfono';
    final digitos = texto.replaceAll(RegExp(r'\D'), '');
    if (digitos.length != 10) return 'El teléfono debe tener 10 dígitos';
    return null;
  }

  String? get _errorEmail {
    final texto = emailController.text.trim();
    if (texto.isEmpty) return 'Ingresa tu e-mail';
    final valido = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(texto);
    if (!valido) return 'Escribe un e-mail válido (ej. nombre@correo.com)';
    return null;
  }

  String? get _errorPassword {
    final texto = passwordController.text;
    if (texto.isEmpty) return 'Ingresa una contraseña';
    if (texto.length < 8) return 'Debe tener al menos 8 caracteres';
    return null;
  }

  String? get _errorConfirmar {
    final texto = confirmarPasswordController.text;
    if (texto.isEmpty) return 'Confirma tu contraseña';
    if (texto != passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  String? get _errorTerminos =>
      aceptarTerminos ? null : 'Debes aceptar los términos y condiciones';

  bool get _hayErrores =>
      _errorNombre != null ||
      _errorApellido != null ||
      _errorTelefono != null ||
      _errorEmail != null ||
      _errorPassword != null ||
      _errorConfirmar != null ||
      _errorTerminos != null;

  // =========================================================
  // REGISTRO
  // =========================================================
  Future<void> registrarUsuario() async {
    FocusScope.of(context).unfocus();

    if (isLoading) return;

    // Activa la visualización de todos los errores
    setState(() {
      _intentoRegistrar = true;
    });

    // No se registra si falta algo o si no aceptó los términos
    if (_hayErrores) return;

    setState(() {
      isLoading = true;
    });

    try {
      await bloc.register();

      if (!mounted) return;

      Fluttertoast.showToast(
        msg: 'Registro realizado correctamente',
        toastLength: Toast.LENGTH_LONG,
      );

      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } catch (e) {
      if (!mounted) return;

      Fluttertoast.showToast(msg: e.toString(), toastLength: Toast.LENGTH_LONG);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmarPasswordController.dispose();
    bloc.dispose();
    super.dispose();
  }

  // =========================================================
  // AYUDAS DE DISEÑO
  // =========================================================

  // Marca el campo como tocado y refresca los mensajes
  void _tocar(String campo) {
    setState(() {
      _tocados.add(campo);
    });
  }

  // Mensaje de error en rojo
  Widget _mensajeError(String texto) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 15, color: _errorColor),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 12.5,
                color: _errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Campo + error debajo (si ya lo tocó o si intentó registrarse).
  // También detecta cuándo el campo tiene el foco, para la mascota.
  Widget _campo(String campo, String? error, Widget child) {
    final mostrarError =
        (_tocados.contains(campo) || _intentoRegistrar) && error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onFocusChange: (tieneFoco) {
            setState(() {
              if (tieneFoco) {
                _campoActivo = campo;
              } else if (_campoActivo == campo) {
                _campoActivo = null;
              }
            });
          },
          child: child,
        ),
        if (mostrarError) _mensajeError(error),
      ],
    );
  }

  // Dos campos en fila (pantallas anchas) o apilados (móvil)
  Widget _pair(bool wide, Widget first, Widget second) {
    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: first),
          const SizedBox(width: 14),
          Expanded(child: second),
        ],
      );
    }
    return Column(
      children: [
        first,
        const SizedBox(height: 16),
        second,
      ],
    );
  }

  // =========================================================
  // MASCOTA
  // =========================================================
  TextEditingController? get _controladorActivo {
    switch (_campoActivo) {
      case 'nombre':
        return nombreController;
      case 'apellido':
        return apellidoController;
      case 'telefono':
        return phoneController;
      case 'email':
        return emailController;
      default:
        return null;
    }
  }

  // Los ojos siguen el texto: vacío = izquierda, lleno = derecha
  double get _lookX {
    final c = _controladorActivo;
    if (c == null) return 0;
    return (c.text.length / 18).clamp(0.0, 1.0) * 2 - 1;
  }

  DogMood get _mood {
    if (isLoading) return DogMood.happy;
    if (_campoActivo == 'password' || _campoActivo == 'confirmar') {
      return DogMood.password;
    }
    if (_intentoRegistrar && _hayErrores) return DogMood.sad;
    if (!_hayErrores) return DogMood.happy;
    if (_campoActivo != null) return DogMood.typing;
    return DogMood.idle;
  }

  String get _mensaje {
    switch (_mood) {
      case DogMood.happy:
        return isLoading
            ? '¡Guau! Creando tu cuenta... 🐾'
            : '¡Todo listo! Presiona Registrarse 🎉';
      case DogMood.password:
        return 'No miro, lo prometo 🙈';
      case DogMood.sad:
        return 'Uy, faltan algunos datos 🥺';
      case DogMood.typing:
        switch (_campoActivo) {
          case 'nombre':
            return '¿Cómo te llamas? 🐶';
          case 'apellido':
            return '¿Y tu apellido?';
          case 'telefono':
            return 'Tu número, 10 dígitos 📱';
          case 'email':
            return 'Tu correo, ¡sin spam! ✉️';
          case 'terminos':
            return 'Léelos con calma 📄';
          default:
            return '¡Sigue así!';
        }
      case DogMood.idle:
        return '¡Hola! Soy Jamik 🐾\nTe ayudo a registrarte';
    }
  }

  Widget _mascota() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DogMascot(mood: _mood, lookX: _lookX, size: 110),
        const SizedBox(width: 8),
        Flexible(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Container(
              key: ValueKey(_mensaje),
              constraints: const BoxConstraints(maxWidth: 220),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _accentColor.withValues(alpha: 0.4)),
              ),
              child: Text(
                _mensaje,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // BUILD
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool wide = constraints.maxWidth >= 700;

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 750),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // MASCOTA ANIMADA
                          _mascota(),

                          const SizedBox(height: 8),

                          // TÍTULO
                          const Text(
                            'REGISTRO DE USUARIO',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // TARJETA CON EL FORMULARIO
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // NOMBRE + APELLIDO
                                _pair(
                                  wide,
                                  _campo(
                                    'nombre',
                                    _errorNombre,
                                    AppTextField(
                                      label: 'Nombre:',
                                      icon: Icons.account_circle_outlined,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      controller: nombreController,
                                      onChanged: (v) {
                                        bloc.changeName(v);
                                        _tocar('nombre');
                                      },
                                    ),
                                  ),
                                  _campo(
                                    'apellido',
                                    _errorApellido,
                                    AppTextField(
                                      label: 'Apellido:',
                                      icon: Icons.abc_outlined,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      controller: apellidoController,
                                      onChanged: (v) {
                                        bloc.changeLastname(v);
                                        _tocar('apellido');
                                      },
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // TELÉFONO
                                _campo(
                                  'telefono',
                                  _errorTelefono,
                                  AppTextField(
                                    label: 'Teléfono:',
                                    icon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                    controller: phoneController,
                                    onChanged: (v) {
                                      bloc.changePhone(v);
                                      _tocar('telefono');
                                    },
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // EMAIL
                                _campo(
                                  'email',
                                  _errorEmail,
                                  AppTextField(
                                    label: 'E-mail:',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    controller: emailController,
                                    onChanged: (v) {
                                      bloc.changeEmail(v);
                                      _tocar('email');
                                    },
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // CONTRASEÑAS
                                _pair(
                                  wide,
                                  _campo(
                                    'password',
                                    _errorPassword,
                                    AppPasswordField(
                                      label: 'Contraseña:',
                                      controller: passwordController,
                                      onChanged: (v) {
                                        bloc.changePassword(v);
                                        _tocar('password');
                                      },
                                    ),
                                  ),
                                  _campo(
                                    'confirmar',
                                    _errorConfirmar,
                                    AppPasswordField(
                                      label: 'Confirmar Contraseña:',
                                      controller: confirmarPasswordController,
                                      onChanged: (v) {
                                        bloc.changeConfirmPassword(v);
                                        _tocar('confirmar');
                                      },
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // TÉRMINOS + error en rojo debajo
                                _campo(
                                  'terminos',
                                  _errorTerminos,
                                  AppTermsCheckbox(
                                    value: aceptarTerminos,
                                    onChanged: (value) {
                                      setState(() {
                                        aceptarTerminos = value;
                                        _tocados.add('terminos');
                                      });
                                    },
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // BOTÓN REGISTRARSE
                                SizedBox(
                                  width: double.infinity,
                                  child: AppButton(
                                    text: isLoading
                                        ? 'Registrando...'
                                        : 'Registrarse',
                                    onPressed:
                                        isLoading ? null : registrarUsuario,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // INICIAR SESIÓN
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.login,
                                    );
                                  },
                            style: TextButton.styleFrom(
                              foregroundColor: _accentColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            child: const Text(
                              'Iniciar de Sesión',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}