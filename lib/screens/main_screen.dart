import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import '../services/cat_api_service.dart';
import '../models/cat_image.dart';
import 'breed_detail_screen.dart';

class LoadingAnimation extends StatelessWidget {
  final double size;
  const LoadingAnimation({super.key, this.size = 150});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset('assets/lottie/cat_loading.json'),
    );
  }
}

class MainScreen extends StatefulWidget {
  final CatApiService api;
  const MainScreen({super.key, required this.api});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  List<CatImage> cats = [];
  int currentIndex = 0;
  int likes = 0;

  bool isLoading = false;
  bool isAnimating = false;
  bool isImageLoaded = false;

  Offset cardOffset = Offset.zero;
  double rotation = 0.0;

  late AnimationController _animationController;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadCats(3);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Один единственный слушатель — обновляет позицию если _slideAnimation задана.
    _animationController.addListener(() {
      if (_slideAnimation != null) {
        final value = _slideAnimation!.value;
        // Обновляем состояние только если действительно изменилось, чтобы уменьшить лишние setState
        if (value != cardOffset) {
          setState(() {
            cardOffset = value;
            rotation = cardOffset.dx / 300;
          });
        }
      }
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextCat();
        _animationController.reset();

        setState(() {
          cardOffset = Offset.zero;
          rotation = 0.0;
          isAnimating = false;
          isImageLoaded = false; // сброс перед следующей карточкой
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  CatImage? get currentCat =>
      (cats.isNotEmpty && currentIndex < cats.length) ? cats[currentIndex] : null;

  Future<void> _loadCats(int count) async {
    setState(() => isLoading = true);
    try {
      for (int i = 0; i < count; i++) {
        final cat = await widget.api.fetchRandomCat();
        cats.add(cat);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => isLoading = false);
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
    setState(() => likes++);
    _animateCard(const Offset(500, 0));
  }

  void _onDislike() {
    _animateCard(const Offset(-500, 0));
  }

  void _animateCard(Offset endOffset) {
    if (currentCat == null) return;

    setState(() => isAnimating = true);

    // создаём новую анимацию, но НЕ добавляем слушатель здесь
    _slideAnimation = Tween<Offset>(begin: cardOffset, end: endOffset).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Запускаем контроллер — в listener (в initState) мы используем _slideAnimation, поэтому он начнёт обновлять cardOffset.
    _animationController.forward(from: 0.0);
  }

  void _nextCat() {
    if (currentIndex < cats.length - 1) {
      setState(() => currentIndex++);
    } else {
      _loadCats(3);
      setState(() => currentIndex++);
    }
    // при смене карточки сброс флага загрузки (кнопки будут скрыты)
    setState(() => isImageLoaded = false);
  }

  void _onTapImage() {
    final cat = currentCat;
    if (cat == null) return;

    final breed = cat.breeds.isNotEmpty ? cat.breeds.first : null;
    if (breed == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BreedDetailScreen(breed: breed)),
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (isAnimating) return;
    setState(() {
      cardOffset += details.delta;
      rotation = cardOffset.dx / 300;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (isAnimating) return;

    if (cardOffset.dx > 150) {
      _onLike();
    } else if (cardOffset.dx < -150) {
      _onDislike();
    } else {
      setState(() {
        cardOffset = Offset.zero;
        rotation = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cat = currentCat;
    // print в build нормально срабатывает при каждом rebuild, но теперь rebuild'ы не будут бесконечными
    print(cat?.url);
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
        child: cat == null
            ? const LoadingAnimation()
            : GestureDetector(
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                onTap: _onTapImage,
                child: Transform.translate(
                  offset: cardOffset,
                  child: Transform.rotate(
                    angle: rotation,
                    child: SizedBox(
                      width: 300,
                      height: 420,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(0), // или твои углы
                              child: Stack(
                                fit: StackFit.expand, // <-- главное!
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: cat.url,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(color: Colors.grey[300]), // растягиваем
                                    errorWidget: (_, __, ___) => const Icon(Icons.error),
                                    imageBuilder: (context, provider) {
                                      if (!isImageLoaded) {
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          if (mounted) setState(() => isImageLoaded = true);
                                        });
                                      }
                                      return Image(image: provider, fit: BoxFit.cover);
                                    },
                                  ),

                                  if (!isImageLoaded) Container(color: Colors.white70),

                                  if (!isImageLoaded)
                                    const Center(
                                      child: LoadingAnimation(size: 100),
                                    ),
                                ],
                              ),
                            ),
                          ),


                          const SizedBox(height: 16),

                          // // Название породы (фиксированная высота)
                          // SizedBox(
                          //   height: 28,
                          //   child: Text(
                          //     cat.breeds.isNotEmpty ? cat.breeds.first.name : '',
                          //     style: const TextStyle(
                          //         fontSize: 20, fontWeight: FontWeight.bold),
                          //     textAlign: TextAlign.center,
                          //   ),
                          // ),

                          // const SizedBox(height: 24),

                          // Показываем кнопки только после загрузки изображения
                          if (isImageLoaded)
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
                  ),
                ),
              ),
      ),
      backgroundColor: Colors.white70,
    );
  }
}
