import 'package:ai_new/homePage.dart';
import 'package:ai_new/welcomePage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;

  static const String _launchKey = 'has_launched_before';
  static const Duration _duration = Duration(milliseconds: 2800);

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, duration: _duration);
    _startLoading();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  Future<void> _startLoading() async {
    _progress.forward();

    final results = await Future.wait([
      Future.delayed(_duration),
      _checkFirstLaunch(),
    ]);

    if (!mounted) return;
    final isFirst = results[1] as bool;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => isFirst ? const Welcomepage() : const Homepage(),
      ),
    );
  }

  Future<bool> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunched = prefs.getBool(_launchKey) ?? false;
    if (!hasLaunched) await prefs.setBool(_launchKey, true);
    return !hasLaunched;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _SplashCard(progress: _progress),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: Text(
                'HIGH-END INTELLIGENCE  •  DAILY BRIEFING',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashCard extends StatelessWidget {
  final AnimationController progress;

  const _SplashCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.8).clamp(280.0, 380.0).toDouble();

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 36),
          const Text(
            'THE\nMONOLITH',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 46,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              height: 1.02,
              letterSpacing: 1.7,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Curating your world...',
            style: TextStyle(
              fontSize: 15,
              color: Colors.blue.shade400,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 34),
          AnimatedBuilder(
            animation: progress,
            builder: (_, __) => LinearProgressIndicator(
              value: progress.value,
              minHeight: 5,
              color: Colors.blue.shade400,
              backgroundColor: Colors.blue.shade100,
            ),
          ),
        ],
      ),
    );
  }
}