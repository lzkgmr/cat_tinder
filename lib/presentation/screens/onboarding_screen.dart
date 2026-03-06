import 'dart:math' as math;

import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  final Future<void> Function() onCompleted;

  const OnboardingScreen({super.key, required this.onCompleted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isCompleting = false;

  static const List<_OnboardingStep> _steps = [
    _OnboardingStep(
      title: 'Swipe Cats',
      description:
          'Swipe right if you like a cat, swipe left if you want to skip.',
      color: Color.fromARGB(255, 255, 228, 234),
      icon: Icons.swipe_rounded,
    ),
    _OnboardingStep(
      title: 'Breed Details',
      description:
          'Tap on a cat photo to open full breed details and useful facts.',
      color: Color.fromARGB(255, 255, 239, 219),
      icon: Icons.info_outline_rounded,
    ),
    _OnboardingStep(
      title: 'Breeds & Likes',
      description:
          'Use bottom tabs to open the breeds list and your liked cats.',
      color: Color.fromARGB(255, 229, 243, 255),
      icon: Icons.pets_rounded,
    ),
  ];

  bool get _isLastStep => _currentIndex == _steps.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 242, 242),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _steps.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    return _buildStepCard(step, index);
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildIndicators(),
              const SizedBox(height: 16),
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(_OnboardingStep step, int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, _) {
        final page = _pageController.hasClients
            ? (_pageController.page ?? _currentIndex.toDouble())
            : _currentIndex.toDouble();
        final distance = (page - index).abs().clamp(0.0, 1.0);
        final opacity = 1 - (distance * 0.35);
        final translateY = distance * 14;
        final phase = (page - index) * math.pi;
        final dx = math.sin(phase) * 18;
        final scale = 1 - (distance * 0.08);
        final angle = math.sin(phase) * 0.08;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: step.color,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(31, 0, 0, 0),
                    blurRadius: 14,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final heroHeight = constraints.maxHeight * 0.75;
                  final heroSize = constraints.maxWidth * 0.78;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: heroHeight,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Transform.translate(
                            offset: Offset(dx, 0),
                            child: Transform.rotate(
                              angle: angle,
                              child: Transform.scale(
                                scale: scale,
                                child: SizedBox(
                                  width: heroSize,
                                  height: heroSize,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color.fromARGB(
                                                38,
                                                0,
                                                0,
                                                0,
                                              ),
                                              blurRadius: 18,
                                              offset: Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(28),
                                        child: Image.asset(
                                          'assets/icons/cat_icon.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      Positioned(
                                        right: heroSize * 0.1,
                                        bottom: heroSize * 0.1,
                                        child: Container(
                                          width: 62,
                                          height: 62,
                                          decoration: BoxDecoration(
                                            color: Colors.pinkAccent,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            ),
                                          ),
                                          child: Icon(
                                            step.icon,
                                            size: 34,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        step.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        step.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 17, height: 1.4),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_steps.length, (index) {
        final isActive = index == _currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 9,
          height: 9,
          decoration: BoxDecoration(
            color: isActive ? Colors.pinkAccent : Colors.grey[350],
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        TextButton(
          onPressed: _isCompleting ? null : _complete,
          child: const Text('Skip'),
        ),
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          ),
          onPressed: _isCompleting ? null : _onNextPressed,
          child: Text(_isLastStep ? 'Start' : 'Next'),
        ),
      ],
    );
  }

  Future<void> _onNextPressed() async {
    if (_isLastStep) {
      await _complete();
      return;
    }
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _complete() async {
    if (_isCompleting) return;
    setState(() {
      _isCompleting = true;
    });
    await widget.onCompleted();
    if (!mounted) return;
    setState(() {
      _isCompleting = false;
    });
  }
}

class _OnboardingStep {
  final String title;
  final String description;
  final Color color;
  final IconData icon;

  const _OnboardingStep({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
  });
}
