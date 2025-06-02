import 'package:flutter/material.dart';
import 'package:replica/constants/colors.dart';
import 'package:replica/constants/text_styles.dart';

class TextInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixIconPressed;

  const TextInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
    this.onSuffixIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style:
          AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryLight),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: AppTextStyles.labelMedium
            .copyWith(color: AppColors.textSecondaryLight),
        prefixIcon:
            icon != null ? Icon(icon, color: AppColors.primaryBlue) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: suffixIcon!,
                color: AppColors.textSecondaryLight,
                onPressed: onSuffixIconPressed,
              )
            : null,
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderColorLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentRed, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      ),
    );
  }
}
