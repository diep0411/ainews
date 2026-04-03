import 'package:ai_new/component/article_image.dart';
import 'package:ai_new/component/newslate.dart';
import 'package:ai_new/component/top_article_card.dart';
import 'package:ai_new/models/news_model.dart';
import 'package:ai_new/services/report_service.dart';
import 'package:flutter/material.dart';

class TopicSections extends StatelessWidget {
  final List<NewsModel> articlePool;
  final void Function(NewsModel article, List<NewsModel> articlePool)
  onOpenArticle;

  const TopicSections({
    super.key,
    required this.articlePool,
    required this.onOpenArticle,
  });

  static const List<_TopicSpec> _topicSpecs = [
    _TopicSpec(
      title: 'IRAN, ISRAEL',
      badge: 'LIVE',
      ctgIdFilters: [44], 
      keywords: [
        'iran',
        'tehran',
        'persian',
        'iranian',
        'israel',
        'israeli',
        'gaza',
        'hamas',
        'jerusalem',
      ],
    ),
    _TopicSpec(
      title: 'SPORT',
      badge: 'TRENDING',
      ctgIdFilters: [32], // Sport category
      keywords: [
        'sport',
        'sports',
        'football',
        'soccer',
        'tennis',
        'nba',
        'fifa',
        'olympic',
      ],
    ),
  ];

  bool _containsWholeWord(String text, String keyword) {
    if (keyword.isEmpty || text.isEmpty) {
      return false;
    }

    final escapedKeyword = RegExp.escape(keyword.toLowerCase());
    final pattern = RegExp(
      r'(^|[^a-z0-9])' + escapedKeyword + r'([^a-z0-9]|$)',
      caseSensitive: false,
    );
    return pattern.hasMatch(text);
  }

  int _countKeywordMatches(String text, List<String> keywords) {
    var hits = 0;
    for (final keyword in keywords) {
      if (_containsWholeWord(text, keyword)) {
        hits++;
      }
    }
    return hits;
  }

  List<NewsModel> _matchedArticlesForSpec(
    _TopicSpec spec,
    List<NewsModel> articles,
  ) {
    final scored = <MapEntry<NewsModel, int>>[];

    for (final article in articles) {
      int score = 0;

      // Primary: check ctgId
      if (article.ctgId != null && spec.ctgIdFilters.contains(article.ctgId)) {
        score += 100; // High score for ctgId match
      }

      // If strong ctgId match, add to result
      if (score >= 100) {
        scored.add(MapEntry(article, score));
        continue;
      }

      // Fallback: keyword matching
      final title = article.title.toLowerCase();
      final description = (article.description ?? '').toLowerCase();
      final source = (article.sourceName ?? '').toLowerCase();
      final content = (article.content ?? '').toLowerCase();

      final titleHits = _countKeywordMatches(title, spec.keywords);
      final descriptionHits = _countKeywordMatches(description, spec.keywords);
      final sourceHits = _countKeywordMatches(source, spec.keywords);
      final contentHits = _countKeywordMatches(content, spec.keywords);

      final hasStrongSignal = (titleHits + descriptionHits + sourceHits) > 0;
      if (!hasStrongSignal && contentHits < 2) {
        continue;
      }

      score =
          (titleHits * 6) +
          (descriptionHits * 3) +
          (sourceHits * 2) +
          contentHits;
      scored.add(MapEntry(article, score));
    }

    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.map((entry) => entry.key).toList();
  }

  void _openTopicAllPage(
    BuildContext context,
    _TopicSpec spec,
    List<NewsModel> topicArticles,
    List<NewsModel> allArticles,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TopicAllArticlesPage(
          topicSpec: spec,
          articles: topicArticles,
          articlePool: allArticles,
        ),
      ),
    );
  }

  Widget _buildTopicCard({
    required _TopicSpec spec,
    required NewsModel article,
  }) {
    return InkWell(
      onTap: () => onOpenArticle(article, articlePool),
      child: ClipRRect(
        child: SizedBox(
          height: 205,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ArticleImage(
                imageUrl: article.imageUrl,
                width: double.infinity,
                height: 205,
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x22000000), Color(0xD9000000)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: spec.badge == 'LIVE'
                                ? const Color(0xFFE62929)
                                : const Color(0xFF1A2E8A),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            spec.badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            article.sourceName ?? 'Unknown source',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[];

    for (final spec in _topicSpecs) {
      final matches = _matchedArticlesForSpec(spec, articlePool);
      if (matches.isEmpty) continue;
      final article = matches.first;

      sections.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 17,
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      spec.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4A5568),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () =>
                        _openTopicAllPage(context, spec, matches, articlePool),
                    child: const Row(
                      children: [
                        Text(
                          'View all',
                          style: TextStyle(
                            color: Color(0xFF2D4BA0),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right,
                          color: Color(0xFF2D4BA0),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (matches.length > 1) ...[
                SizedBox(
                  height: 205,
                  child: PageView.builder(
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _buildTopicCard(
                          spec: spec,
                          article: matches[index],
                        ),
                      );
                    },
                  ),
                ),
              ] else
                _buildTopicCard(spec: spec, article: article),
            ],
          ),
        ),
      );
    }

    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(children: sections);
  }
}

class _TopicSpec {
  final String title;
  final String badge;
  final List<String> keywords;
  final List<int> ctgIdFilters; // Primary filter: ctgId (category IDs)

  const _TopicSpec({
    required this.title,
    required this.badge,
    required this.keywords,
    required this.ctgIdFilters,
  });
}

class TopicAllArticlesPage extends StatefulWidget {
  final _TopicSpec topicSpec;
  final List<NewsModel> articles;
  final List<NewsModel> articlePool;

  const TopicAllArticlesPage({
    super.key,
    required this.topicSpec,
    required this.articles,
    required this.articlePool,
  });

  @override
  State<TopicAllArticlesPage> createState() => _TopicAllArticlesPageState();
}

class _TopicAllArticlesPageState extends State<TopicAllArticlesPage> {
  static const int _kTopPageSize = 5;
  static const double _kBottomPullThreshold = 72;
  final ScrollController _scrollController = ScrollController();
  int _topPage = 0;
  bool _isPagingNext = false;
  double _bottomPullDistance = 0;

  String _articleKey(NewsModel article) {
    final title = article.title.trim().toLowerCase();
    final source = (article.sourceName ?? '').trim().toLowerCase();
    return '$title::$source';
  }

  bool _looselyMatchesTopic(NewsModel article) {
    // Primary: check ctgId
    if (article.ctgId != null &&
        widget.topicSpec.ctgIdFilters.contains(article.ctgId)) {
      return true;
    }

    // Fallback: keyword matching
    final haystack = [
      article.title,
      article.description ?? '',
      article.content ?? '',
      article.sourceName ?? '',
    ].join(' ').toLowerCase();

    return widget.topicSpec.keywords.any(
      (keyword) => haystack.contains(keyword.toLowerCase()),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _advanceTopPageAtBottom(int totalItems) async {
    final totalPages = (totalItems / _kTopPageSize).ceil();
    if (totalPages <= 1 || _isPagingNext) return;

    setState(() {
      _isPagingNext = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;

    setState(() {
      _topPage = (_topPage + 1) % totalPages;
      _isPagingNext = false;
      _bottomPullDistance = 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToTop());
  }

  @override
  Widget build(BuildContext context) {
    final visibleArticles = ReportService.filterUnreported(widget.articles);
    final currentTop = visibleArticles
        .skip(_topPage * _kTopPageSize)
        .take(_kTopPageSize)
        .toList();
    final topKeys = currentTop.map(_articleKey).toSet();

    final strictRelated = visibleArticles
        .where((article) => !topKeys.contains(_articleKey(article)))
        .toList();

    final strictKeys = visibleArticles.map(_articleKey).toSet();
    final supplemental = ReportService.filterUnreported(widget.articlePool)
        .where(_looselyMatchesTopic)
        .where((article) {
          final key = _articleKey(article);
          return !topKeys.contains(key) && !strictKeys.contains(key);
        })
        .toList();

    final latestDisplay = <NewsModel>[
      ...strictRelated,
      ...supplemental,
    ].take(10).toList();

    final relatedStories = latestDisplay.isNotEmpty
        ? latestDisplay
        : visibleArticles.take(10).toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.topicSpec.title)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: visibleArticles.isEmpty
            ? const Center(child: Text('No news to display.'))
            : NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.axis != Axis.vertical) return false;

                  final atBottom = notification.metrics.extentAfter <= 1;

                  if (!atBottom) {
                    _bottomPullDistance = 0;
                    return false;
                  }

                  if (_isPagingNext) {
                    return false;
                  }

                  if (notification is OverscrollNotification &&
                      notification.overscroll > 0) {
                    _bottomPullDistance += notification.overscroll;
                    if (_bottomPullDistance >= _kBottomPullThreshold) {
                      _advanceTopPageAtBottom(visibleArticles.length);
                    }
                  } else if (notification is ScrollEndNotification) {
                    _bottomPullDistance = 0;
                  }

                  return false;
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'TOP HEADLINE',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...visibleArticles
                          .skip(_topPage * _kTopPageSize)
                          .take(_kTopPageSize)
                          .map(
                            (article) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: TopArticleCard(
                                article: article,
                                articlePool: visibleArticles,
                              ),
                            ),
                          ),
                      const SizedBox(height: 8),
                      const Text(
                        'Related Stories',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...relatedStories.map(
                        (article) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: NewsLateCard(
                            article: article,
                            articlePool: visibleArticles,
                          ),
                        ),
                      ),
                      if (_isPagingNext)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
