import 'package:flutter/material.dart';

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
                onTap: onTermsTap,
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
