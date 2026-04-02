import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ai_new/models/news_model.dart';
import 'package:http/http.dart' as http;

class ReportService {
  static final Set<String> _reportedKeys = <String>{};
  static final ValueNotifier<int> reportsVersion = ValueNotifier<int>(0);
  static final Uri _reportEndpoint = Uri.parse('https://httpbin.org/post');

  static const List<String> _reasons = [
    'Nội dung không phù hợp',
    'Nội dung giả fake lừa đảo',
    'Nội dung nhạy cảm',
    'Nội dung spam / other',
  ];

  static String _articleKey(NewsModel article) {
    return _articleKeyFromFields(
      title: article.title,
      sourceName: article.sourceName,
      articleUrl: article.articleUrl,
    );
  }

  static String _articleKeyFromFields({
    required String title,
    String? sourceName,
    String? articleUrl,
  }) {
    final urlKey = (articleUrl ?? '').trim();
    if (urlKey.isNotEmpty) {
      return 'url::$urlKey';
    }

    final normalizedTitle = title.trim().toLowerCase();
    final source = (sourceName ?? '').trim().toLowerCase();
    return 'meta::$normalizedTitle|$source';
  }

  static void markReported(NewsModel article) {
    _reportedKeys.add(_articleKey(article));
    reportsVersion.value++;
  }

  static void markReportedByData({
    required String title,
    String? sourceName,
    String? articleUrl,
  }) {
    _reportedKeys.add(
      _articleKeyFromFields(
        title: title,
        sourceName: sourceName,
        articleUrl: articleUrl,
      ),
    );
    reportsVersion.value++;
  }

  static bool isReported(NewsModel article) {
    return _reportedKeys.contains(_articleKey(article));
  }

  static List<NewsModel> filterUnreported(List<NewsModel> articles) {
    return articles.where((article) => !isReported(article)).toList();
  }

  static Future<String?> showReportDialog(
    BuildContext context, {
    required String title,
    required String description,
    String? imageUrl,
  }) async {
    var selectedReason = _reasons.first;

    Widget reasonTile({
      required String reason,
      required bool isSelected,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 22,
                color: isSelected
                    ? const Color(0xFF1544C6)
                    : const Color(0xFFB9C7E8),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  reason,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF4C5B73),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final result = await showDialog<String>(
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
                'Report article',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C2333),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '$title\n$description',
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.35,
                            color: Color(0xFF4C5B73),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: imageUrl == null || imageUrl.trim().isEmpty
                              ? Container(
                                  color: const Color(0xFFE1E6EF),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Color(0xFF8E9BB5),
                                  ),
                                )
                              : Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: const Color(0xFFE1E6EF),
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.broken_image_outlined,
                                        color: Color(0xFF8E9BB5),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ..._reasons.map(
                    (reason) => reasonTile(
                      reason: reason,
                      isSelected: selectedReason == reason,
                      onTap: () {
                        setLocalState(() {
                          selectedReason = reason;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 46,
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
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1544C6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(dialogContext, selectedReason);
                            },
                            child: const Text(
                              'Report',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
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

  static Future<bool> uploadReport({
    required NewsModel article,
    required String reason,
  }) async {
    final payload = <String, dynamic>{
      'reason': reason,
      'title': article.title,
      'description': article.description,
      'content': article.content,
      'sourceName': article.sourceName,
      'articleUrl': article.articleUrl,
      'imageUrl': article.imageUrl,
      'reportedAt': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      final response = await http
          .post(
            _reportEndpoint,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 8));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}
