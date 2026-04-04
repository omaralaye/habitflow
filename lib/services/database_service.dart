import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/habit_model.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  String? get _uid => _supabase.auth.currentUser?.id;

  Stream<List<HabitModel>> get habitsStream {
    if (_uid == null) return Stream.value([]);
    return _supabase
        .from('habits')
        .stream(primaryKey: ['id'])
        .eq('user_id', _uid!)
        .map((data) {
          return data.map((map) => _habitFromSupabase(map)).toList();
        });
  }

  Future<void> addHabit(HabitModel habit) async {
    if (_uid == null) return;
    await _supabase.from('habits').insert({
      ..._habitToSupabase(habit),
      'user_id': _uid,
    });
  }

  Future<void> updateHabit(HabitModel habit) async {
    if (_uid == null) return;
    await _supabase
        .from('habits')
        .update(_habitToSupabase(habit))
        .eq('id', habit.id);
  }

  Future<void> deleteHabit(String habitId) async {
    if (_uid == null) return;
    await _supabase.from('habits').delete().eq('id', habitId);
  }

  HabitModel _habitFromSupabase(Map<String, dynamic> data) {
    return HabitModel(
      id: data['id'].toString(),
      name: data['name'] ?? '',
      color: Color(data['color'] as int? ?? 0xFFFFFFFF),
      streak: data['streak'] ?? 0,
      completedDays: List<int>.from(data['completed_days'] ?? []),
      mascot: MascotType.values.byName(data['mascot'] ?? 'panda'),
      mascotLevel: (data['mascot_level'] as num?)?.toInt() ?? 1,
      progress: (data['progress'] as num?)?.toInt() ?? 0,
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
