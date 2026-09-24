import 'package:flutter/material.dart';

class AppTermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AppTermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        Checkbox(
          value: value,
          onChanged: (value) {
            onChanged(value ?? false);
          },
        ),

        const Expanded(
          child: Text(
            'Acepto los términos y condiciones de uso.',
          ),
        ),
      ],
    );
  }
}