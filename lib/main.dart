import 'package:cat_tinder/di/di_container.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/router/app_start_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    final di = await AppDiContainer.create();
    runApp(MyApp(di: di));
  } catch (_) {
    runApp(const _BootstrapErrorApp());
  }
}

class MyApp extends StatelessWidget {
  final AppDiContainer di;

  const MyApp({super.key, required this.di});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AppDiContainer>.value(
      value: di,
      child: MaterialApp(
        title: 'CatTinder',
        theme: ThemeData(primarySwatch: Colors.orange),
        home: const AppStartRouter(),
      ),
    );
  }
}

class _BootstrapErrorApp extends StatelessWidget {
  const _BootstrapErrorApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Failed to start app. Please restart and check Firebase setup.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
