import 'package:ai_new/content.dart/all_content.dart';
import 'dart:async';
import 'package:ai_new/models/news_model.dart';
import 'package:ai_new/services/ai_mode_service.dart';
import 'package:ai_new/services/font_service.dart';
import 'package:ai_new/services/report_service.dart';
import 'package:ai_new/services/save_service.dart';
import 'package:ai_new/services/translation_service.dart';
import 'package:ai_new/utils/article_date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AiModeFeedPage extends StatefulWidget {
  final List<NewsModel> articles;
  final int initialIndex;
  final bool autoPlayOnOpen;

  const AiModeFeedPage({
    super.key,
    required this.articles,
    this.initialIndex = 0,
    this.autoPlayOnOpen = false,
  });

  @override
  State<AiModeFeedPage> createState() => _AiModeFeedPageState();
}

class _AiModeFeedPageState extends State<AiModeFeedPage> {
  late final PageController _pageController;
  late int _currentIndex;
  late List<NewsModel> _feedArticles;

  @override
  void initState() {
    super.initState();
    _feedArticles = List<NewsModel>.from(widget.articles);
    final maxIndex = _feedArticles.isEmpty ? 0 : _feedArticles.length - 1;
    _currentIndex = widget.initialIndex.clamp(0, maxIndex);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_feedArticles.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'No articles available for AI mode.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _feedArticles.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          final article = _feedArticles[index];
          return _AiModeCard(
            article: article,
            isActive: index == _currentIndex,
            autoStartTts: widget.autoPlayOnOpen,
            currentIndex: _currentIndex,
            totalCount: _feedArticles.length,
            onClose: () => Navigator.of(context).pop(),
            onReadFull: () => _openReadFull(article),
            onSave: () => _saveArticle(article),
            onShare: () => _shareArticle(article),
            onOpenOriginal: () => _openOriginal(article),
            onReport: (reason) => _reportAndAdvance(index, article, reason),
          );
        },
      ),
    );
  }

  Future<void> _reportAndAdvance(
    int index,
    NewsModel article,
    String reason,
  ) async {
    final uploaded = await ReportService.uploadReport(
      article: article,
      reason: reason,
    );

    if (!mounted) return;
    if (!uploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload report failed. Please try again.'),
        ),
      );
      return;
    }

    ReportService.markReported(article);

    if (index < 0 || index >= _feedArticles.length) return;
    final nextIndex =
        index >= _feedArticles.length - 1 && _feedArticles.length > 1
        ? _feedArticles.length - 2
        : index;

    setState(() {
      _feedArticles.removeAt(index);
      _currentIndex = _feedArticles.isEmpty
          ? 0
          : nextIndex.clamp(0, _feedArticles.length - 1);
    });

    if (_feedArticles.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Reported: $reason')));
      Navigator.of(context).pop();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      _pageController.jumpToPage(_currentIndex);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Reported: $reason')));
  }

  Future<void> _saveArticle(NewsModel article) async {
    final saved = await SaveService.saveArticle(article);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(saved ? 'Saved successfully.' : 'Article already saved.'),
      ),
    );
  }

  Future<void> _shareArticle(NewsModel article) async {
    final url = (article.articleUrl ?? '').trim();
    if (url.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This article does not have a share link.'),
        ),
      );
      return;
    }

    await SharePlus.instance.share(ShareParams(text: '${article.title}\n$url'));
  }

  Future<void> _openOriginal(NewsModel article) async {
    final url = (article.articleUrl ?? '').trim();
    if (url.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This article does not have an original link.'),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The article link is invalid.')),
      );
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open original article.')),
      );
    }
  }

  void _openReadFull(NewsModel article) {
    final published =
        ArticleDateUtils.formatPublishedDate(article.publishedAt) ??
        'Unknown time';

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => ArticleDetailPage(
          imageUrl: article.imageUrl,
          sourceName: article.sourceName,
          articleUrl: article.articleUrl,
          time: published,
          title: article.title,
          description: article.description ?? 'No description',
          content: article.content,
          contentItems: article.contentItems,
          relatedArticles: _feedArticles,
        ),
      ),
      (route) => route.isFirst,
    );
  }
}

class _AiModeCard extends StatefulWidget {
  final NewsModel article;
  final bool isActive;
  final bool autoStartTts;
  final int currentIndex;
  final int totalCount;
  final VoidCallback onClose;
  final VoidCallback onReadFull;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onOpenOriginal;
  final Future<void> Function(String reason) onReport;

  const _AiModeCard({
    required this.article,
    required this.isActive,
    required this.autoStartTts,
    required this.currentIndex,
    required this.totalCount,
    required this.onClose,
    required this.onReadFull,
    required this.onSave,
    required this.onShare,
    required this.onOpenOriginal,
    required this.onReport,
  });

  @override
  State<_AiModeCard> createState() => _AiModeCardState();
}

class _AiModeCardState extends State<_AiModeCard> {
  static const 
  int _collapsedDescriptionLines = 3;
  bool _isDescriptionExpanded = false;
  ArticleFontLevel _fontLevel = ArticleFontLevel.medium;
  bool _isTranslating = false;
  bool _isReporting = false;
  bool _isTranslated = false;
  bool _isReading = false;
  bool _isSpeaking = false;
  bool _ttsLoading = false;
  bool _ttsReady = false;
  bool _didAutoStart = false;
  bool _isPausedByTap = false;
  bool _showCenterPlaybackIcon = false;
  IconData _centerPlaybackIcon = Icons.play_arrow_rounded;
  Timer? _centerIconTimer;
  int _speechBaseOffset = 0;
  int _resumeOffset = 0;
  String _activeSpeechText = '';
  int _speechStart = 0;
  int _speechEnd = 0;
  int _lastProgressMs = 0;
  late String _displayTitle;
  late String _displayDescription;
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _displayTitle = widget.article.title;
    _displayDescription = _resolvedDescription(widget.article);
    _prepareTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoStartIfNeeded();
    });
  }

  @override
  void didUpdateWidget(covariant _AiModeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _autoStartIfNeeded();
    }
    if (oldWidget.isActive && !widget.isActive) {
      _stopReading();
    }
  }

  @override
  void dispose() {
    _centerIconTimer?.cancel();
    _tts.stop();
    super.dispose();
  }

  void _showPlaybackOverlayIcon(IconData icon) {
    _centerIconTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _centerPlaybackIcon = icon;
      _showCenterPlaybackIcon = true;
    });

    _centerIconTimer = Timer(const Duration(milliseconds: 480), () {
      if (!mounted) return;
      setState(() => _showCenterPlaybackIcon = false);
    });
  }

  Future<void> _prepareTts() async {
    try {
      await initAiModeTts(
        tts: _tts,
        onStart: () {
          if (!mounted) return;
          setState(() => _isSpeaking = true);
        },
        onComplete: () {
          if (!mounted) return;
          setState(() {
            _isSpeaking = false;
            _isReading = false;
            _isPausedByTap = false;
            _speechStart = 0;
            _speechEnd = 0;
            _speechBaseOffset = 0;
            _resumeOffset = 0;
          });
        },
        onError: (_) {
          if (!mounted) return;
          setState(() {
            _isSpeaking = false;
            _isReading = false;
            _isPausedByTap = false;
            _speechStart = 0;
            _speechEnd = 0;
            _speechBaseOffset = 0;
            _resumeOffset = 0;
          });
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
            _resumeOffset = (_speechBaseOffset + endOffset).clamp(
              0,
              _activeSpeechText.length,
            );
          });
        },
      );
      if (!mounted) return;
      setState(() => _ttsReady = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _ttsReady = false);
    }
  }

  Future<void> _autoStartIfNeeded() async {
    if (!widget.isActive || !widget.autoStartTts || _didAutoStart) return;
    _didAutoStart = true;
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted || !widget.isActive) return;
    await _toggleTts();
  }

  Future<void> _stopReading() async {
    if (!_isReading && !_isSpeaking) return;
    try {
      await _tts.stop();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _isReading = false;
      _isSpeaking = false;
      _ttsLoading = false;
      _isPausedByTap = false;
      _speechStart = 0;
      _speechEnd = 0;
      _speechBaseOffset = 0;
      _resumeOffset = 0;
      _lastProgressMs = 0;
    });
  }

  Future<void> _handleScreenTap() async {
    if (_ttsLoading) return;

    if (_isReading) {
      try {
        await _tts.stop();
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _isReading = false;
        _isSpeaking = false;
        _isPausedByTap = true;
        _ttsLoading = false;
      });
      _showPlaybackOverlayIcon(Icons.pause_rounded);
      return;
    }

    if (_isPausedByTap && _activeSpeechText.isNotEmpty) {
      final safeOffset = _resumeOffset.clamp(0, _activeSpeechText.length);
      final remaining = _activeSpeechText.substring(safeOffset);

      if (remaining.trim().isEmpty) {
        if (!mounted) return;
        setState(() {
          _isPausedByTap = false;
          _speechBaseOffset = 0;
          _resumeOffset = 0;
        });
        return;
      }

      try {
        if (!mounted) return;
        setState(() {
          _ttsLoading = true;
          _speechBaseOffset = safeOffset;
          _isPausedByTap = false;
        });
        await _tts.stop();
        if (!mounted) return;
        setState(() {
          _isReading = true;
          _ttsLoading = false;
        });
        _showPlaybackOverlayIcon(Icons.play_arrow_rounded);
        await _tts.speak(remaining);
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _isReading = false;
          _isSpeaking = false;
          _ttsLoading = false;
        });
      }
      return;
    }

    _showPlaybackOverlayIcon(Icons.play_arrow_rounded);
    await _toggleTts();
  }

  Future<void> _toggleTts() async {
    if (!_ttsReady) {
      await _prepareTts();
      if (!_ttsReady) return;
    }

    final speechText = buildAiModeSpeechText(
      title: _displayTitle,
      description: _displayDescription,
      content: null,
    );

    if (!_isReading && speechText.trim().isEmpty) return;

    if (!_isReading) {
      setState(() {
        _activeSpeechText = speechText;
        _speechBaseOffset = 0;
        _resumeOffset = 0;
        _isPausedByTap = false;
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
              _speechBaseOffset = 0;
              _resumeOffset = 0;
              _isPausedByTap = false;
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
        title: _displayTitle,
        description: _displayDescription,
        content: null,
        preparedText: speechText,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isReading = false;
        _isSpeaking = false;
        _ttsLoading = false;
      });
    }
  }

  int get _descriptionStartOffset => _displayTitle.length + 2;

  Widget _buildHighlightedSection({
    required String text,
    required int sectionStartOffset,
    required TextStyle style,
    int? maxLines,
    TextOverflow overflow = TextOverflow.clip,
  }) {
    final baseStyle = style.copyWith(color: style.color ?? Colors.white);
    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        style: baseStyle,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }

  String _resolvedDescription(NewsModel article) {
    final primary = (article.description ?? '').trim();
    if (primary.isNotEmpty) {
      return primary;
    }

    final cleanedContent = (article.content ?? '')
        .replaceAll(RegExp(r'\[\+\d+ chars\]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleanedContent.isNotEmpty) {
      if (cleanedContent.length > 220) {
        return '${cleanedContent.substring(0, 220)}...';
      }
      return cleanedContent;
    }

    return 'No description available. Tap Read Full to view details.';
  }

  double get _titleFontSize {
    switch (_fontLevel) {
      case ArticleFontLevel.small:
        return 28;
      case ArticleFontLevel.large:
        return 40;
      case ArticleFontLevel.medium:
        return 34;
    }
  }

  double get _descFontSize {
    switch (_fontLevel) {
      case ArticleFontLevel.small:
        return 16;
      case ArticleFontLevel.large:
        return 24;
      case ArticleFontLevel.medium:
        return 20;
    }
  }

  void _showMoreOptions(BuildContext context) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close options',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (_, __, ___) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(top: 56, right: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2333),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x33FFFFFF)),
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.text_fields,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Font',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _handleFont();
                      },
                    ),
                    const Divider(color: Colors.white24, height: 1),
                    ListTile(
                      leading: _isReporting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.flag_outlined,
                              color: Colors.white,
                            ),
                      title: const Text(
                        'Report',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onTap: _isReporting
                          ? null
                          : () {
                              Navigator.pop(context);
                              _handleReport();
                            },
                    ),
                    const Divider(color: Colors.white24, height: 1),
                    ListTile(
                      leading: _isTranslating
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.translate, color: Colors.white),
                      title: Text(
                        _isTranslated ? 'View original' : 'Translate',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      onTap: _isTranslating
                          ? null
                          : () {
                              Navigator.pop(context);
                              _handleTranslate();
                            },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.06, -0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _handleFont() async {
    final result = await FontService.showFontDialog(
      context,
      currentLevel: _fontLevel,
    );
    if (result != null && mounted) {
      setState(() => _fontLevel = result);
    }
  }

  Future<void> _handleReport() async {
    final reason = await ReportService.showReportDialog(
      context,
      title: _displayTitle,
      description: _displayDescription,
      imageUrl: widget.article.imageUrl,
    );
    if (reason == null || !mounted) return;
    setState(() => _isReporting = true);
    try {
      await widget.onReport(reason);
    } finally {
      if (!mounted) return;
      setState(() => _isReporting = false);
    }
  }

  Future<void> _handleTranslate() async {
    if (_isTranslated) {
      setState(() {
        _isTranslated = false;
        _displayTitle = widget.article.title;
        _displayDescription = _resolvedDescription(widget.article);
      });
      return;
    }

    setState(() => _isTranslating = true);
    try {
      final translated = await TranslationService.translateArticleToEnglish(
        title: widget.article.title,
        description: widget.article.description ?? '',
        content: widget.article.content,
      );

      if (!mounted) return;
      setState(() {
        _displayTitle = translated.title.trim().isNotEmpty
            ? translated.title
            : widget.article.title;
        _displayDescription = translated.description.trim().isNotEmpty
            ? translated.description
            : _resolvedDescription(widget.article);
        _isTranslated = true;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Translation failed. Please try again.')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isTranslating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final sourceHost =
        _sourceHost(widget.article.articleUrl) ??
        (widget.article.sourceName ?? 'news');
    final when =
        ArticleDateUtils.formatRelativeTime(widget.article.publishedAt) ??
        'recently';
    final hasLongDescription = _displayDescription.length > 120;

    return SafeArea(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _handleScreenTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _BackgroundImage(
              imageUrl: widget.article.imageUrl,
              width: media.width,
              height: media.height,
            ),
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66000000),
                    Color(0x33000000),
                    Color(0x99000000),
                    Color(0xE6000000),
                  ],
                  stops: [0.0, 0.35, 0.72, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x33000000),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.currentIndex + 1} / ${widget.totalCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        sourceHost,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 42),
                      GestureDetector(
                        onTap: () => _showMoreOptions(context),
                        child: const Icon(
                          Icons.more_horiz,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Text(
                                    (widget.article.sourceName ?? 'NEWS')
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      letterSpacing: 1.1,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    '•',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    when,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _buildHighlightedSection(
                                text: _displayTitle,
                                sectionStartOffset: 0,
                                maxLines: _isDescriptionExpanded ? null : 3,
                                overflow: _isDescriptionExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: _titleFontSize,
                                  fontWeight: FontWeight.w800,
                                  height: 1.05,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _buildHighlightedSection(
                                text: _displayDescription,
                                sectionStartOffset: _descriptionStartOffset,
                                maxLines: _isDescriptionExpanded
                                    ? 10
                                    : _collapsedDescriptionLines,
                                overflow: _isDescriptionExpanded
                                    ? TextOverflow.ellipsis
                                    : TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: _descFontSize,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            if (hasLongDescription)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isDescriptionExpanded =
                                          !_isDescriptionExpanded;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 0,
                                      vertical: 4,
                                    ),
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    _isDescriptionExpanded
                                        ? 'Thu gọn'
                                        : 'Xem thêm',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 46,
                                    child: ElevatedButton.icon(
                                      onPressed: widget.onReadFull,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            26,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.menu_book,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'Read Full',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _CircleAction(
                                  icon: Icons.link,
                                  onTap: widget.onOpenOriginal,
                                ),
                                const SizedBox(width: 8),
                                _CircleAction(
                                  icon: Icons.bookmark_border,
                                  onTap: widget.onSave,
                                ),
                                const SizedBox(width: 8),
                                _CircleAction(
                                  icon: Icons.share,
                                  onTap: widget.onShare,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_showCenterPlaybackIcon)
              IgnorePointer(
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 140),
                    opacity: 1,
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: const Color(0xAA000000),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0x33FFFFFF)),
                      ),
                      child: Icon(
                        _centerPlaybackIcon,
                        color: Colors.white,
                        size: 46,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String? _sourceHost(String? rawUrl) {
    final url = rawUrl?.trim();
    if (url == null || url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final host = uri.host.toLowerCase();
    if (host.isEmpty) return null;
    return host.startsWith('www.') ? host.substring(4) : host;
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0x33FFFFFF)),
          color: const Color(0x22000000),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _BackgroundImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;

  const _BackgroundImage({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final url = _normalizeImageUrl(imageUrl);

    if (url == null) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: const Icon(Icons.image, color: Colors.white24, size: 82),
      );
    }

    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image, color: Colors.white24, size: 82),
      ),
    );
  }

  String? _normalizeImageUrl(String? rawUrl) {
    final value = rawUrl?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.startsWith('//')) {
      return 'https:$value';
    }

    if (value.startsWith('www.')) {
      return 'https://$value';
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
