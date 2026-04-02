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
            if (isFollowing) {
              // Show unfollow confirmation dialog
              final confirm = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Unfollow $title?',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'You will no longer see articles from $title in your feed.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                'Unfollow',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFFF5F5F5),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );

              if (confirm == true) {
                final prefs = await SharedPreferences.getInstance();

                setState(() {
                  followMap[title] = false;
                });

                final followedKeys = followMap.entries
                    .where((e) => e.value)
                    .map((e) => e.key)
                    .toList();

                await prefs.setStringList('follow_keys', followedKeys);
              }
            } else {
              // Directly follow without confirmation
              final prefs = await SharedPreferences.getInstance();

              setState(() {
                followMap[title] = true;
              });

              final followedKeys = followMap.entries
                  .where((e) => e.value)
                  .map((e) => e.key)
                  .toList();

              await prefs.setStringList('follow_keys', followedKeys);
            }
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
