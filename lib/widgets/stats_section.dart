import 'package:flutter/material.dart';
import 'filter_tabs.dart';
import 'progress_card.dart';
import 'weekly_progress.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Streaks',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          FilterTabs(),
          SizedBox(height: 24),
          ProgressCard(),
          SizedBox(height: 16),
          WeeklyProgress(),
        ],
      ),
    );
  }
}
