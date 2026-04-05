import 'package:flutter/material.dart';
import '../models/habit_model.dart';
import '../models/music_model.dart';

class MockDataService {
  static List<HabitModel> habits = [
    HabitModel(
      id: '1',
      name: 'Meditation',
      color: const Color(0xFFE1F5FE),
      streak: 12,
      completedDays: [1, 2, 3, 4, 5],
      mascot: MascotType.panda,
      mascotLevel: 24,
      progress: 75,
      category: 'Mindfulness',
      isCompletedToday: true,
    ),
    HabitModel(
      id: '2',
      name: 'Morning Run',
      color: const Color(0xFFFFF3E0),
      streak: 5,
      completedDays: [1, 3, 5],
      mascot: MascotType.fox,
      mascotLevel: 12,
      progress: 40,
      category: 'Health',
      isCompletedToday: false,
    ),
    HabitModel(
      id: '3',
      name: 'Read 20 Pages',
      color: const Color(0xFFF3E5F5),
      streak: 8,
      completedDays: [1, 2, 3, 4, 5, 6, 7, 8],
      mascot: MascotType.penguin,
      mascotLevel: 18,
      progress: 90,
      category: 'Learning',
      isCompletedToday: true,
    ),
    HabitModel(
      id: '4',
      name: 'Stay Hydrated',
      color: const Color(0xFFE0F2F1),
      streak: 15,
      completedDays: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
      mascot: MascotType.koala,
      mascotLevel: 32,
      progress: 100,
      category: 'Health',
      isCompletedToday: true,
    ),
  ];

  static List<MusicModel> musicTracks = [
    MusicModel(id: '1', title: 'Rainy Afternoon', artist: 'Nature Sounds', category: 'Mindfulness', duration: '3:45'),
    MusicModel(id: '2', title: 'Deep Zen', artist: 'Calm Masters', category: 'Mindfulness', duration: '5:12'),
    MusicModel(id: '3', title: 'Mountain Breeze', artist: 'Earth Ambience', category: 'General', duration: '4:20'),
    MusicModel(id: '4', title: 'Power Pulse', artist: 'Workout Beats', category: 'Health', duration: '3:15'),
    MusicModel(id: '5', title: 'Steady Pace', artist: 'Rhythm Runners', category: 'Health', duration: '4:00'),
    MusicModel(id: '6', title: 'Focus Flow', artist: 'Study Vibes', category: 'Learning', duration: '2:50'),
    MusicModel(id: '7', title: 'Cosmic Library', artist: 'Space Ambient', category: 'Learning', duration: '6:30'),
    MusicModel(id: '8', title: 'Morning Spark', artist: 'Joy Radiance', category: 'Productivity', duration: '3:30'),
    MusicModel(id: '9', title: 'Forest Path', artist: 'Nature Sounds', category: 'Mindfulness', duration: '4:55'),
    MusicModel(id: '10', title: 'Ocean Waves', artist: 'Sea Harmonics', category: 'General', duration: '5:40'),
  ];

  static List<MusicModel> getMusicByCategory(String category) {
    return musicTracks.where((track) => track.category == category).toList();
  }
}
