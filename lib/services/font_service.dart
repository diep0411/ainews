import 'package:flutter/material.dart';

enum ArticleFontLevel { small, medium, large }

class FontService {
  static double bodyFontSize(ArticleFontLevel level) {
    switch (level) {
      case ArticleFontLevel.small:
        return 14;
      case ArticleFontLevel.large:
        return 20;
      case ArticleFontLevel.medium:
        return 16;
    }
  }

  static double titleFontSize(ArticleFontLevel level) {
    switch (level) {
      case ArticleFontLevel.small:
        return 24;
      case ArticleFontLevel.large:
        return 32;
      case ArticleFontLevel.medium:
        return 28;
    }
  }

  static double metaFontSize(ArticleFontLevel level) {
    switch (level) {
      case ArticleFontLevel.small:
        return 12;
      case ArticleFontLevel.large:
        return 16;
      case ArticleFontLevel.medium:
        return 14;
    }
  }

  static String levelLabel(ArticleFontLevel level) {
    switch (level) {
      case ArticleFontLevel.small:
        return 'Small';
      case ArticleFontLevel.large:
        return 'Large';
      case ArticleFontLevel.medium:
        return 'Medium';
    }
  }

  static Future<ArticleFontLevel?> showFontDialog(
    BuildContext context, {
    required ArticleFontLevel currentLevel,
  }) async {
    var selected = currentLevel;

    Widget sizeOption({
      required String label,
      required bool isSelected,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF1544C6)
                  : const Color(0xFFE7EBF3),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF1544C6),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    final result = await showDialog<ArticleFontLevel>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF4F6FA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              title: const Text(
                'Update font size',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C2333),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'The font is updated only for the current\n'
                    'article page to improve your news-reading\n'
                    'experience.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.45,
                      color: Color(0xFF657086),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      sizeOption(
                        label: 'Small',
                        isSelected: selected == ArticleFontLevel.small,
                        onTap: () {
                          setLocalState(() {
                            selected = ArticleFontLevel.small;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      sizeOption(
                        label: 'Medium',
                        isSelected: selected == ArticleFontLevel.medium,
                        onTap: () {
                          setLocalState(() {
                            selected = ArticleFontLevel.medium;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      sizeOption(
                        label: 'Large',
                        isSelected: selected == ArticleFontLevel.large,
                        onTap: () {
                          setLocalState(() {
                            selected = ArticleFontLevel.large;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFE4E7EC),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xFF1F2937),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1544C6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(dialogContext, selected);
                            },
                            child: const Text(
                              'Update',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    return result;
  }
}
