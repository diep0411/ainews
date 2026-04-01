import 'package:ai_new/component/article_image.dart';
import 'package:ai_new/content.dart/all_content.dart';
import 'package:ai_new/models/news_model.dart';
import 'package:ai_new/services/save_service.dart';
import 'package:ai_new/utils/article_date_utils.dart';
import 'package:flutter/material.dart';

class SavePage extends StatelessWidget {
  const SavePage({super.key});

  @override
  Widget build(BuildContext context) {
    final savedArticles = SaveService.savedArticles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Articles'),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade100,
      body: savedArticles.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Bạn chưa lưu bài viết nào.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: savedArticles.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final article = savedArticles[index];
                return _buildSavedArticleCard(context, article);
              },
            ),
    );
  }

  Widget _buildSavedArticleCard(BuildContext context, NewsModel article) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailPage(
              imageUrl: article.imageUrl,
              sourceName: article.sourceName,
              time:
                  ArticleDateUtils.formatPublishedDate(article.publishedAt) ??
                  'Unknown time',
              title: article.title,
              description: article.description ?? 'No description',
              content: article.content,
              relatedArticles: SaveService.savedArticles,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ArticleImage(
                imageUrl: article.imageUrl,
                width: double.infinity,
                height: 180,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          article.sourceName ?? 'Unknown source',
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (article.publishedAt != null)
                        Text(
                          ArticleDateUtils.formatPublishedDate(article.publishedAt!) ?? '',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    article.title,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Text(
                  //   article.description ??
                  //       article.content ??
                  //       'Không có mô tả chi tiết.',
                  //   maxLines: 3,
                  //   overflow: TextOverflow.ellipsis,
                  //   style: TextStyle(
                  //     color: Colors.grey.shade700,
                  //     fontSize: 15,
                  //     height: 1.5,
                  //   ),
                  // ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Saved',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(
                        Icons.bookmark,
                        color: Colors.blue.shade700,
                        size: 22,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
