import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jamikapet/src/presentation/pages/auth/login/login_cubit.dart';
import 'package:jamikapet/src/presentation/widgets/app_button.dart';
import 'package:jamikapet/src/presentation/widgets/app_logo.dart';
import 'package:jamikapet/src/presentation/widgets/app_password_field.dart';
import 'package:jamikapet/src/presentation/widgets/app_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // =========================================================
    // PROVIDER DEL LOGIN
    // =========================================================

    return BlocProvider<LoginCubit>(
      create: (context) => LoginCubit(),
      child: const _LoginContent(),
    );
  }
}

// =============================================================
// CONTENIDO DEL LOGIN
// =============================================================

class _LoginContent extends StatefulWidget {
  const _LoginContent();

  @override
  State<_LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<_LoginContent> {

  // ===========================================================
  // CONTROLADORES
  // ===========================================================

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  // ===========================================================
  // DISPOSE
  // ===========================================================

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // ===========================================================
  // BUILD
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {

            final double screenWidth =
                constraints.maxWidth;

            return SingleChildScrollView(
              child: Center(
                child: Container(

                  width: screenWidth >= 1000
                      ? 850
                      : double.infinity,

                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),

                  margin: const EdgeInsets.symmetric(
                    vertical: 18,
                  ),

                  padding: EdgeInsets.symmetric(
                    horizontal:
                        screenWidth < 600 ? 18 : 40,
                    vertical: 25,
                  ),

                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F6F6),
                  ),

                  // =================================================
                  // BLOC CONSUMER
                  // =================================================

                  child: BlocConsumer<LoginCubit, LoginState>(

                    // =================================================
                    // LISTENER
                    // =================================================

                    listener: (context, state) {

                      if (state is LoginSuccess) {

                        Fluttertoast.showToast(
                          msg:
                              '¡Inicio de sesión exitoso!',
                          toastLength:
                              Toast.LENGTH_LONG,
                        );

                      } else if (state is LoginFailure) {

                        Fluttertoast.showToast(
                          msg: state.errorMessage,
                          toastLength:
                              Toast.LENGTH_LONG,
                        );
                      }
                    },

                    // =================================================
                    // BUILDER
                    // =================================================

                    builder: (context, state) {

                      final bool isLoading =
                          state is LoginLoading;

                      return Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [

                          // ===========================================
                          // TÍTULO
                          // ===========================================

                          const Text(
                            'INICIAR SESIÓN',

                            style: TextStyle(
                              fontSize: 27,
                              fontWeight:
                                  FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(
                            height: 25,
                          ),

                          // ===========================================
                          // LOGO
                          // ===========================================

                          const AppLogo(
                            width: 150,
                            height: 150,
                          ),

                          const SizedBox(
                            height: 25,
                          ),

                          // ===========================================
                          // EMAIL
                          // ===========================================

                          AppTextField(
                            label: 'E-mail:',
                            icon: null,
                            keyboardType:
                                TextInputType.emailAddress,
                            controller:
                                _emailController,
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          // ===========================================
                          // CONTRASEÑA
                          // ===========================================

                          AppPasswordField(
                            label: 'Contraseña:',
                            controller:
                                _passwordController,
                          ),

                          const SizedBox(
                            height: 25,
                          ),

                          // ===========================================
                          // BOTÓN INGRESAR
                          // ===========================================

                          AppButton(
                            text: isLoading
                                ? 'Cargando...'
                                : 'Ingresar',

                            onPressed: isLoading
                                ? null
                                : () {

                                    context
                                        .read<LoginCubit>()
                                        .login(
                                          _emailController
                                              .text,
                                          _passwordController
                                              .text,
                                        );
                                  },
                          ),

                          const SizedBox(
                            height: 15,
                          ),

                          // ===========================================
                          // REGRESAR A REGISTRO
                          // ===========================================

                          TextButton(
                            onPressed: () {

                              Navigator.pop(
                                context,
                              );
                            },

                            child: const Text(
                              '¿No tienes cuenta? Regístrate',

                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}