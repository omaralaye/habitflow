import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/theme_service.dart';
import '../services/mock_data_service.dart';
import '../models/habit_model.dart';
import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';

class HabitListScreen extends StatelessWidget {
  const HabitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : AppColors.primaryLighter,
      appBar: AppBar(
        title: const Text('My Habits'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddHabitScreen()),
              );
            },
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Builder(
        builder: (context) {
          final habits = MockDataService.habits;
          if (habits.isEmpty) {
            return const Center(child: Text('No habits found. Add your first habit!'));
          }

          final categories = habits.map((h) => h.category).toSet().toList();

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategorySection(
                context,
                category,
                habits.where((h) => h.category == category).toList(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, String title, List<HabitModel> habits) {
    if (habits.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        ...habits.map((habit) => _buildHabitItem(context, habit)),
      ],
    );
  }

  Widget _buildHabitItem(BuildContext context, HabitModel habit) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: habit)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : MockDataService.getPastelColorForMascot(habit.mascot),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  MockDataService.mascotToEmoji(habit.mascot),
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded, size: 14, color: Colors.orange.shade800),
                      const SizedBox(width: 4),
                      Text(
                        '${habit.streak} day streak',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: habit.isCompletedToday ? AppColors.accentGreen : (isDark ? AppColors.darkSurface : AppColors.bgMint),
                shape: BoxShape.circle,
              ),
              child: Icon(
                habit.isCompletedToday ? Icons.check_rounded : Icons.add_rounded,
                color: habit.isCompletedToday ? Colors.white : AppColors.primaryLight,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
