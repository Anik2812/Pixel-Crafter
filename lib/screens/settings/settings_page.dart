import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:replica/main.dart';
import 'package:replica/constants/colors.dart';
import 'package:replica/constants/text_styles.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        title: Text(
          'Settings',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildSettingsSection(
            context,
            title: 'Appearance',
            children: [
              ListTile(
                title: Text(
                  'Dark Mode',
                  style: isDarkMode
                      ? AppTextStyles.bodyMediumDark
                      : AppTextStyles.bodyMedium,
                ),
                trailing: Switch(
                  value: themeNotifier.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeNotifier.toggleTheme();
                  },
                  activeColor: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          _buildSettingsSection(
            context,
            title: 'Account',
            children: [
              ListTile(
                title: Text('Edit Profile',
                    style: isDarkMode
                        ? AppTextStyles.bodyMediumDark
                        : AppTextStyles.bodyMedium),
                trailing: Icon(Icons.arrow_forward_ios,
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Edit Profile (Not Implemented)',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.white))),
                  );
                },
              ),
              ListTile(
                title: Text('Change Password',
                    style: isDarkMode
                        ? AppTextStyles.bodyMediumDark
                        : AppTextStyles.bodyMedium),
                trailing: Icon(Icons.arrow_forward_ios,
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Change Password (Not Implemented)',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.white))),
                  );
                },
              ),
            ],
          ),
          _buildSettingsSection(
            context,
            title: 'General',
            children: [
              ListTile(
                title: Text('Language',
                    style: isDarkMode
                        ? AppTextStyles.bodyMediumDark
                        : AppTextStyles.bodyMedium),
                trailing: Text('English',
                    style: isDarkMode
                        ? AppTextStyles.labelMediumDark
                        : AppTextStyles.labelMedium),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Language selection (Not Implemented)',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.white))),
                  );
                },
              ),
              ListTile(
                title: Text('Notifications',
                    style: isDarkMode
                        ? AppTextStyles.bodyMediumDark
                        : AppTextStyles.bodyMedium),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Notifications toggle (Not Implemented)',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: Colors.white))),
                    );
                  },
                  activeColor: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'App Version: 1.0.0',
              style: isDarkMode
                  ? AppTextStyles.labelSmallDark
                  : AppTextStyles.labelSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context,
      {required String title, required List<Widget> children}) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: isDarkMode
                ? AppTextStyles.headlineSmallDark
                : AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color:
                  isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? AppColors.shadowColorDark
                      : AppColors.shadowColorLight,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
