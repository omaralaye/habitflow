import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/mock_data_service.dart';
import '../models/habit_model.dart';
import 'add_habit_screen.dart';

class HabitDetailScreen extends StatefulWidget {
  final HabitModel habit;
  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                color: AppColors.primaryLighter,
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
                unselectedLabelColor: AppColors.textGrey,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: MockDataService.getPastelColorForMascot(widget.habit.mascot),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              children: [
                Text(
                  MockDataService.mascotToEmoji(widget.habit.mascot),
                  style: const TextStyle(fontSize: 120),
                ),
                const SizedBox(height: 24),
                Text(
                  '${widget.habit.mascot.name.toUpperCase()} LVL ${widget.habit.mascotLevel}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 32),
                _buildEvolutionProgress(),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildMascotStatus(),
        ],
      ),
    );
  }

  Widget _buildEvolutionProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'EVOLUTION PROGRESS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textGrey,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              '75%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: const LinearProgressIndicator(
            value: 0.75,
            minHeight: 12,
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Keep going to evolve into a Giant Panda!',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textGrey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildMascotStatus() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Your ${widget.habit.mascot.name.toLowerCase()} is feeling energized today because of your consistent ${widget.habit.name.toLowerCase()} practice!',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreaksTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStreakSummary(),
          const SizedBox(height: 24),
          const Text(
            'Weekly History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildWeeklyHistory(),
          const SizedBox(height: 24),
          _buildBestStreaks(),
        ],
      ),
    );
  }

  Widget _buildStreakSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStreakStat('Current', '${widget.habit.streak}', 'days'),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStreakStat('Best', '28', 'days'),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStreakStat('Total', '156', 'done'),
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

  Widget _buildWeeklyHistory() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          final isCompleted = index < 5;
          return Column(
            children: [
              Text(
                days[index],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.primary : Colors.white,
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

  Widget _buildBestStreaks() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgSky,
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
                const Text(
                  'Best Streak!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your longest ${widget.habit.name.toLowerCase()} streak was 28 days back in July.',
                  style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
