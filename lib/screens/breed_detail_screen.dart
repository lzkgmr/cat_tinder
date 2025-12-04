import 'package:flutter/material.dart';
import '../models/breed.dart';

class BreedDetailScreen extends StatelessWidget {
  final Breed breed;
  final Widget imageWidget;
  const BreedDetailScreen({super.key, required this.breed, required this.imageWidget});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 242, 242, 242),
      appBar: AppBar(title: Text(breed.name, style: const TextStyle(fontWeight: FontWeight.w600)), backgroundColor: Color.fromARGB(255, 242, 242, 242)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imageWidget,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[100],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    breed.description ?? 'No description',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adaptability',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[100],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(5, (index) {
                      int rating = breed.adaptability ?? 0;
                      return Icon(
                        Icons.star,
                        color: index < rating ? Colors.amber : Colors.grey[300],
                        size: 24,
                      );
                    }),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Intelligence',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[100],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(5, (index) {
                      int rating = breed.intelligence ?? 0;
                      return Icon(
                        Icons.star,
                        color: index < rating ? Colors.amber : Colors.grey[300],
                        size: 24,
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCharacteristic('Life span', breed.lifeSpan),
                _buildCharacteristic('Weight', breed.weightMetric),
              ],
            ),
            const SizedBox(height: 16),
            Text('Origin: ${breed.origin ?? "Unknown"}', style: const TextStyle(fontSize: 14)),
            Text('Temperament: ${breed.temperament ?? "Unknown"}', style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacteristic(String name, dynamic value) {
    return Column(
      children: [
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value?.toString() ?? 'N/A'),
      ],
    );
  }
}
