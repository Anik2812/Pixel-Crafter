import 'package:flutter/material.dart';
import 'package:replica/constants/colors.dart';
import 'package:replica/widgets/gradient_button.dart';
import 'package:replica/constants/text_styles.dart';

class SubscriptionCard extends StatelessWidget {
  final String title;
  final String price;
  final String billingCycle;
  final List<String> features;
  final bool isPopular;
  final String buttonText;
  final VoidCallback buttonAction;
  final bool isCurrentPlan;

  const SubscriptionCard({
    super.key,
    required this.title,
    required this.price,
    required this.billingCycle,
    required this.features,
    this.isPopular = false,
    required this.buttonText,
    required this.buttonAction,
    this.isCurrentPlan = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isPopular || isCurrentPlan
            ? [
                BoxShadow(
                  color: (isPopular
                          ? AppColors.primaryBlue
                          : AppColors.accentGreen)
                      .withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.shadowColorLight,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
        border: isPopular
            ? Border.all(color: AppColors.primaryBlue, width: 2)
            : isCurrentPlan
                ? Border.all(color: AppColors.accentGreen, width: 2)
                : null,
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.headlineMedium
                    .copyWith(color: AppColors.textPrimaryLight),
              ),
              if (isPopular)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Popular',
                    style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )
              else if (isCurrentPlan)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Current Plan',
                    style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: AppTextStyles.displayLarge.copyWith(
                  color: isCurrentPlan
                      ? AppColors.accentGreen
                      : AppColors.primaryBlue,
                ),
              ),
              if (billingCycle.isNotEmpty)
                Text(
                  billingCycle,
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.textSecondaryLight),
                ),
            ],
          ),
          const SizedBox(height: 20),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: AppColors.primaryBlue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        feature,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textPrimaryLight),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 32),
          GradientButton(
            text: buttonText,
            onPressed: buttonAction,
            isEnabled: !isCurrentPlan,
            gradientColors: isCurrentPlan
                ? [
                    AppColors.accentGreen.withOpacity(0.8),
                    AppColors.accentGreen.withOpacity(0.6)
                  ]
                : isPopular
                    ? [AppColors.primaryBlue, AppColors.accentPurple]
                    : [
                        AppColors.primaryBlue.withOpacity(0.8),
                        AppColors.primaryBlue.withOpacity(0.6)
                      ],
          ),
        ],
      ),
    );
  }
}
