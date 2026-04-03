import 'package:ai_new/component/article_image.dart';
import 'package:ai_new/content.dart/all_content.dart';
import 'package:ai_new/homePage.dart';
import 'package:ai_new/models/news_model.dart';
import 'package:ai_new/services/report_service.dart';
import 'package:ai_new/services/save_service.dart';
import 'package:ai_new/utils/article_date_utils.dart';
import 'package:flutter/material.dart';

class SavePage extends StatelessWidget {
  const SavePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ReportService.reportsVersion,
      builder: (context, _, __) {
        final savedArticles = ReportService.filterUnreported(
          SaveService.savedArticles,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Saved',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            centerTitle: false,
            elevation: 0,
          ),
          backgroundColor: Colors.grey.shade100,
          body: savedArticles.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'No Saved Articles Yet',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Articles you save for later will appear here. '
                          'Start exploring to find stories you love.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        // ElevatedButton.icon(
                        //   onPressed: () {
                        //     if (Navigator.of(context).canPop()) {
                        //       Navigator.of(context).pop();
                        //       return;
                        //     }

                        //     Navigator.of(context).pushReplacement(
                        //       MaterialPageRoute(
                        //         builder: (context) => const Homepage(),
                        //       ),
                        //     );
                        //   },
                        //   icon: const Icon(Icons.explore_outlined),
                        //   label: const Text('Start Exploring'),
                        // ),
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Homepage(),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Start Exploring',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: savedArticles.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final article = savedArticles[index];
                    return _buildSavedArticleCard(context, article);
                  },
                ),
        );
      },
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
              articleUrl: article.articleUrl,
              time:
                  ArticleDateUtils.formatPublishedDate(article.publishedAt) ??
                  'Unknown time',
              title: article.title,
              description: article.description ?? 'No description',
              content: article.content,
              contentItems: article.contentItems,
              videoUrl: article.videoUrl,
              relatedArticles: SaveService.savedArticles,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ArticleImage(
            imageUrl: article.imageUrl,
            width: double.infinity,
            height: 180,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    article.sourceName ?? 'Unknown source',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  if (article.publishedAt != null)
                    Text(
                      ArticleDateUtils.formatPublishedDate(
                            article.publishedAt!,
                          ) ??
                          '',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                article.title,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 19,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    SaveService.savedAgoLabel(article),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
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
        ],
      ),
    );
  }
}
