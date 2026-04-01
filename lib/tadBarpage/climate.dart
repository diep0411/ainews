import 'package:flutter/material.dart';

class ClimatePage extends StatefulWidget {
  const ClimatePage({super.key});

  @override
  State<ClimatePage> createState() => _ClimatePageState();
}

class _ClimatePageState extends State<ClimatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Climate content đúng'),
      ),
    );
  }
}