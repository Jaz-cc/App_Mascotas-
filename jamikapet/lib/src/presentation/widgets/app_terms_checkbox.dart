import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jamikapet/src/core/constants/app_constants.dart';

class AppTermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onTermsTap;

  const AppTermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.onTermsTap,
  });

  // ============================================================
  // ABRIR POLÍTICA DE PRIVACIDAD
  // ============================================================
  Future<void> _abrirPoliticaPrivacidad(
    BuildContext context,
  ) async {
    final Uri url = Uri.parse(urlPoliticaPrivacidad);

    if (!url.hasScheme ||
        (url.scheme != 'https' && url.scheme != 'http') ||
        url.host.isEmpty) {
      debugPrint('URL de política de privacidad inválida: $url');
      return;
    }

    try {
      final bool abierto = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!abierto && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo abrir la política de privacidad.',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error al abrir la política: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al abrir el enlace.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: value,
          activeColor: const Color(0xFF4FC3B8),
          onChanged: (newValue) {
            onChanged(newValue ?? false);
          },
        ),

        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Acepto la ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),

              GestureDetector(
                onTap: onTermsTap ??
                    () => _abrirPoliticaPrivacidad(context),
                child: const Text(
                  'Política de Privacidad, Términos y Condiciones',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4FC3B8),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

