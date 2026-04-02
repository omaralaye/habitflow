import 'package:flutter/material.dart';
import 'filter_tabs.dart';
import 'progress_card.dart';
import 'weekly_progress.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Streaks',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          const FilterTabs(),
          const SizedBox(height: 24),
          const ProgressCard(),
          const SizedBox(height: 16),
          const WeeklyProgress(),
        ],
      ),
    );
  }
}
