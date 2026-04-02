import 'package:ai_new/component/newslate.dart';
import 'package:ai_new/component/top_article_card.dart';
import 'package:ai_new/component/top_paginator.dart';
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

  final ScrollController _scrollController = ScrollController();
  List<NewsModel> _articles = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _topPage = 0;

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

  Future<void> _loadArticles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _topPage = 0;
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
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Row(
                children: const [
                  Text(
                    'BUSINESS NEWS',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Text(
                    'View all',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
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
            TopPaginator(
              currentPage: _topPage,
              totalPages: (visibleArticles.length / _kTopPageSize).ceil(),
              onPageChanged: (page) {
                setState(() => _topPage = page);
                _scrollToTop();
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'Latest Business News',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...visibleArticles
                .skip(5)
                .take(7)
                .map(
                  (article) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: NewsLateCard(
                      article: article,
                      articlePool: visibleArticles,
                    ),
                  ),
                ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
