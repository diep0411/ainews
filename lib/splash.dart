import 'package:ai_new/resource/images.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset(
          Splash.splash,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}