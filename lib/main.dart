import 'package:flutter/material.dart';
import 'services/cat_api_service.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final api = CatApiService(apiKey: 'live_K7HtYPDK7wAbiddICuTClSn5wwHOj91lvCItPQ4cDQztwupQHk4IQynylyXu1daB');

    return MaterialApp(
      title: 'CatTinder',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: MainScreen(api: api),
    );
  }
}
