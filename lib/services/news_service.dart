import 'dart:convert';

import 'package:ai_new/models/news_model.dart';
import 'package:flutter/services.dart' show rootBundle;

class NewsService {
  static const String _contentPath1 = 'assets/js/content-0-page-1.json';
  static const String _contentPath2 = 'assets/js/domain-1949198388-page-1.json';
  static const String _preConfigPath = 'assets/js/pre_france.txt.json';

  static Future<List<NewsModel>> fetchTopHeadlines() async {
    final preConfigRaw = await rootBundle.loadString(_preConfigPath);
    final preConfig = jsonDecode(preConfigRaw) as Map<String, dynamic>;
    final allowedSources = _parseAllowedSources(preConfig);

    final raw1 = await rootBundle.loadString(_contentPath1);
    final raw2 = await rootBundle.loadString(_contentPath2);
    final data1 = jsonDecode(raw1) as Map<String, dynamic>;
    final data2 = jsonDecode(raw2) as Map<String, dynamic>;

    final news1 = data1['news'] as List<dynamic>? ?? const [];
    final news2 = data2['news'] as List<dynamic>? ?? const [];
    final merged = <Map<String, dynamic>>[
      ...news1.whereType<Map<String, dynamic>>(),
      ...news2.whereType<Map<String, dynamic>>(),
    ];

    final deduped = <String, Map<String, dynamic>>{};
    for (final item in merged) {
      final key = _buildArticleKey(item);
      if (key.isEmpty || deduped.containsKey(key)) {
        continue;
      }
      deduped[key] = item;
    }

    final parsedCandidates = await Future.wait(
      deduped.values.map(_toNewsModel),
    );

    final parsed = parsedCandidates
        .where((item) => item.title.trim().isNotEmpty)
        .where((item) {
          if (allowedSources.isEmpty) {
            return true;
          }
          final source = (item.sourceName ?? '').trim().toLowerCase();
          return source.isNotEmpty && allowedSources.contains(source);
        })
        .toList();

    parsed.sort((a, b) {
      final aTime = DateTime.tryParse(a.publishedAt ?? '');
      final bTime = DateTime.tryParse(b.publishedAt ?? '');
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

    return parsed;
  }

  static Set<String> _parseAllowedSources(Map<String, dynamic> config) {
    final rawSources = (config['sources'] as String? ?? '').trim();
    if (rawSources.isEmpty) {
      return const <String>{};
    }

    return rawSources
        .split(',')
        .map((item) => item.trim().toLowerCase())
        .where((item) => item.isNotEmpty)
        .toSet();
  }

  static String _buildArticleKey(Map<String, dynamic> item) {
    final id = item['id']?.toString().trim() ?? '';
    if (id.isNotEmpty) {
      return 'id:$id';
    }
    final url = item['url']?.toString().trim() ?? '';
    if (url.isNotEmpty) {
      return 'url:$url';
    }
    final title = item['tte']?.toString().trim() ?? '';
    return title.isEmpty ? '' : 'title:$title';
  }

  static Future<NewsModel> _toNewsModel(Map<String, dynamic> item) async {
    final title = (item['tte'] as String? ?? '').trim();
    final description = (item['dst'] as String? ?? '').trim();
    final source = (item['src'] as String?)?.trim();
    final url = (item['url'] as String?)?.trim();
    final timestamp = item['tmU'];

    final ctn = item['ctn'] as List<dynamic>? ?? const [];
    final textBlocks = ctn
        .whereType<Map<String, dynamic>>()
        .where((entry) => (entry['type'] as String?) == 'CONTENT')
        .map((entry) => (entry['content'] as String? ?? '').trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final detailContent = textBlocks.join('\n\n').trim();
    final fallbackDescription = textBlocks.isNotEmpty ? textBlocks.first : null;
    final imageUrl = _extractImageUrl(item, ctn);
    final resolvedDescription = description.isNotEmpty
        ? description
        : fallbackDescription;

    final publishedAt = switch (timestamp) {
      int value => DateTime.fromMillisecondsSinceEpoch(value).toIso8601String(),
      String value =>
        int.tryParse(value) != null
            ? DateTime.fromMillisecondsSinceEpoch(
                int.parse(value),
              ).toIso8601String()
            : null,
      _ => null,
    };

    return NewsModel(
      title: title.isEmpty ? 'Untitled article' : title,
      description: resolvedDescription,
      content: detailContent.isNotEmpty ? detailContent : null,
      imageUrl: imageUrl,
      sourceName: source,
      publishedAt: publishedAt,
      articleUrl: (url != null && url.isNotEmpty) ? url : null,
    );
  }

  static String? _extractImageUrl(
    Map<String, dynamic> item,
    List<dynamic> ctn,
  ) {
    final candidates = <String?>[
      item['img'] as String?,
      item['bimg'] as String?,
    ];

    for (final entry in ctn.whereType<Map<String, dynamic>>()) {
      if ((entry['type'] as String?) == 'IMG') {
        candidates.add(entry['content'] as String?);
      }
    }

    for (final raw in candidates) {
      final normalized = _normalizeRemoteUrl(raw);
      if (normalized == null) {
        continue;
      }
      return normalized;
    }

    return null;
  }

  static String? _normalizeRemoteUrl(String? rawUrl) {
    final value = rawUrl?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.startsWith('//')) {
      return Uri.encodeFull('https:$value');
    }

    if (value.startsWith('www.')) {
      return Uri.encodeFull('https://$value');
    }

    final uri = Uri.tryParse(value);
    if (uri == null) {
      return null;
    }

    final scheme = uri.scheme.toLowerCase();
    if (scheme == 'http' || scheme == 'https') {
      return Uri.encodeFull(uri.toString());
    }

    return null;
  }
}
