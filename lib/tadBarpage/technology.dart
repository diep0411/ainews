import 'package:ai_new/component/newslate.dart';
import 'package:ai_new/component/top_article_card.dart';
import 'package:ai_new/models/news_model.dart';
import 'package:ai_new/services/news_service.dart';
import 'package:flutter/material.dart';

class TechnologyPage extends StatefulWidget {
  const TechnologyPage({super.key});

  @override
  State<TechnologyPage> createState() => _TechnologyPageState();
}

class _TechnologyPageState extends State<TechnologyPage> {
  List<NewsModel> _articles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final articles = await NewsService.fetchTechnologyArticles();
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
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
                'Unable to load technology news.',
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

    if (_articles.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadArticles,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Center(child: Text('No technology news available.')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadArticles,
      child: SingleChildScrollView(
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
                    'TECH NEWS',
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
            ..._articles.take(3).map(
                  (article) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TopArticleCard(
                      article: article,
                      articlePool: _articles,
                    ),
                  ),
                ),
            const SizedBox(height: 8),
            const Text(
              'Latest Technology News',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._articles.skip(3).take(7).map(
                  (article) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: NewsLateCard(
                      article: article,
                      articlePool: _articles,
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