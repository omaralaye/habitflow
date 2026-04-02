import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../utils/constants.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _CircularProgressIndicator(),
          ),
          Expanded(
            child: _StreakCounter(),
          ),
        ],
      ),
    );
  }
}

class _CircularProgressIndicator extends StatelessWidget {
  const _CircularProgressIndicator();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;
    return Column(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 10,
                  backgroundColor: isDark ? AppColors.darkSurface : const Color(0xFFE8E8E8),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF9B59B6),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '7/7',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Best',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StreakCounter extends StatelessWidget {
  const _StreakCounter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          '7 days',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF9B59B6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Current Streak',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : Colors.black54,
          ),
        ),
      ],
    );
  }
}
