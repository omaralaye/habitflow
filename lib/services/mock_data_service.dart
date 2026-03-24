import 'package:flutter/material.dart';
import '../models/habit_model.dart';

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

  static String mascotToEmoji(MascotType type) {
    switch (type) {
      case MascotType.panda: return '🐼';
      case MascotType.penguin: return '🐧';
      case MascotType.koala: return '🐨';
      case MascotType.fox: return '🦊';
      case MascotType.cat: return '🐱';
      case MascotType.dog: return '🐶';
      case MascotType.bear: return '🐻';
    }
  }

  static Color getPastelColorForMascot(MascotType type) {
    switch (type) {
      case MascotType.panda: return const Color(0xFFF3E5F5);
      case MascotType.penguin: return const Color(0xFFE3F2FD);
      case MascotType.koala: return const Color(0xFFE0F2F1);
      case MascotType.fox: return const Color(0xFFFFF3E0);
      case MascotType.cat: return const Color(0xFFFCE4EC);
      case MascotType.dog: return const Color(0xFFF1F8E9);
      case MascotType.bear: return const Color(0xFFEFEBE9);
    }
  }
}
