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
      backgroundColor: Color(0xFFE0F6F6),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {

            final double screenWidth = constraints.maxWidth;

            return SingleChildScrollView(
              child: Center(
                child: Container(

                  width: screenWidth >= 1000 ? 750 : double.infinity,

                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
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
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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

                          const SizedBox(height: 25,),

                          // ===========================================
                          // LOGO
                          // ===========================================
                          const AppLogo(
                            width: 150,
                            height: 150,
                          ),

                          const SizedBox(height: 25,),

                          // ===========================================
                          // EMAIL
                          // ===========================================
                          AppTextField(
                            label: 'E-mail:',
                            icon: Icons.mail_outlined,
                            keyboardType:
                                TextInputType.emailAddress,
                            controller:
                                _emailController,
                          ),

                          const SizedBox(height: 14,),

                          // ===========================================
                          // CONTRASEÑA
                          // ===========================================
                          AppPasswordField(
                            label: 'Contraseña:',
                            icon: Icons.password_outlined,
                            controller:
                                _passwordController,
                          ),

                          const SizedBox(height: 25,),

                          // ===========================================
                          // BOTÓN INGRESAR
                          // ===========================================
                          BlocConsumer<LoginCubit, LoginState>(
                            listener: (context, state) {
                              if (state is LoginSuccess) {
                                Navigator.pushReplacementNamed(context, AppRoutes.home,);
                              }

                              if (state is LoginFailure) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(state.errorMessage),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            builder: (context, state) {
                              final isLoading = state is LoginLoading;

                              return AppButton(
                                text: isLoading ? 'Cargando...' : 'Ingresar',
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        context.read<LoginCubit>().login(
                                              _emailController.text.trim(),
                                              _passwordController.text,
                                            );
                                      },
                              );
                            },
                          ),
                          
                          const SizedBox(height: 15,),

                          // ===========================================
                          // REGRESAR A REGISTRO
                          // ===========================================
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.register);
                            },
                            child: const Text(
                              '¿No tienes cuenta? Regístrate',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
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
