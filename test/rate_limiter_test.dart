import 'package:flutter_test/flutter_test.dart';
import 'package:sanctuary/utils/rate_limiter.dart';

void main() {
  group('RateLimiter', () {
    test('allows requests within limit', () async {
      final limiter = RateLimiter(maxRequests: 2, window: const Duration(seconds: 1));

      int callCount = 0;
      Future<int> action() async => ++callCount;

      await limiter.run('key', action);
      await limiter.run('key', action);

      expect(callCount, 2);
    });

    test('throws RateLimitException when limit exceeded', () async {
      final limiter = RateLimiter(maxRequests: 2, window: const Duration(seconds: 1));

      Future<int> action() async => 1;

      await limiter.run('key', action);
      await limiter.run('key', action);

      expect(
        () => limiter.run('key', action),
        throwsA(isA<RateLimitException>()),
      );
    });

    test('resets after window expires', () async {
      final limiter = RateLimiter(maxRequests: 1, window: const Duration(milliseconds: 100));

      Future<int> action() async => 1;

      await limiter.run('key', action);

      expect(
        () => limiter.run('key', action),
        throwsA(isA<RateLimitException>()),
      );

      await Future.delayed(const Duration(milliseconds: 150));

      // Should work again
      final result = await limiter.run('key', action);
      expect(result, 1);
    });

    test('keys are isolated', () async {
      final limiter = RateLimiter(maxRequests: 1, window: const Duration(seconds: 1));

      Future<int> action() async => 1;

      await limiter.run('key1', action);

      // key2 should still be allowed
      final result = await limiter.run('key2', action);
      expect(result, 1);
    });
  });
}
