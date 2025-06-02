import 'package:flutter/material.dart';
import 'package:replica/constants/colors.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final List<Color> gradientColors;
  final double height;
  final double borderRadius;
  final TextStyle? textStyle;
  final bool isEnabled;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradientColors = const [AppColors.primaryBlue, AppColors.accentPurple],
    this.height = 50,
    this.borderRadius = 12,
    this.textStyle,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradientColors = isEnabled
        ? gradientColors
        : [Colors.grey.shade400, Colors.grey.shade600];
    final effectiveOnPressed = isEnabled ? onPressed : null;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: effectiveGradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: effectiveGradientColors[0].withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: effectiveOnPressed,
          child: Center(
            child: Text(
              text,
              style: textStyle ??
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
