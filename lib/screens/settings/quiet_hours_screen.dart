import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../services/theme_service.dart';

class QuietHoursScreen extends StatefulWidget {
  const QuietHoursScreen({super.key});

  @override
  State<QuietHoursScreen> createState() => _QuietHoursScreenState();
}

class _QuietHoursScreenState extends State<QuietHoursScreen> {
  TimeOfDay _startTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 7, minute: 0);
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : AppColors.primaryLighter,
      appBar: AppBar(
        title: const Text('Quiet Hours'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pause notifications during your rest hours to maintain your peace.',
              style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Enable Quiet Hours',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Switch(
                        value: _enabled,
                        onChanged: (v) => setState(() => _enabled = v),
                        activeThumbColor: AppColors.primary,
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildTimePicker(
                    'Start Time',
                    _startTime,
                    (time) => setState(() => _startTime = time),
                  ),
                  const SizedBox(height: 16),
                  _buildTimePicker(
                    'End Time',
                    _endTime,
                    (time) => setState(() => _endTime = time),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'During quiet hours, all habit reminders and app notifications will be silenced.',
              style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, Function(TimeOfDay) onTimeChanged) {
    final isDark = ThemeService().isDarkMode;
    final theme = Theme.of(context);
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) onTimeChanged(picked);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                time.format(context),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
