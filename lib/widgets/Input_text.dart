import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';

class InputText extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final IconData? icon;
  final Color fillColor;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final Color focusedBorderColor;
  final String? errorText; // <--- baru

  const InputText({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.icon,
    this.fillColor = AppColors.background,
    this.borderRadius = AppSizes.r12,
    this.borderColor = AppColors.surface,
    this.borderWidth = 1.0,
    this.focusedBorderColor = AppColors.surface,
    this.errorText, // <--- baru
  });

  @override
  Widget build(BuildContext context) {
    final bool hasError = errorText != null && errorText!.isNotEmpty;
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.roboto(
          color: hasError ? Colors.red : Colors.grey[600],
        ),
        errorText: errorText,
        prefixIcon: icon != null
            ? Icon(icon, color: hasError ? Colors.red : Colors.grey)
            : null,
        filled: true,
        fillColor: fillColor,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
              color: hasError ? Colors.red : borderColor, width: borderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
              color: hasError ? Colors.red : borderColor, width: borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
              color: hasError ? Colors.red : focusedBorderColor,
              width: borderWidth),
        ),
      ),
    );
  }
}
