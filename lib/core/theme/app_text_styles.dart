import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_sizes.dart';

class AppTextStyles {
  static final TextStyle heading = GoogleFonts.roboto(
    fontSize: AppSizes.f24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final TextStyle body = GoogleFonts.roboto(
    fontSize: AppSizes.f16,
    color: AppColors.textPrimary,
  );

  static final TextStyle caption = GoogleFonts.roboto(
    fontSize: AppSizes.f14,
    color: AppColors.textSecondary,
  );
}
