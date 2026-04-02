import 'package:ai_new/component/newslate.dart';
import 'package:ai_new/models/news_model.dart';
import 'package:ai_new/services/news_service.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  List<NewsModel> _allArticles = [];
  List<NewsModel> _results = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _controller.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onQueryChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadArticles() async {
    try {
      final articles = await NewsService.fetchTopHeadlines();
      setState(() {
        _allArticles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onQueryChanged() {
    final query = _controller.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() {
      _results = _allArticles.where((article) {
        return _matchesQuery(article, query);
      }).toList();
    });
  }

  bool _matchesQuery(NewsModel article, String query) {
    final fields = [
      article.title,
      article.description ?? '',
      article.content ?? '',
      article.sourceName ?? '',
    ];
    return fields.any(
      (field) => field.toLowerCase().contains(query),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search articles...',
            border: InputBorder.none,
          ),
          style: const TextStyle(fontSize: 16),
          textInputAction: TextInputAction.search,
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          'Failed to load articles.\n$_errorMessage',
          textAlign: TextAlign.center,
        ),
      );
    }

    final query = _controller.text.trim();

    if (query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: Colors.black26),
            SizedBox(height: 12),
            Text(
              'Type something to search',
              style: TextStyle(color: Colors.black45, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.black26),
            const SizedBox(height: 12),
            Text(
              'No results for "$query"',
              style: const TextStyle(color: Colors.black45, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return NewsLateCard(
          article: _results[index],
          articlePool: _results,
        );
      },
    );
  }
}
