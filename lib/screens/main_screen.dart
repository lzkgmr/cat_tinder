import 'package:cached_network_image/cached_network_image.dart';
import 'package:cat_tinder/screens/breeds_list_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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
  int currentIndex = 0;
  int likes = 0;

  bool isLoading = false;
  bool isImageLoaded = false;

  Offset cardOffset = Offset.zero;
  double rotation = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCats();
  }

  Future<void> _loadCats() async {
    try {
      List<Cat> cats = await api.fetchCats();
      setState(() {
        _cats.addAll(cats);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cats: $e');
      }
    }
  }

  Cat? get currentCat => (_cats.isNotEmpty && currentIndex < _cats.length)
      ? _cats[currentIndex]
      : null;

  void _onLike() {
    setState(() => likes++);
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
              child: Row(
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
              ),
            ),
          ),

          Positioned(
            top: 120,
            left: 0,
            right: 0,
            bottom: 40,
            child: _cats.isEmpty
                ? Center(child: Lottie.asset('assets/lottie/cat_loading.json'))
                : CardSwiper(
                    controller: _cardSwiperController,
                    cardsCount: _cats.length,
                    onSwipe: _onSwipe,
                    onUndo: _onUndo,
                    numberOfCardsDisplayed: 3,
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
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(15),
                                    ),
                                    child: Image.network(
                                      cat.imageUrl,
                                      width: double.infinity,
                                      height: screenHeight * 0.59,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 6,
                                    ),
                                    child: Text(
                                      cat.breed,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      right: 16,
                                      bottom: 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        SizedBox(
                                          width: screenWidth * 0.3,
                                          child: DislikeButton(
                                            onPressed: _onDislike,
                                          ),
                                        ),
                                        SizedBox(
                                          width: screenWidth * 0.3,
                                          child: LikeButton(onPressed: _onLike),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, color: Color.fromARGB(255, 242, 242, 242)),
          BottomAppBar(
            color: Color.fromARGB(255, 242, 242, 242),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.person,
                    color: Colors.pinkAccent,
                    size: 36,
                  ),
                  onPressed: _onTapImage,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.pets,
                    color: Colors.pinkAccent,
                    size: 36,
                  ),
                  onPressed: _onTapPow,
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
                      onPressed: _onTapImage,
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
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    setState(() {
      if (direction == CardSwiperDirection.right) {
        likes++;
        _likedCats.add(_cats[previousIndex]);
      }

      if (currentIndex != null) {
        this.currentIndex = currentIndex;
      }
    });

    if (previousIndex % 10 > 3) {
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
