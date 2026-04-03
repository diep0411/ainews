import 'package:ai_new/services/news_service.dart';
import 'package:ai_new/services/save_service.dart';
import 'package:ai_new/splash.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance(); // warm-up cache
  await SaveService.init();             // load saved articles from disk
  await NewsService.preload();          // pre-load all articles & source names
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: SplashPage(),
    );
  }
}

