import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/mock_data_service.dart';
import '../models/habit_model.dart';
import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';

class HabitListScreen extends StatelessWidget {
  const HabitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLighter,
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
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildCategorySection(context, 'Mindfulness', MockDataService.habits.where((h) => h.category == 'Mindfulness').toList()),
          const SizedBox(height: 24),
          _buildCategorySection(context, 'Health', MockDataService.habits.where((h) => h.category == 'Health').toList()),
          const SizedBox(height: 24),
          _buildCategorySection(context, 'Learning', MockDataService.habits.where((h) => h.category == 'Learning').toList()),
        ],
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, String title, List<HabitModel> habits) {
    if (habits.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),
        ...habits.map((habit) => _buildHabitItem(context, habit)).toList(),
      ],
    );
  }

  Widget _buildHabitItem(BuildContext context, HabitModel habit) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HabitDetailScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
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
                color: MockDataService.getPastelColorForMascot(habit.mascot),
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded, size: 14, color: Colors.orange.shade800),
                      const SizedBox(width: 4),
                      Text(
                        '${habit.streak} day streak',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textGrey,
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
                color: habit.isCompletedToday ? AppColors.accentGreen : AppColors.bgMint,
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
