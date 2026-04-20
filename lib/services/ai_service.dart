import 'dart:convert';
import 'dart:math';
import 'package:openai_dart/openai_dart.dart';
import '../utils/error_handler.dart';
import '../models/habit_model.dart';
import '../utils/constants.dart';
import '../utils/rate_limiter.dart';
import 'logger_service.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final OpenAIClient _client = OpenAIClient(apiKey: OpenAIConstants.OPENAI_API_KEY);

  /// Refines a habit name into something more actionable and specific using OpenAI.
  Future<ServiceResult<String>> refineHabit(String habitName) async {
    try {
      return await RateLimiter.ai.run('refineHabit', () async {
      final response = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(OpenAIConstants.OPENAI_MODEL),
          messages: [
            const ChatCompletionMessage.system(
              content: 'You are a habit coaching assistant. Your goal is to take a vague habit name and refine it into a specific, actionable, and measurable habit. Keep the output concise (less than 10 words).',
            ),
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string('Refine this habit: $habitName'),
            ),
          ],
          temperature: 0.7,
          maxTokens: 30,
        ),
      );

      final refinedName = response.choices.first.message.content?.trim();
      LoggerService().info('Habit refined by AI', tag: 'AI', data: {'original': habitName, 'refined': refinedName});
      return ServiceResult.success(refinedName ?? habitName);
      });
    } catch (e) {
      if (e is RateLimitException) return ServiceResult.failure(e);
      LoggerService().warning('AI habit refinement failed, using mock', tag: 'AI', error: e);
      // Fallback to mock logic if API fails or key is placeholder
      return ServiceResult.success(_mockRefineHabit(habitName));
    }
  }

  /// Refines a habit and recommends a category in a single AI call.
  Future<ServiceResult<Map<String, String>>> refineAndCategorize(String habitName) async {
    const categories = ['Mindfulness', 'Health', 'Studying', 'Workout', 'Productivity', 'General'];

    try {
      return await RateLimiter.ai.run('refineAndCategorize', () async {
      final response = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(OpenAIConstants.OPENAI_MODEL),
          messages: [
            const ChatCompletionMessage.system(
              content: 'You are a habit coaching assistant. Refine the habit into something specific (max 10 words) and categorize it into exactly one of: Mindfulness, Health, Studying, Workout, Productivity, General. Return ONLY a JSON object like {"refinedName": "...", "category": "..."}.',
            ),
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string('Refine and categorize: $habitName'),
            ),
          ],
          temperature: 0.5,
          maxTokens: 100,
        ),
      );

      final content = response.choices.first.message.content?.trim() ?? '';

      if (content.isNotEmpty) {
        // Find the JSON block
        final jsonMatch = RegExp(r'\{.*\}', dotAll: true).stringMatch(content);
        if (jsonMatch != null) {
          final Map<String, dynamic> data = jsonDecode(jsonMatch);

          String category = data['category'] ?? 'General';
          if (!categories.contains(category)) {
             // Try to map to nearest category or default
             category = _mapToValidCategory(category);
          }

          final refined = data['refinedName']?.toString().trim();

          LoggerService().info('Habit refined and categorized by AI', tag: 'AI', data: {
            'original': habitName,
            'refined': refined,
            'category': category
          });

          return ServiceResult.success({
            'refinedName': (refined != null && refined.isNotEmpty) ? refined : habitName,
            'category': category,
          });
        }
      }

      LoggerService().warning('AI refineAndCategorize returned invalid JSON, falling back', tag: 'AI', data: {'content': content});

      // Fallback to separate calls if JSON parsing fails
      final refinedResult = await refineHabit(habitName);
      final categoryResult = await recommendCategory(habitName);

      return ServiceResult.success({
        'refinedName': refinedResult.data ?? habitName,
        'category': categoryResult.data ?? 'General',
      });
      });
    } catch (e) {
      if (e is RateLimitException) return ServiceResult.failure(e);
      LoggerService().warning('AI refineAndCategorize failed, using mock', tag: 'AI', error: e);
      return ServiceResult.success({
        'refinedName': _mockRefineHabit(habitName),
        'category': _mockRecommendCategory(habitName),
      });
    }
  }

  String _mapToValidCategory(String input) {
    const categories = ['Mindfulness', 'Health', 'Studying', 'Workout', 'Productivity', 'General'];
    final lowerInput = input.toLowerCase();

    if (lowerInput.contains('mind') || lowerInput.contains('zen')) return 'Mindfulness';
    if (lowerInput.contains('health') || lowerInput.contains('well')) return 'Health';
    if (lowerInput.contains('study') || lowerInput.contains('learn')) return 'Studying';
    if (lowerInput.contains('work') || lowerInput.contains('gym') || lowerInput.contains('exercise')) return 'Workout';
    if (lowerInput.contains('prod') || lowerInput.contains('focus')) return 'Productivity';

    return 'General';
  }

  /// Recommends a category for a habit based on its name using OpenAI.
  Future<ServiceResult<String>> recommendCategory(String habitName) async {
    const categories = ['Mindfulness', 'Health', 'Studying', 'Workout', 'Productivity', 'General'];

    try {
      return await RateLimiter.ai.run('recommendCategory', () async {
      final response = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(OpenAIConstants.OPENAI_MODEL),
          messages: [
            const ChatCompletionMessage.system(
              content: 'You are a habit organization assistant. Categorize the habit provided by the user into exactly one of these categories: Mindfulness, Health, Studying, Workout, Productivity, General. Output only the category name.',
            ),
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string('Categorize this habit: $habitName'),
            ),
          ],
          temperature: 0.3,
          maxTokens: 10,
        ),
      );

      final category = response.choices.first.message.content?.trim();
      if (category != null && categories.contains(category)) {
        return ServiceResult.success(category);
      }
      return ServiceResult.success(_mockRecommendCategory(habitName));
      });
    } catch (e) {
      if (e is RateLimitException) return ServiceResult.failure(e);
      return ServiceResult.success(_mockRecommendCategory(habitName));
    }
  }

  /// Generates a personalized insight from the mascot based on its personality using OpenAI.
  Future<ServiceResult<String>> getMascotInsight(HabitModel habit) async {
    final personality = _mascotPersonalities[habit.mascot] ?? 'helpful';

    try {
      return await RateLimiter.ai.run('getMascotInsight', () async {
      final response = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(OpenAIConstants.OPENAI_MODEL),
          messages: [
            ChatCompletionMessage.system(
              content: 'You are a mascot for a habit tracking app. Your personality is: $personality. Provide a short, encouraging insight (1-2 sentences) to the user about their habit: ${habit.name}.',
            ),
            const ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string('Give me an insight about my habit.'),
            ),
          ],
          temperature: 0.8,
          maxTokens: 60,
        ),
      );

      final insight = response.choices.first.message.content?.trim();
      return ServiceResult.success(insight ?? _mockGetMascotInsight(habit));
      });
    } catch (e) {
      if (e is RateLimitException) return ServiceResult.failure(e);
      return ServiceResult.success(_mockGetMascotInsight(habit));
    }
  }

  /// Generates a quick pep talk for the focus session using OpenAI.
  Future<ServiceResult<String>> getPepTalk(HabitModel habit) async {
    final personality = _mascotPersonalities[habit.mascot] ?? 'helpful';

    try {
      return await RateLimiter.ai.run('getPepTalk', () async {
      final response = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(OpenAIConstants.OPENAI_MODEL),
          messages: [
            ChatCompletionMessage.system(
              content: 'You are a mascot for a habit tracking app. Your personality is: $personality. Give a very short (max 10 words) pep talk for a focus session on the habit: ${habit.name}.',
            ),
            const ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string('Give me a quick pep talk!'),
            ),
          ],
          temperature: 0.9,
          maxTokens: 30,
        ),
      );

      final pepTalk = response.choices.first.message.content?.trim();
      return ServiceResult.success(pepTalk ?? _mockGetPepTalk(habit));
      });
    } catch (e) {
      if (e is RateLimitException) return ServiceResult.failure(e);
      return ServiceResult.success(_mockGetPepTalk(habit));
    }
  }

  // --- Mock Fallbacks (original logic) ---

  String _mockRefineHabit(String habitName) {
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

  String _mockGetMascotInsight(HabitModel habit) {
    final random = Random();
    final insights = _mascotInsights[habit.mascot] ?? ['You\'re doing great! Keep it up!'];
    return insights[random.nextInt(insights.length)].replaceAll('{habit}', habit.name.toLowerCase());
  }

  String _mockGetPepTalk(HabitModel habit) {
    final random = Random();
    final talks = _mascotPepTalks[habit.mascot] ?? ['Let\'s stay focused together!'];
    return talks[random.nextInt(talks.length)];
  }

  String _mockRecommendCategory(String habitName) {
    final lowerName = habitName.toLowerCase();
    if (lowerName.contains('meditate') || lowerName.contains('breath') || lowerName.contains('zen')) {
      return 'Mindfulness';
    } else if (lowerName.contains('read') || lowerName.contains('study') || lowerName.contains('learn') || lowerName.contains('code')) {
      return 'Studying';
    } else if (lowerName.contains('exercise') || lowerName.contains('workout') || lowerName.contains('run') || lowerName.contains('gym')) {
      return 'Workout';
    } else if (lowerName.contains('water') || lowerName.contains('sleep') || lowerName.contains('eat') || lowerName.contains('fruit')) {
      return 'Health';
    } else if (lowerName.contains('work') || lowerName.contains('clean') || lowerName.contains('task')) {
      return 'Productivity';
    } else {
      return 'General';
    }
  }

  final Map<MascotType, String> _mascotPersonalities = {
    MascotType.panda: 'Zen, mindful, patient, and calm.',
    MascotType.penguin: 'Disciplined, consistent, social, and precise.',
    MascotType.koala: 'Relaxed, focused on rest and recharge, steady.',
    MascotType.fox: 'Strategic, clever, efficient, and adaptable.',
    MascotType.cat: 'Independent, curious, agile, and compassionate.',
    MascotType.dog: 'Enthusiastic, loyal, energetic, and encouraging.',
    MascotType.bear: 'Strong, protective, disciplined, and powerful.',
  };

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
