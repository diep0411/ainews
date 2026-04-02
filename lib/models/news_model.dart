class NewsModel {
  final String title;
  final String? description;
  final String? content;
  final String? imageUrl;
  final String? sourceName;
  final String? publishedAt;
  final String? articleUrl;

  const NewsModel({
    required this.title,
    this.description,
    this.content,
    this.imageUrl,
    this.sourceName,
    this.publishedAt,
    this.articleUrl,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    final source = json['source'] as Map<String, dynamic>?;

    return NewsModel(
      title: json['title'] as String? ?? 'No title',
      description: json['description'] as String?,
      content: json['content'] as String?,
      imageUrl: json['urlToImage'] as String?,
      sourceName: source != null ? source['name'] as String? : null,
      publishedAt: json['publishedAt'] as String?,
      articleUrl: json['url'] as String?,
    );
  }

  /// Flat map used for local persistence (SharedPreferences).
  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'content': content,
        'imageUrl': imageUrl,
        'sourceName': sourceName,
        'publishedAt': publishedAt,
        'articleUrl': articleUrl,
      };

  factory NewsModel.fromMap(Map<String, dynamic> map) => NewsModel(
        title: map['title'] as String? ?? 'No title',
        description: map['description'] as String?,
        content: map['content'] as String?,
        imageUrl: map['imageUrl'] as String?,
        sourceName: map['sourceName'] as String?,
        publishedAt: map['publishedAt'] as String?,
        articleUrl: map['articleUrl'] as String?,
      );
}
