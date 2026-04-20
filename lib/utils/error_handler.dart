import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:http/http.dart' as http;
import 'rate_limiter.dart';
import '../services/logger_service.dart';

/// A standardized application error that provides safe, user-facing information.
class AppError {
  final String message;
  final String? code;
  final dynamic originalError;

  AppError({
    required this.message,
    this.code,
    this.originalError,
  });

  /// Converts the error to a safe JSON Map that never exposes stack traces.
  Map<String, dynamic> toJson() {
    return {
      'status': 'error',
      'error': {
        'message': message,
        'code': code ?? 'UNKNOWN_ERROR',
      },
    };
  }

  @override
  String toString() => message;

  /// Factory to handle various types of exceptions and return a structured AppError.
  factory AppError.handle(dynamic error) {
    if (error is AppError) return error;

    LoggerService().error('Error handled by AppError', error: error);

    String message = 'An unexpected error occurred. Please try again later.';
    String code = 'INTERNAL_ERROR';

    if (error is RateLimitException) {
      message = '${error.message} Please try again in ${error.retryAfter.inSeconds} seconds.';
      code = 'RATE_LIMIT_EXCEEDED';
    } else if (error is AuthException) {
      message = error.message;
      code = 'AUTH_${error.statusCode ?? 'ERROR'}';
    } else if (error is PostgrestException) {
      message = 'Database error: ${error.message}';
      code = 'DATABASE_${error.code ?? 'ERROR'}';
    } else if (error is OpenAIClientException) {
      message = 'AI Service temporarily unavailable.';
      code = 'AI_SERVICE_ERROR';
    } else if (error is SocketException || error is http.ClientException) {
      message = 'No internet connection or server unreachable.';
      code = 'NETWORK_ERROR';
    } else if (error is HttpException) {
      message = 'Server returned an error: ${error.message}';
      code = 'HTTP_ERROR';
    } else if (error is FormatException) {
      message = 'Received invalid data from the server.';
      code = 'DATA_FORMAT_ERROR';
    }

    return AppError(
      message: message,
      code: code,
      originalError: error,
    );
  }
}

/// A wrapper for service responses that can contain either data or an error.
class ServiceResult<T> {
  final T? data;
  final AppError? error;

  ServiceResult.success(this.data) : error = null;
  ServiceResult.failure(dynamic e)
      : data = null,
        error = AppError.handle(e);

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  Map<String, dynamic> toJson(dynamic Function(T) dataToJson) {
    if (isSuccess) {
      return {
        'status': 'success',
        'data': dataToJson(data as T),
      };
    } else {
      return error!.toJson();
    }
  }
}
