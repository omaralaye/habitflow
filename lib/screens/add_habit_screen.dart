import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/theme_service.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart';
import '../models/habit_model.dart';
import '../models/music_model.dart';
import '../widgets/main_navigation.dart';
import '../services/notification_service.dart';

class AddHabitScreen extends StatefulWidget {
  final HabitModel? habit;
  final bool isFirstHabit;
  const AddHabitScreen({super.key, this.habit, this.isFirstHabit = false});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController _nameController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _musicSectionKey = GlobalKey();

  MascotType _selectedMascot = MascotType.panda;
  String _selectedCategory = 'General';
  String? _selectedMusicId;
  bool _isStartReminderEnabled = false;
  TimeOfDay _selectedStartTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isEndReminderEnabled = true;
  TimeOfDay _selectedEndTime = const TimeOfDay(hour: 9, minute: 0);

  final List<String> _categories = ['Mindfulness', 'Health', 'Studying', 'Workout', 'Productivity', 'General'];
  final DatabaseService _databaseService = DatabaseService();
  bool _isRefining = false;
  Future<List<MusicModel>>? _musicTracksFuture;

  @override
  void initState() {
    super.initState();
    _musicTracksFuture = _databaseService.getMusicTracks();
    if (widget.habit != null) {
      _nameController.text = widget.habit!.name;
      _selectedMascot = widget.habit!.mascot;
      _selectedCategory = widget.habit!.category;
      _selectedMusicId = widget.habit!.musicId;
      _isStartReminderEnabled = widget.habit!.startReminderEnabled;
      _selectedStartTime = widget.habit!.startReminderTime ?? const TimeOfDay(hour: 8, minute: 0);
      _isEndReminderEnabled = widget.habit!.endReminderEnabled;
      _selectedEndTime = widget.habit!.endReminderTime ?? const TimeOfDay(hour: 9, minute: 0);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refineHabitName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isRefining = true);
    final result = await AIService().refineAndCategorize(name);

    if (mounted) {
      if (result.isSuccess) {
        final data = result.data!;
        setState(() {
          _nameController.text = data['refinedName'] ?? name;
          _selectedCategory = data['category'] ?? 'General';
          _selectedMusicId = null; // Reset music when category changes
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI suggested the "${data['category']}" category and updated your tracks!'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Delay to allow UI to update before scrolling to music section
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && _musicSectionKey.currentContext != null) {
            Scrollable.ensureVisible(
              _musicSectionKey.currentContext!,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI suggestion failed: ${result.error?.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isRefining = false);
    }
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
        automaticallyImplyLeading: !widget.isFirstHabit,
        leading: widget.isFirstHabit
            ? null
            : IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close_rounded, color: theme.appBarTheme.titleTextStyle?.color),
              ),
        actions: [
          TextButton(
            onPressed: () async {
              final String name = _nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a habit name')),
                );
                return;
              }

              final habit = HabitModel(
                id: widget.habit?.id ?? '',
                name: name,
                color: HabitModel.getPastelColorForMascot(_selectedMascot),
                streak: widget.habit?.streak ?? 0,
                completedDays: widget.habit?.completedDays ?? [],
                mascot: _selectedMascot,
                mascotLevel: widget.habit?.mascotLevel ?? 1,
                progress: widget.habit?.progress ?? 0,
                category: _selectedCategory,
                isCompletedToday: widget.habit?.isCompletedToday ?? false,
                musicId: _selectedMusicId,
                startReminderEnabled: _isStartReminderEnabled,
                startReminderTime: _selectedStartTime,
                endReminderEnabled: _isEndReminderEnabled,
                endReminderTime: _selectedEndTime,
              );

              HabitModel? savedHabit;
              bool success = false;
              String? errorMessage;

              if (isEditing) {
                final result = await _databaseService.updateHabit(habit);
                if (result.isSuccess) {
                  savedHabit = habit;
                  success = true;
                } else {
                  errorMessage = result.error?.message;
                }
              } else {
                final result = await _databaseService.addHabit(habit);
                if (result.isSuccess) {
                  savedHabit = result.data;
                  success = true;
                } else {
                  errorMessage = result.error?.message;
                }
              }

              if (success) {
                if (savedHabit != null) {
                  // Schedule notification with the correct ID
                  await NotificationService().scheduleHabitReminders(savedHabit);
                }

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEditing ? 'Habit updated successfully' : 'Habit created successfully'),
                    duration: const Duration(seconds: 2),
                  ),
                );
                if (widget.isFirstHabit) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainNavigation()),
                    (route) => false,
                  );
                } else {
                  Navigator.pop(context);
                }
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $errorMessage'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
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
        controller: _scrollController,
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
                suffixIcon: IconButton(
                  onPressed: _isRefining ? null : _refineHabitName,
                  icon: _isRefining
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        )
                      : const Icon(Icons.auto_fix_high_rounded, color: AppColors.primary),
                  tooltip: 'Refine with AI',
                ),
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
              key: _musicSectionKey,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildMusicSelector(),
            const SizedBox(height: 32),
            _buildReminderSection(
              title: 'Start Habit Reminder',
              subtitle: 'Get notified when it\'s time to start your habit.',
              isEnabled: _isStartReminderEnabled,
              time: _selectedStartTime,
              onToggle: (val) => setState(() => _isStartReminderEnabled = val),
              onTimeChanged: (time) => setState(() => _selectedStartTime = time),
            ),
            const SizedBox(height: 16),
            _buildReminderSection(
              title: 'End Habit Reminder',
              subtitle: 'Get notified when it\'s time to wrap up your habit.',
              isEnabled: _isEndReminderEnabled,
              time: _selectedEndTime,
              onToggle: (val) => setState(() => _isEndReminderEnabled = val),
              onTimeChanged: (time) => setState(() => _selectedEndTime = time),
            ),
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
                HabitModel.mascotToEmoji(mascot),
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
    final isDark = ThemeService().isDarkMode;
    final theme = Theme.of(context);

    return FutureBuilder<List<MusicModel>>(
      future: _musicTracksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final allMusic = snapshot.data ?? [];
        var musicTracks = allMusic.where((track) => track.category == _selectedCategory).toList();
        bool isFallback = false;

        if (musicTracks.isEmpty && _selectedCategory != 'General') {
          musicTracks = allMusic.where((track) => track.category == 'General').toList();
          isFallback = true;
        }

        if (musicTracks.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'No music tracks available at the moment.',
              style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isFallback)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No tracks found for $_selectedCategory. Showing general tracks.',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ListView.separated(
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
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : (isDark ? AppColors.darkSurface : AppColors.primaryLighter),
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
            ),
          ],
        );
      },
    );
  }

  Widget _buildReminderSection({
    required String title,
    required String subtitle,
    required bool isEnabled,
    required TimeOfDay time,
    required Function(bool) onToggle,
    required Function(TimeOfDay) onTimeChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.cardTheme.color : AppColors.bgSky,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_rounded, color: AppColors.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: (val) async {
                  if (val) {
                    final granted = await NotificationService().requestPermissions();
                    if (!granted && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notification permissions are required for reminders.')),
                      );
                      return;
                    }
                  }
                  onToggle(val);
                },
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
          if (isEnabled) ...[
            const Divider(height: 32),
            InkWell(
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: time,
                );
                if (picked != null && picked != time) {
                  onTimeChanged(picked);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reminder Time',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
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
          ],
        ],
      ),
    );
  }
}
