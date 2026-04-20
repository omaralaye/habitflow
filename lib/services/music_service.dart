import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/error_handler.dart';
import '../models/music_model.dart';
import '../utils/constants.dart';
import '../utils/rate_limiter.dart';
import 'logger_service.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  Future<ServiceResult<List<MusicModel>>> fetchFreeToUseMusic({int limit = 100}) async {
    try {
      return await RateLimiter.music.run('fetchFreeToUseMusic', () async {
      final response = await http.get(
        Uri.parse('${MusicConstants.BASE_DATA_URL}/music/tracks/all?limit=$limit&order=release_date'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['ok'] == true && body['data'] is List) {
          final tracks = (body['data'] as List).where((track) => track['id'] != null).map((track) {
            final String id = track['id'].toString();
            final String title = track['title'] ?? 'Unknown Title';

            String artistName = 'Unknown Artist';
            if (track['artists'] is List && (track['artists'] as List).isNotEmpty) {
              final firstArtistEntry = track['artists'][0];
              if (firstArtistEntry is List && firstArtistEntry.length > 1) {
                artistName = firstArtistEntry[1]['name'] ?? 'Unknown Artist';
              }
            }

            // Collect all category names and tags
            final List<String> apiCategories = [];
            if (track['categories'] is List) {
              for (var entry in track['categories']) {
                if (entry is List && entry.length > 1 && entry[1] is Map) {
                  final name = entry[1]['name'];
                  if (name != null) apiCategories.add(name.toString().toLowerCase());
                }
              }
            }
            if (track['genre'] != null) {
              apiCategories.add(track['genre'].toString().toLowerCase());
            }
            if (track['tags'] is List) {
              for (var tag in track['tags']) {
                if (tag is String) {
                  apiCategories.add(tag.toLowerCase());
                } else if (tag is List && tag.length > 1 && tag[1] is String) {
                   apiCategories.add(tag[1].toLowerCase());
                }
              }
            }

            String category = 'General';

            bool matches(List<String> keywords) {
              return apiCategories.any((cat) => keywords.any((kw) => cat.contains(kw)));
            }

            if (matches(['meditative', 'calm', 'peaceful', 'relaxing', 'ambient', 'zen', 'yoga', 'spiritual', 'new age'])) {
              category = 'Mindfulness';
            } else if (matches(['lofi', 'study', 'chill', 'soft', 'piano', 'classical', 'instrumental'])) {
              category = 'Studying';
            } else if (matches(['workout', 'sports', 'energetic', 'rock', 'trap', 'hip hop', 'dance', 'electronic', 'house', 'upbeat'])) {
              category = 'Workout';
            } else if (matches(['corporate', 'inspiring', 'technology', 'advertising', 'uplifting', 'modern', 'motivational', 'productivity'])) {
              category = 'Productivity';
            } else if (matches(['nature', 'vlog', 'acoustic', 'folk', 'country', 'travel', 'health'])) {
              category = 'Health';
            }

            final int durationSeconds = track['duration'] ?? 0;
            final String duration = '${(durationSeconds / 60).floor()}:${(durationSeconds % 60).toString().padLeft(2, '0')}';

            final String url = '${MusicConstants.BASE_DATA_URL}/music/tracks/$id/file/mp3';

            return MusicModel(
              id: id,
              title: title,
              artist: artistName,
              category: category,
              duration: duration,
              url: url,
            );
          }).toList();
          LoggerService().info('Fetched Free To Use Music', tag: 'MUSIC', data: {'count': tracks.length});
          return ServiceResult.success(tracks);
        }
      }
      LoggerService().warning('Failed to fetch music or empty data', tag: 'MUSIC', data: {'statusCode': response.statusCode});
      return ServiceResult.success([]);
      });
    } catch (e) {
      LoggerService().error('Error in fetchFreeToUseMusic', tag: 'MUSIC', error: e);
      return ServiceResult.failure(e);
    }
  }
}
