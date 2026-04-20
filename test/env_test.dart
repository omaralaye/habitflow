import 'package:flutter_test/flutter_test.dart';
import 'package:sanctuary/utils/env_validator.dart';
import 'package:sanctuary/utils/constants.dart';

void main() {
  group('EnvValidator Tests', () {
    test('validate should behave correctly based on environment', () {
      bool isAnyPlaceholder =
          SupabaseConstants.SUPABASE_URL == 'YOUR_SUPABASE_URL' ||
          SupabaseConstants.SUPABASE_ANON_KEY == 'YOUR_SUPABASE_ANON_KEY' ||
          OpenAIConstants.OPENAI_API_KEY == 'sk-placeholder' ||
          OpenAIConstants.OPENAI_API_KEY == 'YOUR_OPENAI_API_KEY';

      if (isAnyPlaceholder) {
        expect(() => EnvValidator.validate(), throwsA(isA<StateError>()));
      } else {
        expect(() => EnvValidator.validate(), returnsNormally);
      }
    });
  });
}
