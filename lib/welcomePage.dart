import 'package:ai_new/homePage.dart';
import 'package:flutter/material.dart';
import 'package:ai_new/resource/images.dart';

class Welcomepage extends StatelessWidget {
  const Welcomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EE),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F6F3),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: AspectRatio(
                              aspectRatio: 0.92,
                              child: Image.asset(
                                WelcomeRes.welcome,
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                              ),
                            ),
                          ),
                          const Positioned(
                            left: 12,
                            top: 12,
                            child: _CornerMark(alignment: _CornerAlignment.topLeft),
                          ),
                          const Positioned(
                            right: 12,
                            bottom: 12,
                            child: _CornerMark(alignment: _CornerAlignment.bottomRight),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Truth in the\nNoise.',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 27,
                              height: 1.02,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C1B23),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Experience a sanctuary for the mind.\n'
                            'We deliver high-integrity journalism,\n'
                            'meticulously curated to filter out the\n'
                            'static and illuminate what truly\n'
                            'matters.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.75,
                              color: Color(0xFF1D4ED8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const Homepage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B49C8),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Get Started',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 18),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Center(
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF1B49C8),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              child: const Text('Sign in to your account'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _CornerAlignment { topLeft, bottomRight }

class _CornerMark extends StatelessWidget {
  final _CornerAlignment alignment;

  const _CornerMark({required this.alignment});

  @override
  Widget build(BuildContext context) {
    const cornerColor = Color(0xFF2AC5D5);

    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(
        painter: _CornerPainter(alignment: alignment, color: cornerColor),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final _CornerAlignment alignment;
  final Color color;

  const _CornerPainter({required this.alignment, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final path = Path();
    if (alignment == _CornerAlignment.topLeft) {
      path
        ..moveTo(size.width, 0)
        ..lineTo(0, 0)
        ..lineTo(0, size.height);
    } else {
      path
        ..moveTo(0, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) {
    return oldDelegate.alignment != alignment || oldDelegate.color != color;
  }
}
