import 'package:flutter/material.dart';
import '../models/cat.dart';
import '../services/storage_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LikedCatsScreen extends StatefulWidget {
  final StorageService storage;

  const LikedCatsScreen({super.key, required this.storage});

  @override
  State<LikedCatsScreen> createState() => _LikedCatsScreenState();
}

class _LikedCatsScreenState extends State<LikedCatsScreen> {
  late List<Cat> likedCats;

  @override
  void initState() {
    super.initState();
    likedCats = widget.storage.getLikedCats();
  }

  void _removeCat(Cat cat) {
    setState(() {
      likedCats.removeWhere((c) => c.id == cat.id);
    });
    widget.storage.removeLikedCat(cat.id);
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear liked cats?'),
        content: const Text('Are you sure you want to remove all liked cats?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.storage.clearLikedCats();
      setState(() {
        likedCats.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 10) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: likedCats.isEmpty
            ? const Center(
                child: Text(
                  'No liked cats yet!',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.6,
                ),
                itemCount: likedCats.length,
                itemBuilder: (context, index) {
                  final cat = likedCats[index];
                  return _buildCatStack(cat);
                },
              ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Liked Cats',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.pink[100],
      actions: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: likedCats.isEmpty ? null : _clearAll,
        ),
      ],
    );
  }

  Widget _buildCatStack(Cat cat) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: cat.imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) =>
                        const Icon(Icons.image_not_supported),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.white,
                  child: Text(
                    cat.breed,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildHertButton(cat),
      ],
    );
  }

  Widget _buildHertButton(Cat cat) {
    return Positioned(
      top: 8,
      right: 8,
      child: GestureDetector(
        onTap: () => _removeCat(cat),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color.fromARGB(156, 255, 255, 255),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.heart_broken, color: Colors.red),
        ),
      ),
    );
  }
}
