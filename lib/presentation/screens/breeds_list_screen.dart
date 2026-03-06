import 'package:cat_tinder/domain/entities/breed.dart';
import 'package:cat_tinder/di/di_container.dart';
import 'package:cat_tinder/presentation/cubit/breeds/breeds_cubit.dart';
import 'package:cat_tinder/presentation/cubit/breeds/breeds_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'breed_detail_screen.dart';

class BreedListScreen extends StatelessWidget {
  const BreedListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final di = context.read<AppDiContainer>();
    return BlocProvider(
      create: (context) => di.makeBreedsCubit()..loadBreeds(),
      child: const _BreedListView(),
    );
  }
}

class _BreedListView extends StatelessWidget {
  const _BreedListView();

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
        backgroundColor: const Color.fromARGB(255, 242, 242, 242),
        body: BlocBuilder<BreedsCubit, BreedsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.errorMessage != null) {
              return Center(child: Text(state.errorMessage!));
            }
            if (state.breeds.isEmpty) {
              return const Center(child: Text('No breeds found'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.breeds.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final breed = state.breeds[index];

                return GestureDetector(
                  onTap: () => _onTapCell(context, breed),
                  child: Container(
                    height: 120,
                    decoration: _buildDecoration(),
                    child: Row(
                      children: [
                        _buildPic(breed.imageUrl ?? ''),
                        const SizedBox(width: 12),
                        _buildBreedName(breed.name),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

AppBar _buildAppBar() {
  return AppBar(
    title: const Text(
      'Cat Breeds',
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    backgroundColor: const Color.fromARGB(255, 242, 242, 242),
    elevation: 0,
  );
}

Future<void> _onTapCell(BuildContext context, Breed breed) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BreedDetailScreen(
        breed: breed,
        imageWidget: Image.network(breed.imageUrl ?? '', fit: BoxFit.cover),
      ),
    ),
  );
}

BoxDecoration _buildDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(
        color: Color.fromARGB(102, 0, 0, 0),
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  );
}

Widget _buildPic(String url) {
  return ClipRRect(
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(16),
      bottomLeft: Radius.circular(16),
    ),
    child: Image.network(
      url,
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
  );
}

Widget _buildBreedName(String breedName) {
  return Expanded(
    child: Text(
      breedName,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    ),
  );
}
