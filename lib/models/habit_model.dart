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
    );
  }
}
