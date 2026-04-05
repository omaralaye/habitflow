import 'dart:math';
import '../models/habit_model.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  /// Simulates refining a habit name into something more actionable and specific.
  Future<String> refineHabit(String habitName) async {
    // Simulating API delay
    await Future.delayed(const Duration(milliseconds: 800));

    final lowerName = habitName.toLowerCase();
    if (lowerName.contains('read')) {
      return 'Read 10 pages of a non-fiction book';
    } else if (lowerName.contains('exercise') || lowerName.contains('workout')) {
      return 'Complete a 15-minute high-intensity workout';
    } else if (lowerName.contains('water')) {
      return 'Drink a glass of water every 2 hours';
    } else if (lowerName.contains('meditate')) {
      return 'Practice 5 minutes of mindful breathing';
    } else if (lowerName.contains('code') || lowerName.contains('programming')) {
      return 'Solve one coding challenge or commit to a side project';
    } else {
      return 'Start with just 5 minutes of $habitName today';
    }
  }

  /// Generates a personalized insight from the mascot based on its personality.
  Future<String> getMascotInsight(HabitModel habit) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final random = Random();
    final insights = _mascotInsights[habit.mascot] ?? ['You\'re doing great! Keep it up!'];
    return insights[random.nextInt(insights.length)].replaceAll('{habit}', habit.name.toLowerCase());
  }

  /// Generates a quick pep talk for the focus session.
  Future<String> getPepTalk(HabitModel habit) async {
    final random = Random();
    final talks = _mascotPepTalks[habit.mascot] ?? ['Let\'s stay focused together!'];
    return talks[random.nextInt(talks.length)];
  }

  final Map<MascotType, List<String>> _mascotInsights = {
    MascotType.panda: [
      'Focusing on {habit} is like tending a bamboo forest—patience is key. You\'re growing stronger every day.',
      'Remember, {habit} isn\'t a race. Find your zen in the process today.',
      'A calm mind makes {habit} easier. Take a deep breath before you start.',
    ],
    MascotType.penguin: [
      'Consistency is the engine of progress. Your {habit} streak is looking sharp!',
      'Even in the coldest winds, we keep moving. Don\'t let distractions stop your {habit} today.',
      'Precision matters. How can you make your {habit} 1% better today?',
    ],
    MascotType.koala: [
      'Progress on {habit} is still progress, no matter how slow. Rest is just as important as the work.',
      'Don\'t overexert yourself with {habit}. Consistency beats intensity every time.',
      'Make sure you\'re comfortable before starting {habit}. A cozy environment helps focus.',
    ],
    MascotType.fox: [
      'Work smarter, not harder. What\'s the most efficient way to complete {habit} today?',
      'Adaptability is your greatest strength. If your schedule changes, find a new way to fit in {habit}.',
      'I see a clever pattern in your {habit} tracking. Keep outsmarting your old excuses!',
    ],
    MascotType.cat: [
      'You don\'t need anyone\'s permission to excel at {habit}. Your independence is your power.',
      'Be curious about your progress with {habit}. What did you learn about yourself today?',
      'Stay agile. If {habit} feels stuck, try approaching it from a different angle.',
    ],
    MascotType.dog: [
      'I\'m so excited to see you tackle {habit} today! You\'ve got this!',
      'Wag more, worry less. You\'re doing an amazing job with your {habit} goals!',
      'Let\'s go! {habit} is going to be the highlight of our day!',
    ],
    MascotType.bear: [
      'Your strength comes from your discipline. {habit} is building a powerful foundation.',
      'Face {habit} head-on today. You have the power to overcome any obstacle.',
      'Protect your time for {habit}. It is the fuel for your inner strength.',
    ],
  };

  final Map<MascotType, List<String>> _mascotPepTalks = {
    MascotType.panda: ['Stay calm and focused.', 'Breathe through the challenge.', 'Peace in, distractions out.'],
    MascotType.penguin: ['Eyes on the prize.', 'Stay the course.', 'One step at a time, perfectly.'],
    MascotType.koala: ['Easy does it.', 'Steady and sure.', 'Enjoy the flow.'],
    MascotType.fox: ['Stay sharp.', 'Outsmart the distractions.', 'Focus with intent.'],
    MascotType.cat: ['Stay alert.', 'Pure focus.', 'Master your craft.'],
    MascotType.dog: ['You\'re doing it!', 'Keep going, friend!', 'So proud of you!'],
    MascotType.bear: ['Be powerful.', 'Unyielding focus.', 'Conquer this session.'],
  };
}
