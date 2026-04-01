import 'package:translator/translator.dart';

class TranslationResult {
  final String title;
  final String description;
  final String? content;

  const TranslationResult({
    required this.title,
    required this.description,
    required this.content,
  });
}

class TranslationService {
  static final GoogleTranslator _translator = GoogleTranslator();
  static final Map<String, String> _cache = <String, String>{};

  static Future<TranslationResult> translateArticleToEnglish({
    required String title,
    required String description,
    required String? content,
  }) async {
    final translatedTitle = await _translateText(title);
    final translatedDescription = await _translateText(description);
    final translatedContent = await _translateLongText(content);

    return TranslationResult(
      title: translatedTitle,
      description: translatedDescription,
      content: translatedContent,
    );
  }

  static Future<String> _translateText(String rawText) async {
    final value = rawText.trim();
    if (value.isEmpty) {
      return rawText;
    }

    final cached = _cache[value];
    if (cached != null) {
      return cached;
    }

    try {
      final translated = await _translator
          .translate(value, from: 'fr', to: 'en')
          .timeout(const Duration(seconds: 4));
      final resolved = translated.text.trim().isEmpty
          ? value
          : translated.text.trim();
      _cache[value] = resolved;
      return resolved;
    } catch (_) {
      try {
        final translated = await _translator
            .translate(value, to: 'en')
            .timeout(const Duration(seconds: 4));
        final resolved = translated.text.trim().isEmpty
            ? value
            : translated.text.trim();
        _cache[value] = resolved;
        return resolved;
      } catch (_) {
        _cache[value] = value;
        return value;
      }
    }
  }

  static Future<String?> _translateLongText(String? rawText) async {
    final value = rawText?.trim();
    if (value == null || value.isEmpty) {
      return rawText;
    }

    const chunkSize = 2200;
    if (value.length <= chunkSize) {
      return _translateText(value);
    }

    final chunks = <String>[];
    var cursor = 0;
    while (cursor < value.length) {
      final end = (cursor + chunkSize < value.length)
          ? cursor + chunkSize
          : value.length;
      chunks.add(value.substring(cursor, end));
      cursor = end;
    }

    final translatedChunks = <String>[];
    for (final chunk in chunks) {
      translatedChunks.add(await _translateText(chunk));
    }

    return translatedChunks.join(' ');
  }
}
