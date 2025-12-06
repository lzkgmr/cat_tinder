import 'package:cached_network_image/cached_network_image.dart';
import 'package:cat_tinder/screens/breeds_list_screen.dart';
import 'package:cat_tinder/screens/liked_cats_screen.dart';
import 'package:cat_tinder/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/cat_api_service.dart';
import '../models/cat.dart';
import 'breed_detail_screen.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  final CatApiService api = CatApiService(
    apiKey:
        'live_K7HtYPDK7wAbiddICuTClSn5wwHOj91lvCItPQ4cDQztwupQHk4IQynylyXu1daB',
  );
  final List<Cat> _cats = [];
  final List<Cat> _likedCats = [];
  final CardSwiperController _cardSwiperController = CardSwiperController();
  late StorageService _storage;
  int currentIndex = 0;
  int likes = 0;

  Offset cardOffset = Offset.zero;
  double rotation = 0.0;

  @override
  void initState() {
    super.initState();
    _initStorage();
    _loadCats();
  }

  Future<void> _initStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _storage = StorageService(prefs);

    setState(() {
      likes = _storage.getLikes();
    });
  }

  Future<void> _loadCats() async {
    try {
      await for (final cat in api.fetchCatsStream(limit: 10)) {
        if (!mounted) return;
        setState(() {
          _cats.add(cat);
        });
      }
    } catch (e) {
      if (kDebugMode) print('Error loading cats: $e');
    }
  }

  Cat? get currentCat => (_cats.isNotEmpty && currentIndex < _cats.length)
      ? _cats[currentIndex]
      : null;

  void _onLike() {
    _cardSwiperController.swipe(CardSwiperDirection.right);
  }

  void _onDislike() {
    _cardSwiperController.swipe(CardSwiperDirection.left);
  }

  Future _onTapImage() async {
    final cat = currentCat;
    if (cat == null) return;
    if (cat.breedId.isEmpty) return;

    final breed = await api.fetchBreedById(cat.breedId);
    if (breed == null || cat.imageUrl.isEmpty) return;
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BreedDetailScreen(
          breed: breed,
          imageWidget: CachedNetworkImage(imageUrl: cat.imageUrl),
        ),
      ),
    );
  }

  Future _onTapPow() async {
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BreedListScreen()),
    );
  }

  Future _onTapHeart() async {
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LikedCatsScreen(storage: _storage)),
    );

    if (!mounted) return;

    setState(() {
      likes = _storage.getLikes();
      _likedCats
        ..clear()
        ..addAll(_storage.getLikedCats());
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 242, 242, 242),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 10),
              child: _buildTopBar(),
            ),
          ),

          Positioned(
            top: 80,
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildCard(screenHeight, screenWidth),
          ),

        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, color: Color.fromARGB(255, 242, 242, 242)),
          _buildBottomAppBar(),
        ],
      ),
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

  Widget _buildCard(double screenHeight, double screenWidth) {
    return _cats.isEmpty
        ? Center(child: Lottie.asset('assets/lottie/cat_loading.json'))
        : CardSwiper(
            controller: _cardSwiperController,
            cardsCount: _cats.length,
            onSwipe: _onSwipe,
            onUndo: _onUndo,
            numberOfCardsDisplayed: _cats.length >= 3 ? 3 : _cats.length,
            backCardOffset: const Offset(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            allowedSwipeDirection: const AllowedSwipeDirection.only(
              left: true,
              right: true,
            ),
            cardBuilder:
                (context, index, percentThresholdX, percentThresholdY) {
                  final cat = _cats[index];
                  return GestureDetector(
                    onTap: () => _onTapImage(),
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


  Widget _buildBottomAppBar() {
    return BottomAppBar(
      color: Color.fromARGB(255, 242, 242, 242),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [_buildPowButton(), _buildHeartButton()],
      ),
    );
  }

  Widget _buildPowButton() {
    return IconButton(
      icon: const Icon(Icons.pets, color: Colors.pinkAccent, size: 36),
      onPressed: _onTapPow,
    );
  }

  Widget _buildHeartButton() {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.favorite, color: Colors.pinkAccent, size: 36),
          onPressed: _onTapHeart,
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
              '$likes',
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    final cat = _cats[previousIndex];

    if (direction == CardSwiperDirection.right) {
      setState(() {
        likes++;
        _likedCats.add(cat);
      });

      () async {
        await _storage.setLikes(likes);
        await _storage.addLikedCat(cat);
      }();
    }

    if (currentIndex != null) {
      setState(() {
        this.currentIndex = currentIndex;
      });
    }

    if (previousIndex % 10 > 3) {
      // не в setState
      _loadCats();
    }

    return true;
  }

  bool _onUndo(
    int? previousIndex,
    int currentIndex,
    CardSwiperDirection direction,
  ) {
    setState(() {
      this.currentIndex = currentIndex;
    });
    return true;
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
