import 'package:ai_new/component/newslate.dart';
import 'package:ai_new/component/top_article_card.dart';
import 'package:ai_new/models/news_model.dart';
import 'package:ai_new/services/news_service.dart';
import 'package:ai_new/services/report_service.dart';
import 'package:flutter/material.dart';

class BusinessPage extends StatefulWidget {
  const BusinessPage({super.key});

  @override
  State<BusinessPage> createState() => _BusinessPageState();
}

class _BusinessPageState extends State<BusinessPage> {
  static const int _kTopPageSize = 5;
  static const double _kBottomPullThreshold = 72;

  final ScrollController _scrollController = ScrollController();
  List<NewsModel> _articles = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _topPage = 0;
  bool _isPagingNext = false;
  double _bottomPullDistance = 0;

  @override
  void initState() {
    super.initState();
    _loadArticles();
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

  Future<void> _loadArticles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _topPage = 0;
      _isPagingNext = false;
      _bottomPullDistance = 0;
    });

    try {
      final articles = await NewsService.fetchBusinessArticles();
      if (!mounted) return;
      setState(() {
        _articles = articles;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ReportService.reportsVersion,
      builder: (context, _, __) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildBody(),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    final visibleArticles = ReportService.filterUnreported(_articles);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Unable to load business news.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadArticles,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (visibleArticles.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadArticles,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Center(child: Text('No business news available.')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadArticles,
      child: NotificationListener<ScrollNotification>(
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
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
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
              ...() {
                final lateArticles = [
                  ...visibleArticles.take(
                    (_topPage * _kTopPageSize).clamp(0, visibleArticles.length),
                  ),
                  ...visibleArticles.skip(
                    ((_topPage + 1) * _kTopPageSize).clamp(
                      0,
                      visibleArticles.length,
                    ),
                  ),
                ];
                if (lateArticles.isEmpty) return <Widget>[];
                return [
                  const SizedBox(height: 8),
                  const Text(
                    'Latest Business News',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...lateArticles.map(
                    (article) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: NewsLateCard(
                        article: article,
                        articlePool: visibleArticles,
                      ),
                    ),
                  ),
                ];
              }(),
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
    );
  }
}
