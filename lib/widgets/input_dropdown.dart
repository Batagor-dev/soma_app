import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';

class InputDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final Function(String?) onChanged;
  final IconData? icon;
  final String? errorText;

  const InputDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasError = errorText != null && errorText!.isNotEmpty;

    return Container(
      width: double.infinity, // Memastikan container mengambil lebar penuh
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
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
          fillColor: AppColors.background,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12),
            borderSide: BorderSide(
                color: hasError ? Colors.red : AppColors.surface, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12),
            borderSide: BorderSide(
                color: hasError ? Colors.red : AppColors.surface, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12),
            borderSide: BorderSide(
                color: hasError ? Colors.red : AppColors.surface, width: 1),
          ),
        ),
        items: items,
        onChanged: onChanged,
        menuMaxHeight: 300,
        // Menambahkan properti ini untuk memastikan dropdown di bawah
        borderRadius: BorderRadius.circular(AppSizes.r12),
        // Menambahkan elevation untuk efek bayangan
        elevation: 8,
        // Menambahkan style untuk item dropdown
        dropdownColor: Colors.white,
        icon: Icon(
          Icons.arrow_drop_down,
          color: hasError ? Colors.red : Colors.grey,
        ),
      ),
    );
  }
}
