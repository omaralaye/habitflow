import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/habit_model.dart';
import 'auth_service.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? _uid = AuthService().user?.uid;

  CollectionReference get _habitsRef => _db.collection('users').doc(_uid).collection('habits');

  Stream<List<HabitModel>> get habitsStream {
    if (_uid == null) return Stream.value([]);
    return _habitsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _habitFromFirestore(doc.id, data);
      }).toList();
    });
  }

  Future<void> addHabit(HabitModel habit) async {
    if (_uid == null) return;
    await _habitsRef.add(_habitToFirestore(habit));
  }

  Future<void> updateHabit(HabitModel habit) async {
    if (_uid == null) return;
    await _habitsRef.doc(habit.id).update(_habitToFirestore(habit));
  }

  Future<void> deleteHabit(String habitId) async {
    if (_uid == null) return;
    await _habitsRef.doc(habitId).delete();
  }

  HabitModel _habitFromFirestore(String id, Map<String, dynamic> data) {
    return HabitModel(
      id: id,
      name: data['name'] ?? '',
      color: Color(data['color'] as int? ?? 0xFFFFFFFF),
      streak: data['streak'] ?? 0,
      completedDays: List<int>.from(data['completedDays'] ?? []),
      mascot: MascotType.values.byName(data['mascot'] ?? 'panda'),
      mascotLevel: data['mascotLevel'] ?? 1,
      progress: data['progress'] ?? 0,
      category: data['category'] ?? 'General',
      isCompletedToday: data['isCompletedToday'] ?? false,
      musicId: data['musicId'],
    );
  }

  Map<String, dynamic> _habitToFirestore(HabitModel habit) {
    return {
      'name': habit.name,
      'color': habit.color.toARGB32(),
      'streak': habit.streak,
      'completedDays': habit.completedDays,
      'mascot': habit.mascot.name,
      'mascotLevel': habit.mascotLevel,
      'progress': habit.progress,
      'category': habit.category,
      'isCompletedToday': habit.isCompletedToday,
      'musicId': habit.musicId,
    };
  }
}
