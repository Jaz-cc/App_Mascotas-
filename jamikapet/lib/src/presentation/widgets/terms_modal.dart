// import 'package:flutter/material.dart';

// class TermsModal {
//   static void show(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (context) {
//         return Dialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(
//               maxWidth: 700,
//               maxHeight: 650,
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [

//                   // TÍTULO
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.description_outlined,
//                         color: Color(0xFF4FC3B8),
//                         size: 30,
//                       ),

//                       const SizedBox(width: 10),

//                       const Expanded(
//                         child: Text(
//                           'Términos y condiciones',
//                           style: TextStyle(
//                             fontSize: 23,
//                             fontWeight: FontWeight.w900,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),

//                       IconButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                         icon: const Icon(Icons.close),
//                       ),
//                     ],
//                   ),

//                   const Divider(),

//                   const SizedBox(height: 10),

//                   // CONTENIDO
//                   Expanded(
//                     child: SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment:
//                             CrossAxisAlignment.start,
//                         children: const [

//                           Text(
//                             '1. Uso de la aplicación',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),

//                           SizedBox(height: 8),

//                           Text(
//                             'JAMIKA PET es una aplicación diseñada '
//                             'para facilitar el seguimiento y registro '
//                             'del bienestar y cuidado de las mascotas. '
//                             'El usuario se compromete a utilizar la '
//                             'aplicación de manera responsable y de '
//                             'acuerdo con la legislación aplicable.',
//                             style: TextStyle(
//                               fontSize: 15,
//                               height: 1.5,
//                               color: Colors.black87,
//                             ),
//                           ),

//                           SizedBox(height: 20),

//                           Text(
//                             '2. Información del usuario',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),

//                           SizedBox(height: 8),

//                           Text(
//                             'Para utilizar determinadas funciones, '
//                             'la aplicación puede solicitar información '
//                             'como nombre, apellido y correo electrónico. '
//                             'El usuario es responsable de proporcionar '
//                             'información correcta y actualizada.',
//                             style: TextStyle(
//                               fontSize: 15,
//                               height: 1.5,
//                               color: Colors.black87,
//                             ),
//                           ),

//                           SizedBox(height: 20),

//                           Text(
//                             '3. Privacidad',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),

//                           SizedBox(height: 8),

//                           Text(
//                             'JAMIKA PET tratará la información personal '
//                             'del usuario de acuerdo con su política de '
//                             'privacidad. Los datos serán utilizados '
//                             'únicamente para proporcionar y mejorar '
//                             'las funcionalidades de la aplicación, '
//                             'conforme a los fines informados al usuario.',
//                             style: TextStyle(
//                               fontSize: 15,
//                               height: 1.5,
//                               color: Colors.black87,
//                             ),
//                           ),

//                           SizedBox(height: 20),

//                           Text(
//                             '4. Seguridad de la información',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),

//                           SizedBox(height: 8),

//                           Text(
//                             'Se implementarán medidas de seguridad '
//                             'para proteger la información almacenada '
//                             'y evitar accesos no autorizados. Sin embargo, '
//                             'ningún sistema conectado a Internet puede '
//                             'garantizar una seguridad absoluta.',
//                             style: TextStyle(
//                               fontSize: 15,
//                               height: 1.5,
//                               color: Colors.black87,
//                             ),
//                           ),

//                           SizedBox(height: 20),

//                           Text(
//                             '5. Responsabilidad del usuario',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),

//                           SizedBox(height: 8),

//                           Text(
//                             'El usuario es responsable de mantener '
//                             'la confidencialidad de sus credenciales '
//                             'de acceso y de todas las actividades '
//                             'realizadas desde su cuenta.',
//                             style: TextStyle(
//                               fontSize: 15,
//                               height: 1.5,
//                               color: Colors.black87,
//                             ),
//                           ),

//                           SizedBox(height: 20),

//                           Text(
//                             '6. Aceptación',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),

//                           SizedBox(height: 8),

//                           Text(
//                             'Al registrarse y utilizar JAMIKA PET, '
//                             'el usuario declara haber leído y aceptado '
//                             'estos términos y condiciones.',
//                             style: TextStyle(
//                               fontSize: 15,
//                               height: 1.5,
//                               color: Colors.black87,
//                             ),
//                           ),

//                         ],
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 15),

//                   // BOTÓN CERRAR
//                   SizedBox(
//                     width: double.infinity,
//                     height: 48,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             const Color(0xFF4FC3B8),
//                         shape: RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.circular(15),
//                         ),
//                       ),
//                       child: const Text(
//                         'Cerrar',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

class TermsModal {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 750,
              maxHeight: 700,
            ),
            child: Column(
              children: [

                // ==========================================
                // ENCABEZADO
                // ==========================================

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    20,
                    12,
                    10,
                  ),
                  child: Row(
                    children: [

                      const Icon(
                        Icons.description_outlined,
                        color: Color(0xFF4FC3B8),
                        size: 30,
                      ),

                      const SizedBox(width: 10),

                      const Expanded(
                        child: Text(
                          'Términos y condiciones',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(
                  height: 1,
                ),

                // ==========================================
                // CONTENIDO HTML
                // ==========================================

                Expanded(
                  child: FutureBuilder<String>(
                    future: rootBundle.loadString(
                      'assets/documents/politica_privacidad.html',
                    ),

                    builder: (
                      context,
                      snapshot,
                    ) {

                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF4FC3B8),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'No se pudo cargar la política de privacidad.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24),

                        child: Html(
                          data: snapshot.data ?? '',
                        ),
                      );
                    },
                  ),
                ),

                // ==========================================
                // BOTÓN CERRAR
                // ==========================================

                Padding(
                  padding: const EdgeInsets.all(16),

                  child: SizedBox(
                    width: double.infinity,
                    height: 48,

                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF4FC3B8),

                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                      ),

                      child: const Text(
                        'Cerrar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
