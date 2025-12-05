import 'package:flutter/material.dart';
import '../models/breed.dart';
import '../services/cat_api_service.dart';
import 'breed_detail_screen.dart';

class BreedListScreen extends StatefulWidget {
  const BreedListScreen({super.key});

  @override
  State<BreedListScreen> createState() => _BreedListScreenState();
}

class _BreedListScreenState extends State<BreedListScreen> {
  final CatApiService api = CatApiService();
  late Future<List<Breed>> futureBreeds;

  @override
  void initState() {
    super.initState();
    futureBreeds = api.fetchBreeds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cat Breeds',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 242, 242, 242),
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 242, 242, 242),
      body: FutureBuilder<List<Breed>>(
        future: futureBreeds,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final breeds = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: breeds.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final breed = breeds[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BreedDetailScreen(
                        breed: breed,
                        imageWidget: Image.network(
                          breed.imageUrl ?? '',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(102, 0, 0, 0),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        child: Image.network(
                          breed.imageUrl ?? '',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Название породы
                      Expanded(
                        child: Text(
                          breed.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
