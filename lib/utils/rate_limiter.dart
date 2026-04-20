import 'dart:collection';

/// Exception thrown when a rate limit is exceeded.
class RateLimitException implements Exception {
  final String message;
  final Duration retryAfter;

  RateLimitException({
    this.message = 'Too many requests. Please try again later.',
    required this.retryAfter,
  });

  @override
  String toString() => 'RateLimitException: $message (Retry after ${retryAfter.inSeconds}s)';
}

/// A simple client-side rate limiter using a sliding window approach.
class RateLimiter {
  final int maxRequests;
  final Duration window;
  final Map<String, Queue<DateTime>> _requestHistory = {};

  RateLimiter({
    required this.maxRequests,
    required this.window,
  });

  /// Executes [action] if the rate limit for [key] has not been exceeded.
  /// Throws [RateLimitException] otherwise.
  Future<T> run<T>(String key, Future<T> Function() action) async {
    final now = DateTime.now();
    final history = _requestHistory.putIfAbsent(key, () => Queue<DateTime>());

    // Remove expired timestamps
    while (history.isNotEmpty && now.difference(history.first) > window) {
      history.removeFirst();
    }

    if (history.length >= maxRequests) {
      final retryAfter = window - now.difference(history.first);
      throw RateLimitException(retryAfter: retryAfter);
    }

    history.addLast(now);
    return await action();
  }

  /// Specialized rate limiters for different parts of the app.
  static final auth = RateLimiter(maxRequests: 5, window: const Duration(minutes: 5));
  static final ai = RateLimiter(maxRequests: 10, window: const Duration(minutes: 1));
  static final db = RateLimiter(maxRequests: 20, window: const Duration(minutes: 1));
  static final music = RateLimiter(maxRequests: 5, window: const Duration(minutes: 1));
}
