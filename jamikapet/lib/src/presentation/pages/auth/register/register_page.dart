import 'package:flutter/material.dart';
import 'dart:async';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/pages/auth/register/register_bloc_cubit.dart';
import 'package:jamikapet/src/presentation/widgets/app_text_field.dart';
import 'package:jamikapet/src/presentation/widgets/app_password_field.dart';
import 'package:jamikapet/src/presentation/widgets/app_button.dart';
import 'package:jamikapet/src/presentation/widgets/app_terms_checkbox.dart';
import 'package:jamikapet/src/presentation/widgets/app_logo.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const Color _backgroundColor = Color(0xFFE0F6F6);
  static const Color _accentColor = Color(0xFF00897B);

  // BLOC
  final RegisterBlocCubit bloc = RegisterBlocCubit();

  StreamSubscription<bool>? formSubscription;

  // CONTROLADORES
  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmarPasswordController = TextEditingController();

  // VARIABLES
  bool aceptarTerminos = false;
  bool formularioValido = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    formSubscription = bloc.validateForm.listen((valid) {
      if (!mounted) return;

      setState(() {
        formularioValido = valid;
      });
    });
  }

  // REGISTRO
  Future<void> registrarUsuario() async {
    FocusScope.of(context).unfocus();

    if (!aceptarTerminos) {
      Fluttertoast.showToast(
        msg: 'Debes aceptar los términos y condiciones',
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }

    if (!formularioValido) {
      Fluttertoast.showToast(
        msg: 'Verifica los datos ingresados',
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }

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
    formSubscription?.cancel();
    nombreController.dispose();
    apellidoController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmarPasswordController.dispose();
    bloc.dispose();
    super.dispose();
  }

  // Muestra dos campos en fila (pantallas anchas) o apilados (móvil)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        // Al tocar fuera de los campos se cierra el teclado
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
                          // LOGO
                          const AppLogo(width: 120, height: 120),

                          const SizedBox(height: 16),

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
                                  color: Colors.black.withOpacity(0.08),
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
                                  AppTextField(
                                    label: 'Nombre:',
                                    icon: Icons.account_circle_outlined,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    controller: nombreController,
                                    onChanged: bloc.changeName,
                                  ),
                                  AppTextField(
                                    label: 'Apellido:',
                                    icon: Icons.abc_outlined,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    controller: apellidoController,
                                    onChanged: bloc.changeLastname,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // TELÉFONO
                                AppTextField(
                                  label: 'Teléfono:',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  controller: phoneController,
                                  onChanged: bloc.changePhone,
                                ),

                                const SizedBox(height: 16),

                                // EMAIL
                                AppTextField(
                                  label: 'E-mail:',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  controller: emailController,
                                  onChanged: bloc.changeEmail,
                                ),

                                const SizedBox(height: 16),

                                // CONTRASEÑAS
                                _pair(
                                  wide,
                                  AppPasswordField(
                                    label: 'Contraseña:',
                                    controller: passwordController,
                                    onChanged: bloc.changePassword,
                                  ),
                                  AppPasswordField(
                                    label: 'Confirmar Contraseña:',
                                    controller: confirmarPasswordController,
                                    onChanged: bloc.changeConfirmPassword,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // TÉRMINOS
                                AppTermsCheckbox(
                                  value: aceptarTerminos,
                                  onChanged: (value) {
                                    setState(() {
                                      aceptarTerminos = value;
                                    });
                                  },
                                ),

                                const SizedBox(height: 20),

                                // BOTÓN REGISTRARSE (ancho completo)
                                SizedBox(
                                  width: double.infinity,
                                  child: AppButton(
                                    text: isLoading
                                        ? 'Registrando...'
                                        : 'Registrarse',
                                    onPressed: isLoading || !formularioValido
                                        ? null
                                        : registrarUsuario,
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