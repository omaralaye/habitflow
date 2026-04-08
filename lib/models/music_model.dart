class MusicModel {
  final String id;
  final String title;
  final String artist;
  final String category;
  final String duration;
  final String? url;

  MusicModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.category,
    required this.duration,
    this.url,
  });
}
