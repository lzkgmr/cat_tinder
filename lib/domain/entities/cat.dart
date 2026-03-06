class Cat {
  final String id;
  final String imageUrl;
  final String breed;
  final String description;
  final String temperament;
  final String origin;
  final String lifeSpan;
  final String breedId;

  Cat({
    required this.id,
    required this.imageUrl,
    required this.breed,
    required this.description,
    required this.temperament,
    required this.origin,
    required this.lifeSpan,
    required this.breedId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'breed': breed,
      'description': description,
      'temperament': temperament,
      'origin': origin,
      'lifeSpan': lifeSpan,
      'breedId': breedId,
    };
  }

  factory Cat.fromJson(Map<String, dynamic> json) {
    return Cat(
      id: json['id'],
      imageUrl: json['imageUrl'],
      breed: json['breed'],
      description: json['description'],
      temperament: json['temperament'],
      origin: json['origin'],
      lifeSpan: json['lifeSpan'],
      breedId: json['breedId'],
    );
  }
}
