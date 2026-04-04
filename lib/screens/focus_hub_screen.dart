import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/theme_service.dart';
import '../services/mock_data_service.dart';
import '../models/habit_model.dart';
import '../models/music_model.dart';
import '../widgets/shared/signed_in_badge.dart';

class FocusHubScreen extends StatefulWidget {
  const FocusHubScreen({super.key});

  @override
  State<FocusHubScreen> createState() => _FocusHubScreenState();
}

class _FocusHubScreenState extends State<FocusHubScreen> {
  HabitModel? _selectedHabit;
  MusicModel? _selectedMusic;
  bool _isFocusing = false;
  double _focusProgress = 0.0;

  @override
  void initState() {
    super.initState();
    if (MockDataService.habits.isNotEmpty) {
      _selectedHabit = MockDataService.habits.first;
      if (_selectedHabit!.musicId != null) {
        _selectedMusic = MockDataService.musicTracks.firstWhere(
          (m) => m.id == _selectedHabit!.musicId,
          orElse: () => MockDataService.musicTracks.first,
        );
      } else {
        _selectedMusic = MockDataService.musicTracks.first;
      }
    }
  }

  void _toggleFocus() {
    setState(() {
      _isFocusing = !_isFocusing;
      if (_isFocusing) {
        _focusProgress = 0.45; // Simulating some progress
      } else {
        _focusProgress = 0.0;
      }
    });
  }

  void _nextTrack() {
    if (_selectedMusic == null) return;
    final currentIndex = MockDataService.musicTracks.indexWhere((m) => m.id == _selectedMusic!.id);
    final nextIndex = (currentIndex + 1) % MockDataService.musicTracks.length;
    setState(() {
      _selectedMusic = MockDataService.musicTracks[nextIndex];
    });
  }

  void _previousTrack() {
    if (_selectedMusic == null) return;
    final currentIndex = MockDataService.musicTracks.indexWhere((m) => m.id == _selectedMusic!.id);
    final prevIndex = (currentIndex - 1 + MockDataService.musicTracks.length) % MockDataService.musicTracks.length;
    setState(() {
      _selectedMusic = MockDataService.musicTracks[prevIndex];
    });
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Focus Hub'),
        content: const Text(
          'The Focus Hub is your dedicated space for deep work. '
          'Choose a habit mascot to accompany you and pick some soothing ambient music '
          'to help you stay in the flow.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : AppColors.primaryLighter,
      appBar: AppBar(
        title: const Text('Focus Hub'),
        actions: [
          const SignedInBadge(),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _showInfoDialog,
            icon: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFocusCard(),
            const SizedBox(height: 32),
            Text(
              'Habit Selection',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildHabitSelector(),
            const SizedBox(height: 32),
            Text(
              'Ambient Sanctuary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildMusicPlayer(),
            const SizedBox(height: 32),
            _buildQuickStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusCard() {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: _focusProgress,
                  strokeWidth: 12,
                  backgroundColor: isDark ? AppColors.darkSurface : AppColors.primaryLighter,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isFocusing ? AppColors.primary : AppColors.primaryLight,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedHabit != null
                        ? MockDataService.mascotToEmoji(_selectedHabit!.mascot)
                        : '🧘',
                    style: const TextStyle(fontSize: 80),
                  ),
                  if (_isFocusing)
                    const Text(
                      'FOCUSING...',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 2,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            _selectedHabit?.name ?? 'Select a Habit',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isFocusing ? 'Keep it up, you\'re doing great!' : 'Ready to start your session?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _toggleFocus,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isFocusing ? AppColors.secondary : AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Text(
              _isFocusing ? 'Stop Session' : 'Start Focus',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitSelector() {
    final theme = Theme.of(context);

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: MockDataService.habits.length,
        itemBuilder: (context, index) {
          final habit = MockDataService.habits[index];
          final isSelected = _selectedHabit?.id == habit.id;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedHabit = habit;
                if (habit.musicId != null) {
                  _selectedMusic = MockDataService.musicTracks.firstWhere(
                    (m) => m.id == habit.musicId,
                    orElse: () => _selectedMusic!,
                  );
                }
              });
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : theme.cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    MockDataService.mascotToEmoji(habit.mascot),
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    habit.name,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMusicPlayer() {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.bgSky,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.music_note_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedMusic?.title ?? 'No Music Selected',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  _selectedMusic?.artist ?? 'Select a track',
                  style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _previousTrack,
            icon: const Icon(Icons.skip_previous_rounded, color: AppColors.textGrey),
          ),
          IconButton(
            onPressed: _toggleFocus,
            icon: Icon(
              _isFocusing ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          IconButton(
            onPressed: _nextTrack,
            icon: const Icon(Icons.skip_next_rounded, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Current Streak',
            '${_selectedHabit?.streak ?? 0} days',
            Icons.local_fire_department_rounded,
            Colors.orange.shade800,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Mascot Level',
            'Lvl ${_selectedHabit?.mascotLevel ?? 1}',
            Icons.auto_awesome_rounded,
            AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color iconColor) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}
