class Breed {
  final String id;
  final String name;
  final String? temperament;
  final String? origin;
  final String? description;
  final String? lifeSpan;
  final String? weightMetric;
  final int? adaptability;
  final int? intelligence;
  final String? imageUrl;

  Breed({
    required this.id,
    required this.name,
    this.temperament,
    this.origin,
    this.description,
    this.lifeSpan,
    this.weightMetric,
    this.adaptability,
    this.intelligence,
    this.imageUrl,
  });

  factory Breed.fromJson(Map<String, dynamic> json) {
    return Breed(
      id: json['id'] as String,
      name: json['name'] as String,
      temperament: json['temperament'] as String?,
      origin: json['origin'] as String?,
      description: json['description'] as String?,
      lifeSpan: json['life_span'] as String?,
      weightMetric: json['weight'] != null && json['weight']['metric'] != null
          ? json['weight']['metric'] as String
          : null,
      adaptability: json['adaptability'] is int ? json['adaptability'] as int : null,
      intelligence: json['intelligence'] is int ? json['intelligence'] as int : null,
      imageUrl: json['image'] != null ? (json['image']['url'] as String?) : null,
    );
  }
}