import 'package:cached_network_image/cached_network_image.dart';
import 'package:cat_tinder/di/di_container.dart';
import 'package:cat_tinder/domain/entities/cat.dart';
import 'package:cat_tinder/presentation/cubit/liked_cats/liked_cats_cubit.dart';
import 'package:cat_tinder/presentation/cubit/liked_cats/liked_cats_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LikedCatsScreen extends StatelessWidget {
  const LikedCatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final di = context.read<AppDiContainer>();
    return BlocProvider(
      create: (context) => di.makeLikedCatsCubit()..load(),
      child: const _LikedCatsView(),
    );
  }
}

class _LikedCatsView extends StatelessWidget {
  const _LikedCatsView();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 10) {
          Navigator.of(context).pop();
        }
      },
      child: BlocBuilder<LikedCatsCubit, LikedCatsState>(
        builder: (context, state) {
          return Scaffold(
            appBar: _buildAppBar(context, state.cats.isNotEmpty),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, LikedCatsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null) {
      return Center(child: Text(state.errorMessage!));
    }
    if (state.cats.isEmpty) {
      return const Center(
        child: Text('No liked cats yet!', style: TextStyle(fontSize: 18)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.6,
      ),
      itemCount: state.cats.length,
      itemBuilder: (context, index) {
        final cat = state.cats[index];
        return _buildCatStack(context, cat);
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, bool hasCats) {
    return AppBar(
      title: const Text(
        'Liked Cats',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.pink[100],
      actions: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: hasCats ? () => _clearAll(context) : null,
        ),
      ],
    );
  }

  Widget _buildCatStack(BuildContext context, Cat cat) {
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
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => context.read<LikedCatsCubit>().remove(cat),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color.fromARGB(156, 255, 255, 255),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.heart_broken, color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _clearAll(BuildContext context) async {
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

    if (confirm == true && context.mounted) {
      await context.read<LikedCatsCubit>().clear();
    }
  }
}
