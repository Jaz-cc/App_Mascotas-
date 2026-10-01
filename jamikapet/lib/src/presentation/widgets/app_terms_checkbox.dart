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
  Future<void> _abrirPoliticaPrivacidad() async {
    final Uri url = Uri.parse(urlPoliticaPrivacidad);

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
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
                onTap: onTermsTap ?? _abrirPoliticaPrivacidad,
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

