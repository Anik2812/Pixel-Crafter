import 'package:flutter/material.dart';
import 'package:replica/constants/colors.dart';
import 'package:replica/constants/text_styles.dart';

class ColorPickerButton extends StatelessWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorChanged;
  final String label;

  const ColorPickerButton({
    super.key,
    required this.currentColor,
    required this.onColorChanged,
    this.label = 'Color',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMediumDark),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            _showColorPickerDialog(context);
          },
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: currentColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderColorDark),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '#${currentColor.value.toRadixString(16).substring(2).toUpperCase()}',
              style: AppTextStyles.bodySmallDark.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _showColorPickerDialog(BuildContext context) {
    Color tempColor = currentColor;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.surfaceLight,
          title: Text(
            'Select Color',
            style: Theme.of(context).brightness == Brightness.dark
                ? AppTextStyles.headlineSmallDark
                : AppTextStyles.headlineSmall,
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    for (Color color in Colors.primaries)
                      GestureDetector(
                        onTap: () {
                          tempColor = color;
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.borderColorDark
                                    : AppColors.borderColorLight,
                                width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: Theme.of(context).brightness == Brightness.dark
                    ? AppTextStyles.bodyMediumDark
                        .copyWith(color: AppColors.textSecondaryDark)
                    : AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondaryLight),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Apply',
                style: Theme.of(context).brightness == Brightness.dark
                    ? AppTextStyles.bodyMediumDark
                        .copyWith(color: AppColors.primaryBlue)
                    : AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.primaryBlue),
              ),
              onPressed: () {
                onColorChanged(tempColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
