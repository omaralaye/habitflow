import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../utils/constants.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF9B59B6),
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.spa,
              size: 40,
              color: Color(0xFF9B59B6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Meditation',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Take 10 minutes to practice mindfulness and meditation',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: ThemeService().isDarkMode ? AppColors.darkTextSecondary : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
