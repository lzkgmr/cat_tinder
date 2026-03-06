import 'package:cached_network_image/cached_network_image.dart';
import 'package:cat_tinder/di/di_container.dart';
import 'package:cat_tinder/presentation/cubit/main/main_cubit.dart';
import 'package:cat_tinder/presentation/cubit/main/main_state.dart';
import 'package:cat_tinder/presentation/screens/breed_detail_screen.dart';
import 'package:cat_tinder/presentation/screens/breeds_list_screen.dart';
import 'package:cat_tinder/presentation/screens/liked_cats_screen.dart';
import 'package:cat_tinder/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:lottie/lottie.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final di = context.read<AppDiContainer>();
    return BlocProvider(
      create: (context) => di.makeMainCubit()..initialize(),
      child: const _MainScreenView(),
    );
  }
}

class _MainScreenView extends StatefulWidget {
  const _MainScreenView();

  @override
  State<_MainScreenView> createState() => _MainScreenViewState();
}

class _MainScreenViewState extends State<_MainScreenView> {
  final CardSwiperController _cardSwiperController = CardSwiperController();

  void _onLike() {
    _cardSwiperController.swipe(CardSwiperDirection.right);
  }

  void _onDislike() {
    _cardSwiperController.swipe(CardSwiperDirection.left);
  }

  Future<void> _onTapImage(BuildContext context) async {
    final cubit = context.read<MainCubit>();
    final state = cubit.state;
    final currentCat = state.currentCat;
    if (currentCat == null) return;

    final breed = await cubit.loadCurrentBreed();
    if (breed == null || currentCat.imageUrl.isEmpty) return;
    if (!context.mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BreedDetailScreen(
          breed: breed,
          imageWidget: CachedNetworkImage(imageUrl: currentCat.imageUrl),
        ),
      ),
    );
  }

  Future<void> _onTapPow(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BreedListScreen()),
    );
  }

  Future<void> _onTapHeart(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LikedCatsScreen()),
    );
    if (!context.mounted) return;
    await context.read<MainCubit>().refreshLikes();
  }

  Future<void> _onTapProfile(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 242, 242, 242),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _buildTopBar(),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _buildCard(
                        context: context,
                        state: state,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(
                height: 1,
                color: Color.fromARGB(255, 242, 242, 242),
              ),
              _buildBottomAppBar(context, state.likesCount),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Image.asset('assets/icons/cat_icon.png'),
        ),
        const SizedBox(width: 12),
        const Text(
          'pussycats',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Pacifico',
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required MainState state,
  }) {
    if (state.isLoading && state.cats.isEmpty) {
      return Center(child: Lottie.asset('assets/lottie/cat_loading.json'));
    }
    if (state.errorMessage != null && state.cats.isEmpty) {
      return Center(child: Text(state.errorMessage!));
    }
    if (state.cats.isEmpty) {
      return const Center(child: Text('No cats yet'));
    }

    return CardSwiper(
      controller: _cardSwiperController,
      cardsCount: state.cats.length,
      onSwipe: (previousIndex, currentIndex, direction) {
        context.read<MainCubit>().handleSwipe(
          previousIndex: previousIndex,
          nextIndex: currentIndex,
          liked: direction == CardSwiperDirection.right,
        );
        return true;
      },
      onUndo: (previousIndex, currentIndex, direction) {
        context.read<MainCubit>().handleUndo(currentIndex);
        return true;
      },
      numberOfCardsDisplayed: state.cats.length >= 3 ? 3 : state.cats.length,
      backCardOffset: const Offset(0, 40),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      allowedSwipeDirection: const AllowedSwipeDirection.only(
        left: true,
        right: true,
      ),
      cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
        final cat = state.cats[index];
        return GestureDetector(
          onTap: () => _onTapImage(context),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: Colors.pink[100],
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildPic(cat.imageUrl),
                      ),
                      _buildName(cat.breed),
                    ],
                  ),
                ),
                SizedBox(
                  height: 72,
                  child: _buildButtons(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPic(String url) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      child: CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, _) => Container(color: Colors.grey[300]),
        errorWidget: (context, _, _) => const Icon(Icons.error),
      ),
    );
  }

  Widget _buildName(String catBreed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
      child: Text(
        catBreed,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Center(child: DislikeButton(onPressed: _onDislike)),
          ),
          Expanded(
            child: Center(child: LikeButton(onPressed: _onLike)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAppBar(BuildContext context, int likesCount) {
    return BottomAppBar(
      color: const Color.fromARGB(255, 242, 242, 242),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.pets, color: Colors.pinkAccent, size: 36),
            onPressed: () => _onTapPow(context),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.favorite,
                  color: Colors.pinkAccent,
                  size: 36,
                ),
                onPressed: () => _onTapHeart(context),
              ),
              Positioned(
                top: 2,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$likesCount',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              color: Colors.pinkAccent,
              size: 36,
            ),
            onPressed: () => _onTapProfile(context),
          ),
        ],
      ),
    );
  }
}

class DislikeButton extends StatelessWidget {
  final VoidCallback onPressed;

  const DislikeButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.cancel, color: Colors.pinkAccent, size: 40),
      onPressed: onPressed,
    );
  }
}

class LikeButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LikeButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.favorite, color: Colors.pinkAccent, size: 40),
      onPressed: onPressed,
    );
  }
}
