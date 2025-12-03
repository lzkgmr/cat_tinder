import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/cat_api_service.dart';
import '../models/cat_image.dart';
import 'breed_detail_screen.dart';

class MainScreen extends StatefulWidget {
  final CatApiService api;
  const MainScreen({super.key, required this.api});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  CatImage? currentCat;
  int likes = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRandomCat();
  }

  Future<void> _loadRandomCat() async {
    setState(() {
      isLoading = true;
    });
    try {
      final cat = await widget.api.fetchRandomCat();
      setState(() {
        currentCat = cat;
      });
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  void _onLike() {
    setState(() {
      likes++;
    });
    _loadRandomCat();
  }

  void _onDislike() {
    _loadRandomCat();
  }

  void _onTapImage() {
    if (currentCat == null) return;

    final breed = currentCat!.breeds.isNotEmpty ? currentCat!.breeds.first : null;
    if (breed == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BreedDetailScreen(breed: breed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CatTinder'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text('Likes: $likes')),
          ),
        ],
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : currentCat == null
                ? const Text('No cat loaded')
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _onTapImage,
                        child: CachedNetworkImage(
                          imageUrl: currentCat!.url,
                          width: 300,
                          height: 300,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const CircularProgressIndicator(),
                          errorWidget: (_, __, ___) => const Icon(Icons.error),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currentCat!.breeds.isNotEmpty
                            ? currentCat!.breeds.first.name
                            : 'Unknown breed',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _onDislike,
                            icon: const Icon(Icons.close),
                            label: const Text('Dislike'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          ),
                          const SizedBox(width: 32),
                          ElevatedButton.icon(
                            onPressed: _onLike,
                            icon: const Icon(Icons.favorite),
                            label: const Text('Like'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
      ),
    );
  }
}
