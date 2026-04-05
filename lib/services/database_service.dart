import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/habit_model.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  factory DatabaseService() => instance;

  DatabaseService._internal();

  @visibleForTesting
  static void setMockInstance(DatabaseService mock) {
    _instance = mock;
  }

  final SupabaseClient _supabase = Supabase.instance.client;
  String? get _uid => _supabase.auth.currentUser?.id;

  Stream<List<HabitModel>> get habitsStream {
    if (_uid == null) return Stream.value([]);

    // Using a more complex stream that combines habits and completions
    return _supabase
        .from('habits')
        .stream(primaryKey: ['id'])
        .eq('user_id', _uid!)
        .asyncMap((data) async {
          final List<HabitModel> habits = [];
          for (var map in data) {
            final habitId = map['id'];

            // Fetch completions for this habit
            final completionsResponse = await _supabase
                .from('habit_completions')
                .select('completed_at')
                .eq('habit_id', habitId);

            final List<String> completedDates = (completionsResponse as List)
                .map((c) => c['completed_at'] as String)
                .toList();

            habits.add(_habitFromSupabase(map, completedDates));
          }
          return habits;
        });
  }

  Future<void> addHabit(HabitModel habit) async {
    if (_uid == null) return;
    await _supabase.from('habits').insert({
      ..._habitToSupabase(habit),
      'user_id': _uid,
    });
  }

  Future<bool> hasHabits() async {
    if (_uid == null) return false;
    final response = await _supabase
        .from('habits')
        .select('id')
        .eq('user_id', _uid!)
        .limit(1);
    return (response as List).isNotEmpty;
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

  Future<void> completeHabit(String habitId) async {
    if (_uid == null) return;
    await _supabase.from('habit_completions').insert({
      'habit_id': habitId,
      'user_id': _uid,
      'completed_at': DateTime.now().toIso8601String().split('T')[0],
    });
  }

  HabitModel _habitFromSupabase(Map<String, dynamic> data, List<String> completedDates) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final isCompletedToday = completedDates.contains(today);

    // Simple progress calculation (e.g., % of days completed in last 30 days)
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentCompletions = completedDates.where((date) {
      final d = DateTime.parse(date);
      return d.isAfter(thirtyDaysAgo);
    }).length;
    final progress = ((recentCompletions / 30) * 100).toInt().clamp(0, 100);

    return HabitModel(
      id: data['id'].toString(),
      name: data['name'] ?? '',
      color: _colorFromHex(data['color'] ?? '#006D77'),
      streak: data['streak'] ?? 0,
      completedDays: completedDates.map((d) => DateTime.parse(d).day).toList(),
      mascot: MascotType.values.byName(data['mascot'] ?? 'panda'),
      mascotLevel: (data['mascot_level'] as num?)?.toInt() ?? 1,
      progress: progress,
      category: data['category'] ?? 'General',
      isCompletedToday: isCompletedToday,
      musicId: data['music_id'],
    );
  }

  Map<String, dynamic> _habitToSupabase(HabitModel habit) {
    return {
      'name': habit.name,
      'color': _colorToHex(habit.color),
      'streak': habit.streak,
      'mascot': habit.mascot.name,
      'mascot_level': habit.mascotLevel,
      'category': habit.category,
      'music_id': habit.musicId,
    };
  }

  Color _colorFromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}
