import 'package:cat_tinder/di/di_container.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/router/app_start_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final di = await AppDiContainer.create();
  runApp(MyApp(di: di));
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
