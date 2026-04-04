import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/theme_service.dart';
import '../services/mock_data_service.dart';
import '../models/habit_model.dart';

class AddHabitScreen extends StatefulWidget {
  final HabitModel? habit;
  const AddHabitScreen({super.key, this.habit});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController _nameController = TextEditingController();
  MascotType _selectedMascot = MascotType.panda;
  String _selectedCategory = 'General';
  String? _selectedMusicId;
  bool _isReminderEnabled = true;

  final List<String> _categories = ['Mindfulness', 'Health', 'Learning', 'Productivity', 'General'];

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _nameController.text = widget.habit!.name;
      _selectedMascot = widget.habit!.mascot;
      _selectedCategory = widget.habit!.category;
      _selectedMusicId = widget.habit!.musicId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.habit != null;
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Habit' : 'Add Habit'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close_rounded, color: theme.appBarTheme.titleTextStyle?.color),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // For now, just show a message since we're using mock data
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEditing ? 'Habit updated (mock data)' : 'Habit created (mock data)'),
                  duration: const Duration(seconds: 2),
                ),
              );
              Navigator.pop(context);
            },
            child: Text(
              isEditing ? 'Save' : 'Create',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habit Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'e.g. Morning Meditation',
                hintStyle: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : AppColors.primaryLighter,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Choose a Mascot',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildMascotGrid(),
            const SizedBox(height: 32),
            Text(
              'Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildCategorySelector(),
            const SizedBox(height: 32),
            Text(
              'Smoothing Music',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildMusicSelector(),
            const SizedBox(height: 32),
            _buildReminderSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMascotGrid() {
    final isDark = ThemeService().isDarkMode;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: MascotType.values.length,
      itemBuilder: (context, index) {
        final mascot = MascotType.values[index];
        final isSelected = mascot == _selectedMascot;
        return GestureDetector(
          onTap: () => setState(() => _selectedMascot = mascot),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : (isDark ? AppColors.darkSurface : AppColors.primaryLighter),
              borderRadius: BorderRadius.circular(16),
              border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
            ),
            child: Center(
              child: Text(
                MockDataService.mascotToEmoji(mascot),
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategorySelector() {
    final isDark = ThemeService().isDarkMode;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((cat) {
        final isSelected = cat == _selectedCategory;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = cat;
              _selectedMusicId = null; // Reset music when category changes
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : (isDark ? AppColors.darkSurface : AppColors.primaryLighter),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              cat,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.textGrey),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMusicSelector() {
    final musicTracks = MockDataService.getMusicByCategory(_selectedCategory);
    final isDark = ThemeService().isDarkMode;
    final theme = Theme.of(context);

    if (musicTracks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.primaryLighter,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'No music tracks available for this category.',
          style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: musicTracks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final track = musicTracks[index];
        final isSelected = track.id == _selectedMusicId;
        return GestureDetector(
          onTap: () => setState(() => _selectedMusicId = track.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.1) : (isDark ? AppColors.darkSurface : AppColors.primaryLighter),
              borderRadius: BorderRadius.circular(16),
              border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.music_note_rounded : Icons.music_off_outlined,
                  color: isSelected ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.textGrey),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primary : theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        track.artist,
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
                Text(
                  track.duration,
                  style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReminderSection() {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.cardTheme.color : AppColors.bgSky,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_rounded, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Reminder',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '8:00 AM',
                  style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey),
                ),
              ],
            ),
          ),
          Switch(
            value: _isReminderEnabled,
            onChanged: (val) {
              setState(() {
                _isReminderEnabled = val;
              });
            },
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
