import 'package:flutter_tts/flutter_tts.dart';

typedef AiModeErrorCallback = void Function(dynamic message);
typedef AiModeProgressCallback =
    void Function(int startOffset, int endOffset, String word);

Future<void> initAiModeTts({
  required FlutterTts tts,
  required void Function() onStart,
  required void Function() onComplete,
  required AiModeErrorCallback onError,
  AiModeProgressCallback? onProgress,
}) async {
  await tts.setLanguage('en-US');
  await tts.setSpeechRate(0.45);
  await tts.setVolume(1.0);
  await tts.setPitch(1.0);

  tts.setStartHandler(onStart);
  tts.setCompletionHandler(onComplete);
  tts.setErrorHandler(onError);
  if (onProgress != null) {
    tts.setProgressHandler((_, startOffset, endOffset, word) {
      onProgress(startOffset, endOffset, word);
    });
  }
}

Future<void> aiMode({
  required FlutterTts tts,
  required bool isReading,
  required void Function(bool) setReading,
  required void Function(bool) setSpeaking,
  required void Function(bool) setLoading,
  required String title,
  required String description,
  String? content,
  String? preparedText,
}) async {
  if (isReading) {
    try {
      await tts.stop();
    } finally {
      setReading(false);
      setSpeaking(false);
      setLoading(false);
    }
    return;
  }

  setLoading(true);
  try {
    final textToSpeak =
        preparedText ??
        buildAiModeSpeechText(
          title: title,
          description: description,
          content: content,
        );

    if (textToSpeak.trim().isEmpty) {
      setReading(false);
      setSpeaking(false);
      setLoading(false);
      return;
    }

    // Ensure a previous utterance is fully stopped before starting new speech.
    await tts.stop();
    setReading(true);
    await tts.speak(textToSpeak);
    setLoading(false);
  } catch (_) {
    setReading(false);
    setSpeaking(false);
    setLoading(false);
    rethrow;
  }
}

String buildAiModeSpeechText({
  required String title,
  required String description,
  String? content,
}) {
  String normalizeForTts(String input) {
    var value = input;
    value = value.replaceAll(RegExp(r'https?://\S+'), '');
    value = value.replaceAll(RegExp(r'www\.\S+'), '');
    value = value.replaceAll(RegExp(r'<[^>]*>'), ' ');
    value = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    return value;
  }

  final buffer = StringBuffer();
  final cleanTitle = normalizeForTts(title);
  final cleanDescription = normalizeForTts(description);
  final cleanContent = normalizeForTts(
    (content ?? '').replaceAll(RegExp(r'\[\+\d+ chars\]'), ''),
  );

  if (cleanTitle.isNotEmpty) {
    buffer.write(cleanTitle);
    buffer.write('. ');
  }

  if (cleanDescription.isNotEmpty) {
    buffer.write(cleanDescription);
    buffer.write('. ');
  }

  if (cleanContent.isNotEmpty) {
    buffer.write(cleanContent);
  }

  final fullText = buffer.toString().trim();
  const maxChars = 3500;
  if (fullText.length <= maxChars) {
    return fullText;
  }

  return '${fullText.substring(0, maxChars)}...';
}
