import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../services/theme_service.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : AppColors.primaryLighter,
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
                'Terms and Conditions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Please read these terms and conditions carefully before using our service.',
                style: TextStyle(fontSize: 16, color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(context, '1. Acceptance of Terms'),
              Text(
                'By accessing or using our service, you agree to be bound by these terms. If you disagree with any part, you may not access the service.',
                style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle(context, '2. Intellectual Property'),
              Text(
                'The service and its original content, features, and functionality are and will remain the exclusive property of Habit Flow.',
                style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle(context, '3. Termination'),
              Text(
                'We may terminate or suspend access to our service immediately, without prior notice or liability, for any reason whatsoever.',
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
