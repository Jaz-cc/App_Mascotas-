import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
                        child: Text(
                          snapshot.data ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
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
