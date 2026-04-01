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
    await tts.stop();
    setReading(false);
    setSpeaking(false);
    return;
  }

  setLoading(true);

  final textToSpeak =
      preparedText ??
      buildAiModeSpeechText(
        title: title,
        description: description,
        content: content,
      );

  setReading(true);
  setLoading(false);
  await tts.speak(textToSpeak);
}

String buildAiModeSpeechText({
  required String title,
  required String description,
  String? content,
}) {
  final buffer = StringBuffer();
  buffer.write(title);
  buffer.write('. ');

  if (description.trim().isNotEmpty) {
    buffer.write(description.trim());
    buffer.write('. ');
  }

  if ((content ?? '').trim().isNotEmpty) {
    final clean = content!.replaceAll(RegExp(r'\[\+\d+ chars\]'), '').trim();
    buffer.write(clean);
  }

  return buffer.toString();
}
