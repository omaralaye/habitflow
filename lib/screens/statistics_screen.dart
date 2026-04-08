import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/theme_service.dart';
import '../services/database_service.dart';
import '../models/habit_model.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : AppColors.primaryLighter,
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing your progress...')),
              );
            },
            icon: const Icon(Icons.share_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: DatabaseService().statsStream,
        builder: (context, snapshot) {
          final stats = snapshot.data ?? {};
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildOverview(context, stats),
                const SizedBox(height: 24),
                _buildWeeklyStats(context, stats),
                const SizedBox(height: 24),
                _buildHabitBreakdown(context),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildOverview(BuildContext context, Map<String, dynamic> stats) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;
    final int successRate = stats['successRate'] ?? 0;
    final int totalDone = stats['totalDone'] ?? 0;
    final int activeHabits = stats['activeHabits'] ?? 0;
    final int perfectDays = stats['perfectDays'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Text(
            'Overall Progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: successRate / 100,
                  strokeWidth: 16,
                  backgroundColor: isDark ? AppColors.darkSurface : AppColors.primaryLighter,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                children: [
                  Text(
                    '$successRate%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Success Rate',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSimpleStat(context, '$totalDone', 'Total Done'),
              Container(width: 1, height: 30, color: isDark ? AppColors.darkSurface : AppColors.primaryLighter),
              _buildSimpleStat(context, '$activeHabits', 'Active Habits'),
              Container(width: 1, height: 30, color: isDark ? AppColors.darkSurface : AppColors.primaryLighter),
              _buildSimpleStat(context, '$perfectDays', 'Perfect Days'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyStats(BuildContext context, Map<String, dynamic> stats) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;
    final List<int> values = stats['weeklyCompletions']?.cast<int>() ?? List.filled(7, 0);
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    // Map days based on current day
    final now = DateTime.now();
    final List<String> last7Days = [];
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      last7Days.add(days[date.weekday - 1]);
    }

    final maxVal = values.isEmpty ? 1 : values.reduce((curr, next) => curr > next ? curr : next);
    final double chartHeight = 120.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final val = values[index];
              final height = maxVal == 0 ? 0.0 : (val / maxVal) * chartHeight;
              return Column(
                children: [
                  Container(
                    width: 24,
                    height: height.clamp(4.0, chartHeight),
                    decoration: BoxDecoration(
                      color: index == 6 ? AppColors.primaryLight : AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    last7Days[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitBreakdown(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;
    return StreamBuilder<List<HabitModel>>(
      stream: DatabaseService().habitsStream,
      builder: (context, snapshot) {
        final habits = snapshot.data ?? [];
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Habit Performance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              ...habits.map((habit) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          habit.name,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                        ),
                        Text(
                          '${habit.progress}%',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: habit.progress / 100,
                        minHeight: 10,
                        backgroundColor: isDark ? AppColors.darkSurface : AppColors.primaryLighter,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }
}
