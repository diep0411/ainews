import 'package:ai_new/component/article_image.dart';
import 'package:ai_new/component/newslate.dart';
import 'package:ai_new/content.dart/ai_mode_feed_page.dart';
import 'package:ai_new/models/news_model.dart';
import 'package:ai_new/services/ai_mode_service.dart';
import 'package:ai_new/services/font_service.dart';
import 'package:ai_new/services/histories_service.dart';
import 'package:ai_new/services/report_service.dart';
import 'package:ai_new/services/save_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailPage extends StatefulWidget {
  final String? imageUrl;
  final String? sourceName;
  final String? articleUrl;
  final String time;
  final String title;
  final String description;
  final String? content;
  final List<NewsModel>? relatedArticles;
  final bool autoPlayTtsOnOpen;

  const ArticleDetailPage({
    super.key,
    required this.imageUrl,
    required this.sourceName,
    this.articleUrl,
    required this.time,
    required this.title,
    required this.description,
    this.content,
    this.relatedArticles,
    this.autoPlayTtsOnOpen = false,
  });

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  late bool _isSaved;
  bool _isReading = false;
  bool _isSpeaking = false;
  bool _ttsLoading = false;
  int _speechStart = 0;
  int _speechEnd = 0;
  int _lastProgressMs = 0;
  ArticleFontLevel _fontLevel = ArticleFontLevel.medium;
  late String _displayTitle;
  late String _displayDescription;
  String? _displayContent;
  final FlutterTts _tts = FlutterTts();
  bool _didAutoPlayTts = false;

  double get _articleFontSize => FontService.bodyFontSize(_fontLevel);

  double get _titleFontSize => FontService.titleFontSize(_fontLevel);

  double get _metaFontSize => FontService.metaFontSize(_fontLevel);

  NewsModel get _currentArticle => NewsModel(
    title: _displayTitle,
    description: _displayDescription,
    content: _displayContent,
    imageUrl: widget.imageUrl,
    sourceName: widget.sourceName,
    publishedAt: null,
    articleUrl: widget.articleUrl,
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
    HistoryService.addHistory(_currentArticle);

    if (widget.autoPlayTtsOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTtsOnOpen();
      });
    }
  }

  Future<void> _startTtsOnOpen() async {
    if (!mounted || _didAutoPlayTts) return;
    _didAutoPlayTts = true;

    try {
      await _initTts();
      if (!mounted || _isReading) return;
      await _toggleTts();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to auto-start voice reading.')),
      );
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
          // Ignore stale completion callbacks that may arrive before speech starts.
          if (!_isReading) return;
          if (!_isSpeaking && _speechEnd == 0) return;
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

        final now = DateTime.now().millisecondsSinceEpoch;
        final shouldUpdate =
            (now - _lastProgressMs) >= 70 || endOffset >= _speechEnd;
        if (!shouldUpdate) return;

        setState(() {
          _lastProgressMs = now;
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

    if (!_isReading && speechText.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No readable content found for AI mode.')),
      );
      return;
    }

    if (!_isReading) {
      setState(() {
        _speechStart = 0;
        _speechEnd = 0;
        _lastProgressMs = 0;
      });
    }

    try {
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
              _lastProgressMs = 0;
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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isReading = false;
        _isSpeaking = false;
        _ttsLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'AI mode is temporarily unavailable. Please try again.',
          ),
        ),
      );
    }
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
                backgroundColor: const Color(0xFFFFEB3B),
                color: Colors.black,
                fontWeight: FontWeight.w700,
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
        'No detailed content. Please open the original article to read more.';
    final contentText = _cleanContent;

    if (contentText.isEmpty) {
      return Text(
        fallback,
        style: TextStyle(
          fontSize: _articleFontSize,
          height: 1.6,
          color: Colors.black54,
        ),
      );
    }
    return _buildHighlightedSection(
      text: contentText,
      sectionStartOffset: _contentStartOffset,
      style: TextStyle(
        fontSize: _articleFontSize,
        height: 1.6,
        color: Colors.black54,
      ),
    );
  }

  @override
  void dispose() {
    _isReading = false;
    _isSpeaking = false;
    _ttsLoading = false;
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
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreOptionsDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHighlightedSection(
              text: _displayTitle,
              sectionStartOffset: 0,
              style: TextStyle(
                fontSize: _titleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.sourceName ?? 'Unknown source'} • ${widget.time}',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: _metaFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: _confirmOpenAiMode,
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('AI Mode'),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
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
                _iconfunc(
                  const Icon(Icons.share),
                  'SHARE',
                  onTap: _shareArticle,
                ),
                _iconfunc(
                  const Icon(Icons.open_in_new),
                  '     VIEW \n ORIGINAL',
                  onTap: _openOriginalArticle,
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
              ),
            ),
            _buildHighlightedSection(
              text: _cleanDescription,
              sectionStartOffset: _descriptionStartOffset,
              style: TextStyle(
                fontSize: _articleFontSize,
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
                'Related Articles',
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

  Future<void> _confirmOpenAiMode() async {
    final shouldOpen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          child: Container(
            width: 340,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE3E6EF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 24,
                    color: Color(0xFF2A2E93),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'AI Summary Mode',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2433),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'You are now viewing an AI-generated\n'
                  'summary of this article. You can\n'
                  'switch back to the full text at any\n'
                  'time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.45,
                    color: Color(0xFF5E6476),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF2A2E93),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text(
                      'Got it',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
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

    if (shouldOpen == true) {
      _openAiModeFeed();
    }
  }

  Future<void> _saveArticle(BuildContext context) async {
    final article = _currentArticle;

    final saved = await SaveService.saveArticle(article);
    if (!mounted) return;
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

  void _openAiModeFeed() {
    final currentForFeed = NewsModel(
      title: _displayTitle,
      description: _displayDescription,
      content: _displayContent,
      imageUrl: widget.imageUrl,
      sourceName: widget.sourceName,
      publishedAt: null,
      articleUrl: widget.articleUrl,
    );

    final pool = [
      currentForFeed,
      ...(widget.relatedArticles ?? const <NewsModel>[]),
    ];

    final deduped = <String, NewsModel>{};
    for (final article in pool) {
      final key =
          '${article.title.trim().toLowerCase()}::${(article.sourceName ?? '').trim().toLowerCase()}';
      if (key == '::') continue;
      deduped[key] = article;
    }

    final feedArticles = deduped.values.toList();
    if (feedArticles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No articles available for AI mode.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AiModeFeedPage(
          articles: feedArticles,
          initialIndex: 0,
          autoPlayOnOpen: true,
        ),
      ),
    );
  }

  Future<void> _shareArticle() async {
    if (!mounted) return;

    final articleUrl = (widget.articleUrl ?? '').trim();
    if (articleUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This article does not have a shareable link.'),
        ),
      );
      return;
    }

    final shareText = '${widget.title}\n$articleUrl';
    await SharePlus.instance.share(ShareParams(text: shareText));
  }

  Future<void> _openOriginalArticle() async {
    if (!mounted) return;

    final articleUrl = (widget.articleUrl ?? '').trim();
    if (articleUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This article does not have an original link.'),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(articleUrl);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The article link is invalid.')),
      );
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open the article in browser.')),
      );
    }
  }

  Future<void> _showMoreOptionsDialog() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          alignment: Alignment.topRight,
          insetPadding: const EdgeInsets.fromLTRB(72, 12, 12, 0),
          title: const Text('Options'),
          contentPadding: const EdgeInsets.only(top: 8, bottom: 8),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.format_size),
                title: const Text('Font'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _handleFontSelection();
                },
              ),
              ListTile(
                leading: const Icon(Icons.report_gmailerrorred),
                title: const Text('Report'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _handleReportSelection();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleFontSelection() async {
    if (!mounted) return;

    final selected = await FontService.showFontDialog(
      context,
      currentLevel: _fontLevel,
    );

    if (!mounted || selected == null) return;

    setState(() {
      _fontLevel = selected;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Font updated: ${FontService.levelLabel(selected)}'),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  Future<void> _handleReportSelection() async {
    if (!mounted) return;

    final selectedReason = await ReportService.showReportDialog(
      context,
      title: _displayTitle,
      description: _displayDescription,
      imageUrl: widget.imageUrl,
    );

    if (!mounted || selectedReason == null) return;

    ReportService.markReportedByData(
      title: widget.title,
      sourceName: widget.sourceName,
      articleUrl: widget.articleUrl,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reported: $selectedReason'),
        duration: const Duration(milliseconds: 1200),
      ),
    );

    Navigator.pop(context);
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
