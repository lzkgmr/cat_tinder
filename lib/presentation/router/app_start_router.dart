import 'package:cat_tinder/di/di_container.dart';
import 'package:cat_tinder/presentation/screens/login_screen.dart';
import 'package:cat_tinder/presentation/screens/main_screen.dart';
import 'package:cat_tinder/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppStartRouter extends StatefulWidget {
  const AppStartRouter({super.key});

  @override
  State<AppStartRouter> createState() => _AppStartRouterState();
}

class _AppStartRouterState extends State<AppStartRouter> {
  bool? _isOnboardingCompleted;
  bool? _isAuthorized;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final di = context.read<AppDiContainer>();
    final completed = await di.isOnboardingCompletedUseCase();
    final authorized = completed ? await di.isAuthorizedUseCase() : false;
    if (!mounted) return;
    setState(() {
      _isOnboardingCompleted = completed;
      _isAuthorized = authorized;
    });
  }

  Future<void> _completeOnboarding() async {
    final di = context.read<AppDiContainer>();
    await di.completeOnboardingUseCase();
    final authorized = await di.isAuthorizedUseCase();
    if (!mounted) return;
    setState(() {
      _isOnboardingCompleted = true;
      _isAuthorized = authorized;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isOnboardingCompleted == null || _isAuthorized == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isOnboardingCompleted == false) {
      return OnboardingScreen(onCompleted: _completeOnboarding);
    }

    if (_isAuthorized == false) {
      return const LoginScreen();
    }

    return const MainScreen();
  }
}
