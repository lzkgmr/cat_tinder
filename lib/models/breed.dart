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
  final String? countryCode;

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
    this.countryCode,
  });
}
