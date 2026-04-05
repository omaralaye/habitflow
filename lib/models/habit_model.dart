import 'package:flutter/material.dart';

enum MascotType {
  panda,
  penguin,
  koala,
  fox,
  cat,
  dog,
  bear,
}

class HabitModel {
  final String id;
  final String name;
  final Color color;
  final int streak;
  final List<int> completedDays;
  final MascotType mascot;
  final int mascotLevel;
  final int progress; // percentage 0-100
  final String category;
  final bool isCompletedToday;
  final String? musicId;

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

  HabitModel({
    required this.id,
    required this.name,
    required this.color,
    required this.streak,
    required this.completedDays,
    required this.mascot,
    this.mascotLevel = 1,
    this.progress = 0,
    this.category = 'General',
    this.isCompletedToday = false,
    this.musicId,
  });

  HabitModel copyWith({
    String? id,
    String? name,
    Color? color,
    int? streak,
    List<int>? completedDays,
    MascotType? mascot,
    int? mascotLevel,
    int? progress,
    String? category,
    bool? isCompletedToday,
    String? musicId,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      streak: streak ?? this.streak,
      completedDays: completedDays ?? this.completedDays,
      mascot: mascot ?? this.mascot,
      mascotLevel: mascotLevel ?? this.mascotLevel,
      progress: progress ?? this.progress,
      category: category ?? this.category,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      musicId: musicId ?? this.musicId,
    );
  }
}
