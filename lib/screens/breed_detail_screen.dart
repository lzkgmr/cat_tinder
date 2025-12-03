import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/cat_api_service.dart';
import '../models/breed.dart';

class BreedDetailScreen extends StatelessWidget {
  final Breed breed;
  const BreedDetailScreen({super.key, required this.breed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(breed.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (breed.imageUrl != null)
              CachedNetworkImage(
                imageUrl: breed.imageUrl!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                placeholder: (_, __) => const CircularProgressIndicator(),
                errorWidget: (_, __, ___) => const Icon(Icons.error),
              ),
            const SizedBox(height: 16),
            Text(breed.description ?? 'No description', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCharacteristic('Adaptability', breed.adaptability),
                _buildCharacteristic('Intelligence', breed.intelligence),
              ],
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
