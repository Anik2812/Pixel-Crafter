import 'package:flutter/material.dart';
import 'package:replica/constants/colors.dart';
import 'package:replica/widgets/subscription_card.dart';
import 'package:replica/constants/text_styles.dart';

class SubscriptionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Choose Your Plan',
          style: AppTextStyles.headlineSmall
              .copyWith(color: AppColors.textPrimaryLight),
        ),
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Unlock powerful features for your design workflow.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 32),
            SubscriptionCard(
              title: 'Free Plan',
              price: '€0',
              billingCycle: '/month',
              features: const [
                'Limited projects (3 projects)',
                'Basic collaboration (2 editors)',
                'Community support',
                '1 GB cloud storage',
              ],
              isPopular: false,
              buttonText: 'Current Plan',
              buttonAction: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('You are already on the Free Plan!',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: Colors.white)),
                    backgroundColor: AppColors.primaryBlue,
                  ),
                );
              },
              isCurrentPlan: true,
            ),
            const SizedBox(height: 24),
            SubscriptionCard(
              title: 'Pro Plan',
              price: '€12',
              billingCycle: '/month',
              features: const [
                'Unlimited projects',
                'Advanced collaboration (Unlimited editors)',
                'Priority email support',
                'Version history (30 days)',
                '100 GB cloud storage',
                'Private plugins',
              ],
              isPopular: true,
              buttonText: 'Subscribe Now',
              buttonAction: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Subscribing to Pro Plan... (Simulated)',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: Colors.white)),
                    backgroundColor: AppColors.accentGreen,
                  ),
                );
                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.pushReplacementNamed(context, '/home');
                });
              },
            ),
            const SizedBox(height: 24),
            SubscriptionCard(
              title: 'Enterprise',
              price: 'Custom',
              billingCycle: '',
              features: const [
                'Custom integrations & SSO',
                'Dedicated account manager',
                'Advanced security controls',
                'Unlimited version history',
                'Custom training & onboarding',
                'On-premise deployment options',
              ],
              isPopular: false,
              buttonText: 'Contact Sales',
              buttonAction: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Contacting sales... (Simulated)',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: Colors.white)),
                    backgroundColor: AppColors.primaryBlue,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
