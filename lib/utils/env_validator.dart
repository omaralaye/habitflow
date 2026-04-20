import 'constants.dart';

class EnvValidator {
  static void validate() {
    final missingVars = <String>[];

    if (SupabaseConstants.SUPABASE_URL.isEmpty ||
        SupabaseConstants.SUPABASE_URL == 'YOUR_SUPABASE_URL') {
      missingVars.add('SUPABASE_URL');
    }

    if (SupabaseConstants.SUPABASE_ANON_KEY.isEmpty ||
        SupabaseConstants.SUPABASE_ANON_KEY == 'YOUR_SUPABASE_ANON_KEY') {
      missingVars.add('SUPABASE_ANON_KEY');
    }

    if (OpenAIConstants.OPENAI_API_KEY.isEmpty ||
        OpenAIConstants.OPENAI_API_KEY == 'sk-placeholder' ||
        OpenAIConstants.OPENAI_API_KEY == 'YOUR_OPENAI_API_KEY') {
      missingVars.add('OPENAI_API_KEY');
    }

    if (missingVars.isNotEmpty) {
      throw StateError(
        'Missing required environment variables: ${missingVars.join(', ')}. '
        'Please provide them using --dart-define or --dart-define-from-file.',
      );
    }
  }
}
