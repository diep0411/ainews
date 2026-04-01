import 'package:flutter/material.dart';

class TechnologyPage extends StatefulWidget {
  const TechnologyPage({super.key});

  @override
  State<TechnologyPage> createState() => _TechnologyPageState();
}

class _TechnologyPageState extends State<TechnologyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('technology đúng'),
      ),
    );
  }
}