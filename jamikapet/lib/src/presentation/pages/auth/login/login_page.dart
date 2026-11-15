import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jamikapet/src/presentation/routes/app_routes.dart';
import 'package:jamikapet/src/presentation/pages/auth/login/login_cubit.dart';
import 'package:jamikapet/src/presentation/widgets/app_button.dart';
import 'package:jamikapet/src/presentation/widgets/app_logo.dart';
import 'package:jamikapet/src/presentation/widgets/app_password_field.dart';
import 'package:jamikapet/src/presentation/widgets/app_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginCubit>(
      create: (context) => LoginCubit(),
      child: const _LoginContent(),
    );
  }
}

class _LoginContent extends StatefulWidget {
  const _LoginContent();

  @override
  State<_LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<_LoginContent> {
  static const Color _backgroundColor = Color(0xFFE0F6F6);
  static const Color _accentColor = Color(0xFF00897B);
  static const Color _errorColor = Color(0xFFD32F2F);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<LoginCubit>().login(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  // Al escribir se quitan los errores en pantalla
  void _alEscribir(BuildContext context) {
    context.read<LoginCubit>().limpiarError();
  }

  // Mensaje de error debajo de un campo
  Widget _errorDeCampo(String? mensaje) {
    if (mensaje == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 14, top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 15, color: _errorColor),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              mensaje,
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

  // Recuadro de error general (servidor, conexión, etc.)
  Widget _errorGeneral(String mensaje) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _errorColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, size: 18, color: _errorColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(
                fontSize: 13,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: _errorColor,
              ),
            ),
          ),
        ],
      ),
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
            builder: (context, constraints) {
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
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: BlocConsumer<LoginCubit, LoginState>(
                        listener: (context, state) {
                          if (state is LoginSuccess) {
                            Fluttertoast.showToast(
                              msg: '¡Inicio de sesión exitoso!',
                              toastLength: Toast.LENGTH_LONG,
                            );
                            Navigator.pushNamed(context, AppRoutes.home);
                          }
                        },
                        builder: (context, state) {
                          final isLoading = state is LoginLoading;
                          final falla = state is LoginFailure ? state : null;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // LOGO
                              const AppLogo(width: 130, height: 130),

                              const SizedBox(height: 20),

                              // TÍTULO
                              const Text(
                                'INICIAR SESIÓN',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black87,
                                  letterSpacing: 0.5,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // TARJETA CON LOS CAMPOS
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // EMAIL
                                    AppTextField(
                                      label: 'E-mail:',
                                      icon: Icons.mail_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      controller: _emailController,
                                      onChanged: (_) => _alEscribir(context),
                                    ),
                                    _errorDeCampo(falla?.emailError),

                                    const SizedBox(height: 16),

                                    // CONTRASEÑA
                                    AppPasswordField(
                                      label: 'Contraseña:',
                                      icon: Icons.password_outlined,
                                      controller: _passwordController,
                                      onChanged: (_) => _alEscribir(context),
                                    ),
                                    _errorDeCampo(falla?.passwordError),

                                    const SizedBox(height: 24),

                                    // ERROR GENERAL (servidor, conexión...)
                                    if (falla != null && !falla.esDeCampo)
                                      _errorGeneral(falla.errorMessage),

                                    // BOTÓN INGRESAR (ancho completo)
                                    SizedBox(
                                      width: double.infinity,
                                      child: AppButton(
                                        text: isLoading
                                            ? 'Cargando...'
                                            : 'Ingresar',
                                        onPressed: isLoading
                                            ? null
                                            : () => _submit(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // REGISTRO
                              TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.register,
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
                                  '¿No tienes cuenta? Regístrate',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
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