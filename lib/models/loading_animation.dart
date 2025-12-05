import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';

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
