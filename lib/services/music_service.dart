import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/music_model.dart';
import '../utils/constants.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  Future<List<MusicModel>> fetchFreeToUseMusic({int limit = 100}) async {
    try {
      final response = await http.get(
        Uri.parse('${MusicConstants.BASE_API_URL}/music/tracks/all?limit=$limit&order=release_date'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['ok'] == true && body['data'] is List) {
          return (body['data'] as List).where((track) => track['id'] != null).map((track) {
            final String id = track['id'].toString();
            final String title = track['title'] ?? 'Unknown Title';

            String artistName = 'Unknown Artist';
            if (track['artists'] is List && (track['artists'] as List).isNotEmpty) {
              final firstArtistEntry = track['artists'][0];
              if (firstArtistEntry is List && firstArtistEntry.length > 1) {
                artistName = firstArtistEntry[1]['name'] ?? 'Unknown Artist';
              }
            }

            String category = 'General';
            if (track['categories'] is List && (track['categories'] as List).isNotEmpty) {
              final firstCatEntry = track['categories'][0];
              if (firstCatEntry is List && firstCatEntry.length > 1) {
                category = firstCatEntry[1]['name'] ?? 'General';
              }
            }

            // Map API categories to app categories
            final String lowerCat = category.toLowerCase();
            if (lowerCat.contains('meditative') || lowerCat.contains('calm') || lowerCat.contains('peaceful') || lowerCat.contains('relaxing')) {
              category = 'Mindfulness';
            } else if (lowerCat.contains('workout') || lowerCat.contains('sports') || lowerCat.contains('energetic')) {
              category = 'Workout';
            } else if (lowerCat.contains('lofi') || lowerCat.contains('study') || lowerCat.contains('ambient')) {
              category = 'Studying';
            } else if (lowerCat.contains('corporate') || lowerCat.contains('inspiring') || lowerCat.contains('technology')) {
              category = 'Productivity';
            } else if (lowerCat.contains('nature') || lowerCat.contains('vlog')) {
              category = 'Health';
            } else {
              category = 'General';
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
        }
      }
      return [];
    } catch (e) {
      print('Error fetching music: $e');
      return [];
    }
  }
}
