import 'package:ai_new/component/article_image.dart';
import 'package:ai_new/component/newslate.dart';
import 'package:ai_new/models/news_model.dart';
import 'package:ai_new/services/ai_mode_service.dart';
import 'package:ai_new/services/histories_service.dart';
import 'package:ai_new/services/save_service.dart';
import 'package:ai_new/services/translation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ArticleDetailPage extends StatefulWidget {
  final String? imageUrl;
  final String? sourceName;
  final String time;
  final String title;
  final String description;
  final String? content;
  final List<NewsModel>? relatedArticles;

  const ArticleDetailPage({
    super.key,
    required this.imageUrl,
    required this.sourceName,
    required this.time,
    required this.title,
    required this.description,
    this.content,
    this.relatedArticles,
  });

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  late bool _isSaved;
  bool _isTranslating = false;
  bool _isReading = false;
  bool _isSpeaking = false;
  bool _ttsLoading = false;
  int _speechStart = 0;
  int _speechEnd = 0;
  late String _displayTitle;
  late String _displayDescription;
  String? _displayContent;
  final FlutterTts _tts = FlutterTts();

  NewsModel get _currentArticle => NewsModel(
    title: _displayTitle,
    description: _displayDescription,
    content: _displayContent,
    imageUrl: widget.imageUrl,
    sourceName: widget.sourceName,
    publishedAt: null,
    articleUrl: null,
  );

  List<NewsModel> get _relatedArticles {
    final pool = widget.relatedArticles ?? const <NewsModel>[];

    final filtered = pool.where((article) {
      final sameTitle =
          article.title.trim().toLowerCase() ==
          widget.title.trim().toLowerCase();
      final sameSource =
          (article.sourceName ?? '').trim().toLowerCase() ==
          (widget.sourceName ?? '').trim().toLowerCase();

      if (sameTitle && sameSource) {
        return false;
      }

      return article.title.trim().isNotEmpty;
    }).toList();

    filtered.sort((a, b) {
      final aSameSource =
          (a.sourceName ?? '').trim().toLowerCase() ==
          (widget.sourceName ?? '').trim().toLowerCase();
      final bSameSource =
          (b.sourceName ?? '').trim().toLowerCase() ==
          (widget.sourceName ?? '').trim().toLowerCase();

      if (aSameSource == bSameSource) {
        return 0;
      }
      return aSameSource ? -1 : 1;
    });

    return filtered.take(3).toList();
  }

  @override
  void initState() {
    super.initState();
    _displayTitle = widget.title;
    _displayDescription = widget.description;
    _displayContent = widget.content;
    _isSaved = SaveService.savedArticles.any(
      (item) =>
          item.title == widget.title && item.sourceName == widget.sourceName,
    );
    _translateArticle();
    HistoryService.addHistory(_currentArticle);
    _initTts();
  }

  Future<void> _translateArticle() async {
    setState(() {
      _isTranslating = true;
    });

    try {
      final translated = await TranslationService.translateArticleToEnglish(
        title: widget.title,
        description: widget.description,
        content: widget.content,
      );

      if (!mounted) return;
      setState(() {
        _displayTitle = translated.title;
        _displayDescription = translated.description;
        _displayContent = translated.content;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _displayTitle = widget.title;
        _displayDescription = widget.description;
        _displayContent = widget.content;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isTranslating = false;
      });
    }
  }

  Future<void> _initTts() async {
    await initAiModeTts(
      tts: _tts,
      onStart: () {
        if (mounted) {
          setState(() => _isSpeaking = true);
        }
      },
      onComplete: () {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _isReading = false;
            _speechStart = 0;
            _speechEnd = 0;
          });
        }
      },
      onError: (_) {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _isReading = false;
            _speechStart = 0;
            _speechEnd = 0;
          });
        }
      },
      onProgress: (startOffset, endOffset, _) {
        if (!mounted) return;
        setState(() {
          _speechStart = startOffset;
          _speechEnd = endOffset;
        });
      },
    );
  }

  Future<void> _toggleTts() async {
    final speechText = buildAiModeSpeechText(
      title: _displayTitle,
      description: _displayDescription,
      content: _displayContent,
    );

    await aiMode(
      tts: _tts,
      isReading: _isReading,
      setReading: (value) {
        if (!mounted) return;
        setState(() {
          _isReading = value;
          if (!value) {
            _speechStart = 0;
            _speechEnd = 0;
          }
        });
      },
      setSpeaking: (value) {
        if (!mounted) return;
        setState(() => _isSpeaking = value);
      },
      setLoading: (value) {
        if (!mounted) return;
        setState(() => _ttsLoading = value);
      },
      title: widget.title,
      description: _displayDescription,
      content: _displayContent,
      preparedText: speechText,
    );
  }

  String get _cleanDescription => _displayDescription.trim();

  String get _cleanContent =>
      (_displayContent ?? '').replaceAll(RegExp(r'\[\+\d+ chars\]'), '').trim();

  int get _descriptionStartOffset => _displayTitle.length + 2;

  int get _descriptionEndOffset =>
      _descriptionStartOffset + _cleanDescription.length;

  int get _contentStartOffset {
    var offset = _descriptionStartOffset;
    if (_cleanDescription.isNotEmpty) {
      offset += _cleanDescription.length + 2;
    }
    return offset;
  }

  Widget _buildHighlightedSection({
    required String text,
    required int sectionStartOffset,
    required TextStyle style,
  }) {
    final baseStyle = style.copyWith(color: style.color ?? Colors.black87);

    if (text.isEmpty) {
      return SizedBox(
        width: double.infinity,
        child: Text(text, style: baseStyle),
      );
    }

    final shouldHighlight = _isReading && _isSpeaking;
    if (!shouldHighlight) {
      return SizedBox(
        width: double.infinity,
        child: Text(text, style: baseStyle),
      );
    }

    final localStart = (_speechStart - sectionStartOffset).clamp(
      0,
      text.length,
    );
    final localEnd = (_speechEnd - sectionStartOffset).clamp(0, text.length);

    if (localEnd <= localStart) {
      return SizedBox(
        width: double.infinity,
        child: Text(text, style: baseStyle),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: RichText(
        text: TextSpan(
          style: baseStyle,
          children: [
            TextSpan(text: text.substring(0, localStart)),
            TextSpan(
              text: text.substring(localStart, localEnd),
              style: baseStyle.copyWith(
                backgroundColor: const Color(0xFFB39DDB),
                color: Colors.black,
              ),
            ),
            TextSpan(text: text.substring(localEnd)),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusedContent() {
    final fallback =
        'Không có nội dung chi tiết. Vui lòng mở bài gốc để đọc thêm.';
    final contentText = _cleanContent;

    if (contentText.isEmpty) {
      return Text(
        fallback,
        style: const TextStyle(
          fontSize: 16,
          height: 1.6,
          color: Colors.black54,
        ),
      );
    }
    return _buildHighlightedSection(
      text: contentText,
      sectionStartOffset: _contentStartOffset,
      style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black54),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ARCHITECT',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHighlightedSection(
              text: _displayTitle,
              sectionStartOffset: 0,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            if (_isTranslating)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Translating content to English...',
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.sourceName ?? 'Unknown source'} • ${widget.time}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                InkWell(
                  onTap: _ttsLoading ? null : _toggleTts,
                  child: Container(
                    height: 40,
                    width: 122,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: _isReading ? Colors.red : Colors.blueAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: _ttsLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isReading
                                      ? Icons.stop_rounded
                                      : Icons.record_voice_over_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isReading ? 'STOP' : 'AI MODE',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.grey.shade300,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _iconfunc(
                  Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border),
                  'SAVE',
                  onTap: () => _saveArticle(context),
                ),
                _iconfunc(const Icon(Icons.share), 'SHARE'),
                _iconfunc(
                  const Icon(Icons.open_in_new),
                  '     VIEW \n ORIGINAL',
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.grey.shade300,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ArticleImage(
                imageUrl: widget.imageUrl,
                width: double.infinity,
                height: 240,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
            ),
            _buildHighlightedSection(
              text: _cleanDescription,
              sectionStartOffset: _descriptionStartOffset,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isSpeaking
                    ? const Color(0xFFF3E5F5)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildFocusedContent(),
            ),
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 16),
            if (_relatedArticles.isNotEmpty) ...[
              const Text(
                'Bài viết liên quan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ..._relatedArticles.map(
                (article) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NewsLateCard(
                    article: article,
                    articlePool: widget.relatedArticles,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  void _saveArticle(BuildContext context) {
    final article = _currentArticle;

    final saved = SaveService.saveArticle(article);
    if (saved) {
      setState(() {
        _isSaved = true;
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Đã lưu bài viết thành công'
              : 'Bài viết này đã được lưu trước đó',
        ),
      ),
    );
  }

  Widget _iconfunc(Icon icon, String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        margin: const EdgeInsets.only(top: 16, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 4),
            Text(
              text,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
