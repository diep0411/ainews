import 'package:flutter/material.dart';
import 'package:ai_new/services/histories_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sourcespage extends StatefulWidget {
  const Sourcespage({super.key});

  @override
  State<Sourcespage> createState() => _SourcespageState();
}

class _SourcespageState extends State<Sourcespage> {
  Map<String, bool> followMap = {};
  List<String> getSources() {
    return HistoryService.histories
        .map((e) => e.sourceName ?? "Unknown")
        .toSet()
        .toList();
  }

  @override
  void initState() {
    super.initState();
    loadFollow();
  }

  void loadFollow() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      followMap = Map<String, bool>.from(
        (prefs.getStringList('follow_keys') ?? []).fold<Map<String, bool>>({}, (
          map,
          key,
        ) {
          map[key] = true;
          return map;
        }),
      );
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SOURCES',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: getSources().map((source) {
          return Padding(
            key: ValueKey(source),
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSources(source),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSources(String title) {
    bool isFollowing = followMap[title] ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        InkWell(
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();

            setState(() {
              final current = followMap[title] ?? false;
              followMap[title] = !current;
            });

            final followedKeys = followMap.entries
                .where((e) => e.value)
                .map((e) => e.key)
                .toList();

            await prefs.setStringList('follow_keys', followedKeys);
          },
          child: Container(
            height: 40,
            width: 100,
            decoration: BoxDecoration(
              color: isFollowing ? Colors.blue : Colors.white,
              border: Border.all(color: Colors.blue, width: 1.5),
            ),
            child: Center(
              child: Text(
                isFollowing ? "FOLLOWING" : "FOLLOW",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isFollowing ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
