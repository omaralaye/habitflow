import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../services/theme_service.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : AppColors.primaryLighter,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Privacy Matters',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'At Habit Flow, we are committed to protecting your privacy. This policy outlines how we handle your data.',
                style: TextStyle(fontSize: 16, color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(context, '1. Data Collection'),
              Text(
                'We collect information you provide directly to us, such as your email address and habit tracking data.',
                style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle(context, '2. Use of Information'),
              Text(
                'Your data is used to provide, maintain, and improve our services, as well as to develop new features.',
                style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle(context, '3. Data Security'),
              Text(
                'We use industry-standard security measures to protect your personal information from unauthorized access.',
                style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
