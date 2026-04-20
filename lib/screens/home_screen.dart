import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/theme_service.dart';
import '../services/database_service.dart';
import '../models/habit_model.dart';
import '../widgets/state_widgets.dart';
import 'habit_detail_screen.dart';
import 'settings_screen.dart';
import 'focus_hub_screen.dart';
import 'add_habit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : AppColors.primaryLighter,
      appBar: AppBar(
        title: const Text('Sanctuary'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDailyProgress(),
            const SizedBox(height: 24),
            _buildFocusHubPrompt(context),
            const SizedBox(height: 32),
            Text(
              'Habit Mascots',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildHabitsGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusHubPrompt(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FocusHubScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.bgSky,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.primaryLight.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? theme.cardTheme.color : Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.center_focus_strong_rounded, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Focus Hub',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Deep focus with your mascots and music.',
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyProgress() {
    return StreamBuilder<List<HabitModel>>(
      stream: DatabaseService().habitsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SizedBox.shrink(); // Hide progress if error, grid will show error
        }

        final habits = snapshot.data ?? [];
        final completedCount = habits.where((h) => h.isCompletedToday).length;
        final totalCount = habits.length;
        final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

        if (totalCount == 0 && snapshot.connectionState != ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Goal',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedCount of $totalCount habits',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You\'re doing great!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildHabitsGrid(BuildContext context) {
    return StreamBuilder<List<HabitModel>>(
      stream: DatabaseService().habitsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: AppLoadingWidget(message: 'Loading your sanctuary...'),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: AppErrorWidget(
              message: 'Failed to load habits: ${snapshot.error}',
              onRetry: () {
                // StreamBuilder will automatically rebuild and retry if the stream is recreated or updated
                // but for a stream, it's already listening. We can trigger a rebuild.
                (context as Element).markNeedsBuild();
              },
            ),
          );
        }
        final habits = snapshot.data ?? [];
        if (habits.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: AppEmptyStateWidget(
              title: 'No Mascots Yet',
              message: 'Your sanctuary is quiet. Add a habit to bring it to life!',
              icon: Icons.pets_rounded,
              actionLabel: 'Add Your First Habit',
              onAction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddHabitScreen()),
                );
              },
            ),
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];
            return _buildHabitMascotCard(context, habit);
          },
        );
      },
    );
  }

  Widget _buildHabitMascotCard(BuildContext context, HabitModel habit) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;
    return GestureDetector(
      onDoubleTap: () async {
        if (!habit.isCompletedToday) {
          final result = await DatabaseService().completeHabit(habit.id);
          if (context.mounted) {
            if (result.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${habit.name} completed! +50 XP'),
                  duration: const Duration(seconds: 1),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to complete habit: ${result.error?.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      },
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: habit)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.bgLavender,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Lvl ${habit.mascotLevel}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const Spacer(),
            Text(
              HabitModel.mascotToEmoji(habit.mascot),
              style: const TextStyle(fontSize: 48),
            ),
            const Spacer(),
            Text(
              habit.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: habit.progress / 100,
                minHeight: 6,
                backgroundColor: isDark ? AppColors.darkSurface : AppColors.primaryLighter,
                valueColor: AlwaysStoppedAnimation<Color>(
                  habit.isCompletedToday ? AppColors.primary : AppColors.primaryLight,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Streak',
                  style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey),
                ),
                Text(
                  '${habit.streak}d',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
