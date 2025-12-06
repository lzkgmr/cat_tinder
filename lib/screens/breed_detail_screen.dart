import 'package:flutter/material.dart';
import '../models/breed.dart';

class BreedDetailScreen extends StatelessWidget {
  final Breed breed;
  final Widget imageWidget;

  const BreedDetailScreen({
    super.key,
    required this.breed,
    required this.imageWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 10) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 242, 242, 242),
        appBar: AppBar(
          title: Text(
            breed.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color.fromARGB(255, 242, 242, 242),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPic(),
              const SizedBox(height: 12),
              if (breed.temperament != null) _buildTemps(),
              const SizedBox(height: 12),
              if (breed.origin != null) _buildOrigin(),
              const SizedBox(height: 16),
              _buildDescription(),
              const SizedBox(height: 16),
              _buildRatingContainer('Adaptability', breed.adaptability ?? 0),
              const SizedBox(height: 16),
              _buildRatingContainer('Intelligence', breed.intelligence ?? 0),
              const SizedBox(height: 16),
              _buildLifeSpanAndWeight(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPic() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: imageWidget,
    );
  }

  Widget _buildTemps() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      children: breed.temperament!
          .split(',')
          .map(
            (temp) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                temp.trim(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.pinkAccent,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildOrigin() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // flag
          Text(
            countryCodeToEmoji(breed.countryCode ?? ''), // ← флаг
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          // country name
          Text(
            breed.origin!,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bio',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.pink[100],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            breed.description ?? 'No description',
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildLifeSpanAndWeight() {
    return Row(
      children: [
        Expanded(
          child: _buildStatContainer('Life span', '${breed.lifeSpan} years'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatContainer('Weight', '${breed.weightMetric} kg'),
        ),
      ],
    );
  }

  Widget _buildRatingContainer(String title, int rating) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.pink[100],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                Icons.star,
                color: index < rating ? Colors.amber : Colors.grey[300],
                size: 24,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatContainer(String title, String? value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.pink[100],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(value ?? 'N/A', style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

String countryCodeToEmoji(String countryCode) {
  final code = countryCode.toUpperCase();
  if (code.length != 2) return '';
  return String.fromCharCodes([
    code.codeUnitAt(0) + 0x1F1E6 - 65,
    code.codeUnitAt(1) + 0x1F1E6 - 65,
  ]);
}
