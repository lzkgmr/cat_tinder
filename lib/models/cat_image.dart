import '../models/breed.dart';

class CatImage {
  final String id;
  final String url;
  final int width;
  final int height;
  final List<Breed> breeds;

  CatImage({
    required this.id,
    required this.url,
    required this.width,
    required this.height,
    required this.breeds,
  });

  factory CatImage.fromJson(Map<String, dynamic> json) {
    final breedsJson = (json['breeds'] as List?) ?? [];
    return CatImage(
      id: json['id'] as String,
      url: json['url'] as String,
      width: (json['width'] is int) ? json['width'] as int : int.tryParse('${json['width']}') ?? 0,
      height:
          (json['height'] is int) ? json['height'] as int : int.tryParse('${json['height']}') ?? 0,
      breeds: breedsJson.map((e) => Breed.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}