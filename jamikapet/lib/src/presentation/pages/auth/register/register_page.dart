import 'package:flutter/material.dart';
import 'dart:async';
import 'package:jamikapet/src/presentation/pages/auth/register/register_bloc_cubit.dart';
import 'package:jamikapet/src/presentation/widgets/app_text_field.dart';
import 'package:jamikapet/src/presentation/widgets/app_password_field.dart';
import 'package:jamikapet/src/presentation/widgets/app_button.dart';
import 'package:jamikapet/src/presentation/widgets/app_terms_checkbox.dart';
import 'package:jamikapet/src/presentation/widgets/app_logo.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jamikapet/src/presentation/pages/auth/login/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // =========================================================
  // BLOC
  // =========================================================
  final RegisterBlocCubit bloc = RegisterBlocCubit();
  StreamSubscription<bool>? formSubscription;

  // =========================================================
  // CONTROLADORES
  // =========================================================
  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmarPasswordController = TextEditingController();

  // =========================================================
  // VARIABLES
  // =========================================================

  bool aceptarTerminos = false;
  bool formularioValido = false;
  bool isLoading = false;

  // =========================================================
  // INIT STATE
  // =========================================================

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

  // =========================================================
  // REGISTRO
  // =========================================================

  Future<void> registrarUsuario() async {
    // ---------------------------------------------------------
    // TÉRMINOS Y CONDICIONES
    // ---------------------------------------------------------

    if (!aceptarTerminos) {
      Fluttertoast.showToast(
        msg: 'Debes aceptar los términos y condiciones',
        toastLength: Toast.LENGTH_LONG,
      );

      return;
    }

    // ---------------------------------------------------------
    // VALIDACIÓN DEL FORMULARIO
    // ---------------------------------------------------------
    if (!formularioValido) {
      Fluttertoast.showToast(
        msg: 'Verifica los datos ingresados',
        toastLength: Toast.LENGTH_LONG,
      );

      return;
    }

    // ---------------------------------------------------------
    // CARGANDO
    // ---------------------------------------------------------
    setState(() {
      isLoading = true;
    });

    try {
      // -------------------------------------------------------
      // REGISTRO EN EL BLOC
      // -------------------------------------------------------

      await bloc.register();

      if (!mounted) return;

      Fluttertoast.showToast(
        msg: 'Registro realizado correctamente',
        toastLength: Toast.LENGTH_LONG,
      );

      // -------------------------------------------------------
      // POSTERIORMENTE:
      // Navegar al Login
      // -------------------------------------------------------

      // Navigator.pushReplacementNamed(
      //   context,
      //   '/login',
      // );
    } catch (e) {
      if (!mounted) return;

      Fluttertoast.showToast(
        msg: 'Ocurrió un error al registrar el usuario',
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    formSubscription?.cancel();

    nombreController.dispose();
    apellidoController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmarPasswordController.dispose();

    bloc.dispose();

    super.dispose();
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (
            BuildContext context,
            BoxConstraints constraints,
          ) {
            // =================================================
            // RESPONSIVIDAD
            // =================================================

            final double screenWidth = constraints.maxWidth;

            double contentWidth;

            if (screenWidth < 600) {
              // CELULAR
              contentWidth = screenWidth;
            } else if (screenWidth < 1000) {
              // TABLET
              contentWidth = 650;
            } else {
              // ESCRITORIO / WEB
              contentWidth = 850;
            }

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
                    horizontal: screenWidth < 600 ? 18 : 40,
                    vertical: 25,
                  ),

                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F6F6),
                  ),

                  child: Center(
                    child: SizedBox(
                      // width: contentWidth,

                      child: Column(
                        children: [
                          // ===================================
                          // TÍTULO
                          // ===================================
                          const Text(
                            'REGISTRO DE USUARIO',

                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 25),

                          // ===================================
                          // LOGO
                          // ===================================
                          const AppLogo(
                            width: 150,
                            height: 150,
                          ),

                          const SizedBox(height: 25),

                          // ===================================
                          // NOMBRE + APELLIDO
                          // ===================================
                          if (screenWidth >= 700)
                            Row(
                              children: [

                                Expanded(
                                  child: AppTextField(
                                    label: 'Nombre:',
                                    icon: null,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    controller:
                                        nombreController,
                                    onChanged:
                                        bloc.changeName,
                                  ),
                                ),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: AppTextField(
                                    label: 'Apellido:',
                                    icon: null,
                                    textCapitalization: TextCapitalization.words,
                                    controller: apellidoController,
                                    onChanged: bloc.changelastname,
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [

                                AppTextField(
                                  label: 'Nombre:',
                                  icon: null,
                                  textCapitalization:
                                      TextCapitalization.words,
                                  controller:
                                      nombreController,
                                  onChanged:
                                      bloc.changeName,
                                ),

                                const SizedBox(height: 14),

                                AppTextField(
                                  label: 'Apellido:',
                                  icon: null,
                                  textCapitalization:
                                      TextCapitalization.words,
                                  controller:
                                      apellidoController,
                                  onChanged:
                                      bloc.changelastname,
                                ),
                              ],
                            ),

                          const SizedBox(height: 14),

                          // ===================================
                          // EMAIL
                          // ===================================
                          AppTextField(
                            label: 'E-mail:',
                            icon: null,
                            keyboardType: TextInputType.emailAddress,
                            controller: emailController,
                            onChanged: bloc.changeEmail,
                          ),

                          const SizedBox(height: 14),

                          // ===================================
                          // CONTRASEÑAS
                          // ===================================
                          if (screenWidth >= 700)
                            Row(
                              children: [
                                Expanded(
                                  child: AppPasswordField(
                                    label: 'Contraseña:',
                                    controller: passwordController,
                                    onChanged: bloc.changePassword,
                                  ),
                                ),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: AppPasswordField(
                                    label: 'Confirmar Contraseña:',
                                    controller: confirmarPasswordController,
                                    onChanged: bloc.changeConfirmPassword,
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                AppPasswordField(
                                  label: 'Contraseña:',
                                  controller: passwordController,
                                  onChanged: bloc.changePassword,
                                ),

                                const SizedBox(height: 14),

                                AppPasswordField(
                                  label: 'Confirmar Contraseña:',
                                  controller: confirmarPasswordController,
                                  onChanged: bloc.changeConfirmPassword,
                                ),
                              ],
                            ),

                          const SizedBox(height: 18),

                          // ===================================
                          // TÉRMINOS
                          // ===================================
                          AppTermsCheckbox(
                            value: aceptarTerminos,
                            //Aplicar enlace hacia el archivo de terminos y condiciones.
                            onChanged: (value) {
                              setState(() {
                                aceptarTerminos = value;
                              });
                            },
                          ),

                          const SizedBox(height: 18),

                          // ===================================
                          // BOTÓN REGISTRARSE
                          // ===================================
                          AppButton(
                            text: isLoading
                                ? 'Registrando...'
                                : 'Registrarse',
                            onPressed: isLoading || !formularioValido
                                ? null
                                : registrarUsuario,
                          ),

                          const SizedBox(height: 5),

                          // ===================================
                          // INICIAR SESIÓN
                          // ===================================
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },

                            child: const Text(
                              'Iniciar de Sesión',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
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




