import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/habit_model.dart';
import '../models/music_model.dart';
import 'music_service.dart';

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
    if (_uid == null) {
      debugPrint('habitsStream: _uid is null');
      return Stream.value([]);
    }

    // Using a more complex stream that combines habits and completions
    return _supabase
        .from('habits')
        .stream(primaryKey: ['id'])
        .eq('user_id', _uid!)
        .asyncMap((data) async {
          try {
            final List<HabitModel> habits = [];
            // Fetch all completions for the user to optimize and reduce queries
            final completionsResponse = await _supabase
                .from('habit_completions')
                .select('habit_id, completed_at')
                .eq('user_id', _uid!);

            final Map<String, List<String>> completionsByHabit = {};
            for (var c in completionsResponse as List) {
              final hId = c['habit_id'].toString();
              final date = c['completed_at'] as String;
              completionsByHabit.putIfAbsent(hId, () => []).add(date);
            }

            for (var map in data) {
              final habitId = map['id'].toString();
              final completedDates = completionsByHabit[habitId] ?? [];
              habits.add(_habitFromSupabase(map, completedDates));
            }
            return habits;
          } catch (e) {
            debugPrint('Error in habitsStream: $e');
            return [];
          }
        });
  }

  Future<HabitModel?> addHabit(HabitModel habit) async {
    if (_uid == null) return null;
    final habitData = _habitToSupabase(habit);

    // Ensure music_id is a valid UUID or null
    if (habitData['music_id'] != null) {
      final musicId = habitData['music_id'].toString();
      if (musicId.length < 36) { // Basic check for non-UUID strings from mock data
        habitData['music_id'] = null;
      }
    }

    final response = await _supabase.from('habits').insert({
      ...habitData,
      'user_id': _uid,
    }).select().single();

    return _habitFromSupabase(response, []);
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
    final habitData = _habitToSupabase(habit);

    // Ensure music_id is a valid UUID or null
    if (habitData['music_id'] != null) {
      final musicId = habitData['music_id'].toString();
      if (musicId.length < 36) { // Basic check for non-UUID strings from mock data
        habitData['music_id'] = null;
      }
    }

    await _supabase
        .from('habits')
        .update(habitData)
        .eq('id', habit.id);
  }

  Future<void> deleteHabit(String habitId) async {
    if (_uid == null) return;
    await _supabase.from('habits').delete().eq('id', habitId);
  }

  Future<void> completeHabit(String habitId) async {
    if (_uid == null) return;

    // 1. Add completion record
    await _supabase.from('habit_completions').insert({
      'habit_id': habitId,
      'user_id': _uid,
      'completed_at': DateTime.now().toIso8601String().split('T')[0],
    });

    // 2. Update habit streak
    final habitResponse = await _supabase.from('habits').select('streak').eq('id', habitId).single();
    final currentStreak = habitResponse['streak'] as int? ?? 0;
    await _supabase.from('habits').update({'streak': currentStreak + 1}).eq('id', habitId);

    // 3. Award XP to user
    final profileResponse = await _supabase.from('profiles').select('xp, level').eq('id', _uid!).single();
    int currentXp = profileResponse['xp'] as int? ?? 0;
    int currentLevel = profileResponse['level'] as int? ?? 1;

    currentXp += 50; // Award 50 XP per habit

    // Check for level up: level * 500 XP per level
    int nextLevelXp = currentLevel * 500;
    if (currentXp >= nextLevelXp) {
      currentXp -= nextLevelXp;
      currentLevel += 1;
    }

    await _supabase.from('profiles').update({
      'xp': currentXp,
      'level': currentLevel,
    }).eq('id', _uid!);
  }

  Stream<Map<String, dynamic>> get profileStream {
    if (_uid == null) return const Stream.empty();
    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', _uid!)
        .map((data) => data.isNotEmpty ? data.first : {});
  }

  Stream<List<Map<String, dynamic>>> get userMilestonesStream {
    if (_uid == null) return Stream.value([]);
    return _supabase
        .from('user_milestones')
        .stream(primaryKey: ['user_id', 'milestone_id'])
        .eq('user_id', _uid!)
        .asyncMap((data) async {
          if (data.isEmpty) return [];

          final List<String> milestoneIds = data.map((item) => item['milestone_id'].toString()).toList();
          final milestonesData = await _supabase
              .from('milestones')
              .select()
              .filter('id', 'in', '(${milestoneIds.join(',')})');

          final Map<String, Map<String, dynamic>> milestoneMap = {
            for (var m in milestonesData as List) m['id'].toString(): Map<String, dynamic>.from(m)
          };

          return data.map((item) {
            final mId = item['milestone_id'].toString();
            final mData = milestoneMap[mId] ?? {};
            return {
              ...mData,
              'unlocked_at': item['unlocked_at'],
              'is_completed': true,
            };
          }).toList();
        });
  }

  Future<List<Map<String, dynamic>>> getAllMilestones() async {
    final response = await _supabase.from('milestones').select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<MusicModel>> getMusicTracks() async {
    // 1. Fetch from Supabase
    final response = await _supabase.from('music').select();
    final List<MusicModel> tracks = (response as List).map((m) => MusicModel(
      id: m['id'].toString(),
      title: m['title'] ?? 'Unknown Title',
      artist: m['artist'] ?? 'Unknown Artist',
      category: m['category'] ?? 'General',
      duration: m['duration'] ?? '0:00',
      url: m['url'],
    )).toList();

    // 2. Fetch from Free To Use API and merge
    try {
      final freeTracks = await MusicService().fetchFreeToUseMusic();
      tracks.addAll(freeTracks);
    } catch (e) {
      debugPrint('Error merging Free To Use Music: $e');
    }

    return tracks;
  }

  Stream<Map<String, dynamic>> get statsStream {
    if (_uid == null) return Stream.value({});

    return _supabase
        .from('habit_completions')
        .stream(primaryKey: ['id'])
        .eq('user_id', _uid!)
        .asyncMap((data) async {
          final totalDone = data.length;

          final habitsResponse = await _supabase
              .from('habits')
              .select('id')
              .eq('user_id', _uid!);
          final activeHabits = (habitsResponse as List).length;

          // Perfect days: days where all active habits were completed
          // This is a bit simplified for now
          final Map<String, Set<String>> completionsByDate = {};
          for (var c in data) {
            final date = c['completed_at'] as String;
            final habitId = c['habit_id'].toString();
            completionsByDate.putIfAbsent(date, () => {}).add(habitId);
          }

          int perfectDays = 0;
          if (activeHabits > 0) {
            completionsByDate.forEach((date, completedHabits) {
              if (completedHabits.length >= activeHabits) {
                perfectDays++;
              }
            });
          }

          // Calculate success rate for the last 30 days
          final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
          final recentCompletions = data.where((c) {
            final date = DateTime.parse(c['completed_at'] as String);
            return date.isAfter(thirtyDaysAgo);
          }).length;

          final expectedCompletions = activeHabits * 30;
          final successRate = expectedCompletions > 0
              ? (recentCompletions / expectedCompletions * 100).toInt().clamp(0, 100)
              : 0;

          // Weekly data (last 7 days)
          final List<int> weeklyCompletions = List.filled(7, 0);
          final now = DateTime.now();
          for (int i = 0; i < 7; i++) {
            final date = now.subtract(Duration(days: 6 - i)).toIso8601String().split('T')[0];
            weeklyCompletions[i] = completionsByDate[date]?.length ?? 0;
          }

          return {
            'totalDone': totalDone,
            'activeHabits': activeHabits,
            'perfectDays': perfectDays,
            'successRate': successRate,
            'weeklyCompletions': weeklyCompletions,
          };
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

    TimeOfDay? startReminderTime;
    if (data['start_reminder_time'] != null) {
      final parts = (data['start_reminder_time'] as String).split(':');
      if (parts.length >= 2) {
        startReminderTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }

    TimeOfDay? endReminderTime;
    if (data['reminder_time'] != null) {
      final parts = (data['reminder_time'] as String).split(':');
      if (parts.length >= 2) {
        endReminderTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }

    return HabitModel(
      id: data['id'].toString(),
      name: data['name'] ?? '',
      color: _colorFromHex(data['color'] ?? '#006D77'),
      streak: data['streak'] ?? 0,
      completedDays: completedDates.map((d) => DateTime.parse(d)).toList(),
      mascot: MascotType.values.byName(data['mascot'] ?? 'panda'),
      mascotLevel: (data['mascot_level'] as num?)?.toInt() ?? 1,
      progress: progress,
      category: data['category'] ?? 'General',
      isCompletedToday: isCompletedToday,
      musicId: data['music_id'],
      startReminderEnabled: data['start_reminder_enabled'] ?? false,
      startReminderTime: startReminderTime,
      endReminderEnabled: data['reminder_enabled'] ?? true,
      endReminderTime: endReminderTime,
    );
  }

  Map<String, dynamic> _habitToSupabase(HabitModel habit) {
    String? startReminderTimeStr;
    if (habit.startReminderTime != null) {
      final hour = habit.startReminderTime!.hour.toString().padLeft(2, '0');
      final minute = habit.startReminderTime!.minute.toString().padLeft(2, '0');
      startReminderTimeStr = '$hour:$minute:00';
    }

    String? endReminderTimeStr;
    if (habit.endReminderTime != null) {
      final hour = habit.endReminderTime!.hour.toString().padLeft(2, '0');
      final minute = habit.endReminderTime!.minute.toString().padLeft(2, '0');
      endReminderTimeStr = '$hour:$minute:00';
    }

    return {
      'name': habit.name,
      'color': _colorToHex(habit.color),
      'streak': habit.streak,
      'mascot': habit.mascot.name,
      'mascot_level': habit.mascotLevel,
      'category': habit.category,
      'music_id': habit.musicId,
      'start_reminder_enabled': habit.startReminderEnabled,
      'start_reminder_time': startReminderTimeStr,
      'reminder_enabled': habit.endReminderEnabled,
      'reminder_time': endReminderTimeStr,
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
