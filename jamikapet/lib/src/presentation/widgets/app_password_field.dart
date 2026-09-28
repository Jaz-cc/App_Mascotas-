import 'package:flutter/material.dart';

class AppPasswordField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? errorText;
  final IconData? icon;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const AppPasswordField({
    super.key,
    required this.label,
    this.hint,
    this.errorText,
    this.icon,
    this.controller,
    this.onChanged,
  });

  @override
  State<AppPasswordField> createState() =>
      _AppPasswordFieldState();
}

class _AppPasswordFieldState
    extends State<AppPasswordField> {

  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      onChanged: widget.onChanged,

      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,

        prefixIcon: const Icon(
          Icons.lock_outline,
          color: Color(0xFF4FC3B8),
        ),

        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },

          icon: Icon(
            _obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,

            color: Colors.black,
            size: 27,
          ),
        ),

        filled: true,
        fillColor: const Color(0xFFF5F5F5),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 15,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFFA9DDD7),
            width: 5,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFFA9DDD7),
            width: 5,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFF66C9BF),
            width: 5,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 3,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 3,
          ),
        ),

        labelStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
        ),
      ),
    );
  }
}