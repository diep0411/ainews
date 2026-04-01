import 'package:ai_new/homePage.dart';
import 'package:flutter/material.dart';
import 'package:ai_new/resource/images.dart';

class Welcomepage extends StatelessWidget {
  const Welcomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          extendBodyBehindAppBar: true,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 300,
                child: Image.asset(WelcomeRes.welcome, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 1,
                ),
                child: Column(
                  children: [
                    // TITLE
                    const Text(
                      'Truth in the\nNoise.',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 16),
                    // DESCRIPTION
                    const Text(
                      'Experience a sanctuary for the mind.\n'
                      'We deliver high-integrity journalism,\n'
                      'meticulously curated to filter out the\n'
                      'static and illuminate what truly\n'
                      'matters.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blue,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => Homepage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1D4ED8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Get Started',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Sign in to your account',
                          style: TextStyle(fontSize: 13, color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
