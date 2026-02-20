import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';

class InputPassword extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final Color fillColor;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final Color focusedBorderColor;
  final String? errorText; // <--- baru

  const InputPassword({
    super.key,
    required this.controller,
    this.hint = "Sandi",
    this.icon,
    this.fillColor = AppColors.background,
    this.borderRadius = AppSizes.r12,
    this.borderColor = AppColors.surface,
    this.borderWidth = 1.0,
    this.focusedBorderColor = AppColors.surface,
    this.errorText, // <--- baru
  });

  @override
  State<InputPassword> createState() => _InputPasswordState();
}

class _InputPasswordState extends State<InputPassword> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final bool hasError =
        widget.errorText != null && widget.errorText!.isNotEmpty;

    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle:
            GoogleFonts.roboto(color: hasError ? Colors.red : Colors.grey[600]),
        errorText: widget.errorText,
        prefixIcon: widget.icon != null
            ? Icon(widget.icon, color: hasError ? Colors.red : Colors.grey)
            : null,
        filled: true,
        fillColor: widget.fillColor,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
              color: hasError ? Colors.red : widget.borderColor,
              width: widget.borderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
              color: hasError ? Colors.red : widget.borderColor,
              width: widget.borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
              color: hasError ? Colors.red : widget.focusedBorderColor,
              width: widget.borderWidth),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off : Icons.visibility,
            color: hasError ? Colors.red : Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscure = !_obscure;
            });
          },
        ),
      ),
    );
  }
}
