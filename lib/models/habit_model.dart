import 'package:flutter/material.dart';

class HabitModel {
  final String id;
  final String name;
  final IconData? icon;
  final String? emoji;
  final Color color;
  final int streak;
  final List<int> completedDays;

  HabitModel({
    required this.id,
    required this.name,
    this.icon,
    this.emoji,
    required this.color,
    required this.streak,
    required this.completedDays,
  });
}
