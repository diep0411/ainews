import 'package:ai_new/component/article_image.dart';
import 'package:ai_new/content.dart/all_content.dart';
import 'package:ai_new/homePage.dart';
import 'package:ai_new/models/news_model.dart';
import 'package:ai_new/services/report_service.dart';
import 'package:ai_new/services/save_service.dart';
import 'package:ai_new/utils/article_date_utils.dart';
import 'package:flutter/material.dart';

class SavePage extends StatefulWidget {
  const SavePage({super.key});

  @override
  State<SavePage> createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
  static const Color _dialogPrimary = Color(0xFF1D4ED8);
  static const Color _dialogNeutralBg = Color(0xFFF3F4F6);

  Future<void> _confirmAndUnsave(NewsModel article) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Remove saved article?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
                ),
                const SizedBox(height: 10),
                Text(
                  'Do you want to remove "${article.title}" from Saved?',
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, height: 1.35),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: _dialogPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text(
                      'Remove',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: _dialogNeutralBg,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm != true) return;

    await SaveService.removeArticle(article);
    if (!mounted) return;

    setState(() {});
  }

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
              'Save',
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
                    return _buildSavedArticleCard(article);
                  },
                ),
        );
      },
    );
  }

  Widget _buildSavedArticleCard(NewsModel article) {
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
                  IconButton(
                    onPressed: () => _confirmAndUnsave(article),
                    icon: Icon(
                      Icons.bookmark,
                      color: Colors.blue.shade700,
                      size: 22,
                    ),
                    tooltip: 'Remove saved article',
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
