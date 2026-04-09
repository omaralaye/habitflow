import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/theme_service.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart';
import '../models/habit_model.dart';
import 'add_habit_screen.dart';
import '../services/notification_service.dart';

class HabitDetailScreen extends StatefulWidget {
  final HabitModel habit;
  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Future<String>? _mascotWisdomFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _mascotWisdomFuture = AIService().getMascotInsight(widget.habit);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.habit.name),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddHabitScreen(habit: widget.habit)),
              ).then((_) {
                // Refresh state if habit was updated
                setState(() {});
              });
            },
            icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
          ),
          IconButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Habit'),
                  content: const Text('Are you sure you want to delete this habit?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await NotificationService().cancelHabitReminders(widget.habit.id);
                await DatabaseService().deleteHabit(widget.habit.id);
                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.primary,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.textGrey,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Mascot'),
                  Tab(text: 'Streaks'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMascotTab(),
                _buildStreaksTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMascotTab() {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;

    return StreamBuilder<List<HabitModel>>(
      stream: DatabaseService().habitsStream,
      builder: (context, snapshot) {
        final habits = snapshot.data ?? [];
        final habit = habits.firstWhere((h) => h.id == widget.habit.id, orElse: () => widget.habit);

        return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? theme.cardTheme.color : HabitModel.getPastelColorForMascot(widget.habit.mascot),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              children: [
                Text(
                  HabitModel.mascotToEmoji(habit.mascot),
                  style: const TextStyle(fontSize: 120),
                ),
                const SizedBox(height: 24),
                Text(
                  '${habit.mascot.name.toUpperCase()} LVL ${habit.mascotLevel}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 32),
                _buildEvolutionProgress(habit),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildMascotStatus(habit),
        ],
      ),
    );
      },
    );
  }

  Widget _buildEvolutionProgress(HabitModel habit) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;

    // Calculate evolution progress based on mascot level (mock logic: level 1-5)
    // If progress is not available, use habit progress as fallback
    final double evolutionProgress = (habit.progress / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'EVOLUTION PROGRESS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              '${(evolutionProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: evolutionProgress,
            minHeight: 12,
            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          evolutionProgress >= 0.9
              ? 'Your ${habit.mascot.name} is about to evolve!'
              : 'Keep going to evolve your ${habit.mascot.name}!',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildMascotStatus(HabitModel habit) {
    final isDark = ThemeService().isDarkMode;
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? theme.cardTheme.color : AppColors.primaryLighter,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Your ${habit.mascot.name.toLowerCase()} is feeling energized today because of your consistent ${habit.name.toLowerCase()} practice!',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildMascotWisdom(habit),
      ],
    );
  }

  Widget _buildMascotWisdom(HabitModel habit) {
    final isDark = ThemeService().isDarkMode;
    final theme = Theme.of(context);

    return FutureBuilder<String>(
      future: _mascotWisdomFuture,
      builder: (context, snapshot) {
        final insight = snapshot.data ?? 'Reflecting on your journey...';
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.darkSurface, AppColors.darkCard]
                  : [AppColors.primary.withOpacity(0.1), AppColors.primaryLight.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.psychology_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Mascot\'s Wisdom',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  if (isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                insight,
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStreaksTab() {
    final theme = Theme.of(context);

    return StreamBuilder<List<HabitModel>>(
      stream: DatabaseService().habitsStream,
      builder: (context, snapshot) {
        final habits = snapshot.data ?? [];
        final habit = habits.firstWhere((h) => h.id == widget.habit.id, orElse: () => widget.habit);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStreakSummary(habit),
              const SizedBox(height: 24),
          Text(
            'Weekly History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
              _buildWeeklyHistory(habit),
              const SizedBox(height: 24),
              _buildBestStreaks(habit),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStreakSummary(HabitModel habit) {
    // Current streak is already in habit.streak

    // Calculate Best Streak and Total Done from completedDays
    // Note: Best streak logic could be more complex, but we'll use a simple approximation if full history isn't tracked yet
    final int totalDone = habit.completedDays.length;
    final int bestStreak = habit.streak; // Simplified: Using current streak as best for now or could calculate from history

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStreakStat('Current', '${habit.streak}', 'days'),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStreakStat('Best', '$bestStreak', 'days'),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStreakStat('Total', '$totalDone', 'done'),
        ],
      ),
    );
  }

  Widget _buildStreakStat(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildWeeklyHistory(HabitModel habit) {
    final daysLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final isDark = ThemeService().isDarkMode;
    final theme = Theme.of(context);

    // Get dates for the last 7 days (ending today)
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    // Create a set of formatted strings for comparison
    final completedDatesStrings = habit.completedDays
        .map((d) => "${d.year}-${d.month}-${d.day}")
        .toSet();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.cardTheme.color : AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          final date = last7Days[index];
          final dateStr = "${date.year}-${date.month}-${date.day}";
          final isCompleted = completedDatesStrings.contains(dateStr);

          return Column(
            children: [
              Text(
                daysLabels[date.weekday - 1],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.primary : (isDark ? AppColors.darkSurface : Colors.white),
                  shape: BoxShape.circle,
                ),
                child: isCompleted
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                    : null,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBestStreaks(HabitModel habit) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? theme.cardTheme.color : AppColors.bgSky,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded, color: AppColors.primary, size: 32),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.streak > 0 ? 'Best Streak!' : 'New Journey!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  habit.streak > 0
                    ? 'Your current ${habit.name.toLowerCase()} streak is ${habit.streak} days. Keep it going!'
                    : 'Start your ${habit.name.toLowerCase()} journey today and build your first streak!',
                  style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
