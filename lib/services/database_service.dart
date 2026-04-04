import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/habit_model.dart';
import 'auth_service.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _uid => AuthService().user?.id;

  Stream<List<HabitModel>> get habitsStream {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    // Supabase Realtime for a stream of data
    return _supabase
        .from('habits')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .map((snapshot) {
          return snapshot.map((data) {
            return _habitFromSupabase(data);
          }).toList();
        });
  }

  Future<void> addHabit(HabitModel habit) async {
    final uid = _uid;
    if (uid == null) return;
    final Map<String, dynamic> data = _habitToSupabase(habit);
    data['user_id'] = uid;
    await _supabase.from('habits').insert(data);
  }

  Future<void> updateHabit(HabitModel habit) async {
    final uid = _uid;
    if (uid == null) return;
    await _supabase
        .from('habits')
        .update(_habitToSupabase(habit))
        .eq('id', habit.id)
        .eq('user_id', uid); // Ensure user owns the habit
  }

  Future<void> deleteHabit(String habitId) async {
    final uid = _uid;
    if (uid == null) return;
    await _supabase
        .from('habits')
        .delete()
        .eq('id', habitId)
        .eq('user_id', uid); // Ensure user owns the habit
  }

  HabitModel _habitFromSupabase(Map<String, dynamic> data) {
    return HabitModel(
      id: data['id'].toString(),
      name: data['name'] ?? '',
      color: Color(data['color'] as int? ?? 0xFFFFFFFF),
      streak: data['streak'] ?? 0,
      completedDays: List<int>.from(data['completed_days'] ?? []),
      mascot: MascotType.values.byName(data['mascot'] ?? 'panda'),
      mascotLevel: data['mascot_level'] ?? 1,
      progress: data['progress'] ?? 0,
      category: data['category'] ?? 'General',
      isCompletedToday: data['is_completed_today'] ?? false,
      musicId: data['music_id'],
    );
  }

  Map<String, dynamic> _habitToSupabase(HabitModel habit) {
    return {
      'name': habit.name,
      'color': habit.color.toARGB32(),
      'streak': habit.streak,
      'completed_days': habit.completedDays,
      'mascot': habit.mascot.name,
      'mascot_level': habit.mascotLevel,
      'progress': habit.progress,
      'category': habit.category,
      'is_completed_today': habit.isCompletedToday,
      'music_id': habit.musicId,
    };
  }
}
