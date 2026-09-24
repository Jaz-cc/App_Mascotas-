import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,

      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF55C5B9),
        foregroundColor: Colors.black,

        elevation: 0,

        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),

        minimumSize: const Size(96, 42),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
      ),

      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black,
              ),
            )
          : Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}