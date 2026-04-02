import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../utils/constants.dart';

class WeeklyProgress extends StatelessWidget {
  const WeeklyProgress({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          const isCompleted = true;
          final isToday = index == 2;
          return Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF4CAF50)
                      : (isDark ? AppColors.darkSurface : const Color(0xFFE8E8E8)),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                day,
                style: TextStyle(
                  fontSize: 12,
                  color: isToday ? const Color(0xFF9B59B6) : (isDark ? AppColors.darkTextSecondary : Colors.black54),
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
