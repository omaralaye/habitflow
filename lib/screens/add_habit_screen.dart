import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/mock_data_service.dart';
import '../models/habit_model.dart';
import '../models/music_model.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController _nameController = TextEditingController();
  MascotType _selectedMascot = MascotType.panda;
  String _selectedCategory = 'General';
  String? _selectedMusicId;

  final List<String> _categories = ['Mindfulness', 'Health', 'Learning', 'Productivity', 'General'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Habit'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded, color: AppColors.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Create the new habit with the selected music
              final newHabit = HabitModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController.text.isEmpty ? 'New Habit' : _nameController.text,
                color: MockDataService.getPastelColorForMascot(_selectedMascot),
                streak: 0,
                completedDays: [],
                mascot: _selectedMascot,
                category: _selectedCategory,
                musicId: _selectedMusicId,
              );

              // In a real app, we would save this to a provider or database
              // For now, we'll just add it to our mock list and pop
              MockDataService.habits.add(newHabit);
              Navigator.pop(context);
            },
            child: const Text(
              'Create',
              style: TextStyle(
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
            const Text(
              'Habit Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g. Morning Meditation',
                filled: true,
                fillColor: AppColors.primaryLighter,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Choose a Mascot',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildMascotGrid(),
            const SizedBox(height: 32),
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildCategorySelector(),
            const SizedBox(height: 32),
            const Text(
              'Smoothing Music',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
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
              color: isSelected ? AppColors.primary : AppColors.primaryLighter,
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
              color: isSelected ? AppColors.primary : AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              cat,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textGrey,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMusicSelector() {
    final musicTracks = MockDataService.getMusicByCategory(_selectedCategory);

    if (musicTracks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryLighter,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'No music tracks available for this category.',
          style: TextStyle(color: AppColors.textGrey),
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
              color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(16),
              border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.music_note_rounded : Icons.music_off_outlined,
                  color: isSelected ? AppColors.primary : AppColors.textGrey,
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
                          color: isSelected ? AppColors.primary : AppColors.textDark,
                        ),
                      ),
                      Text(
                        track.artist,
                        style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
                Text(
                  track.duration,
                  style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReminderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgSky,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_rounded, color: AppColors.primary),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Reminder',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '8:00 AM',
                  style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          Switch(
            value: true,
            onChanged: (val) {},
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
