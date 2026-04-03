class ContentItem {
  final String content;
  final String type; // IMG, IMG-DES, CONTENT, BOL, HTML
  final int position;
  final String style; // NOR, I (italic), BOL (bold)

  ContentItem({
    required this.content,
    required this.type,
    required this.position,
    required this.style,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      content: json['content'] as String? ?? '',
      type: json['type'] as String? ?? 'CONTENT',
      position: json['position'] as int? ?? 0,
      style: json['style'] as String? ?? 'NOR',
    );
  }

  Map<String, dynamic> toJson() => {
    'content': content,
    'type': type,
    'position': position,
    'style': style,
  };
}

class NewsModel {
  final String title;
  final String? description;
  final String? content;
  final String? imageUrl;
  final String? sourceName;
  final String? publishedAt;
  final String? articleUrl;
  final String? videoUrl;
  final List<ContentItem>? contentItems;

  const NewsModel({
    required this.title,
    this.description,
    this.content,
    this.imageUrl,
    this.sourceName,
    this.publishedAt,
    this.articleUrl,
    this.videoUrl,
    this.contentItems,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    final source = json['source'] as Map<String, dynamic>?;
    final contentItemsRaw = json['ctn'] as List<dynamic>?;

    return NewsModel(
      title: json['title'] as String? ?? json['tte'] as String? ?? 'No title',
      description: json['description'] as String? ?? json['dst'] as String?,
      content: json['content'] as String?,
      imageUrl: json['urlToImage'] as String? ?? json['img'] as String?,
      sourceName: source != null
          ? source['name'] as String?
          : json['src'] as String?,
      publishedAt: json['publishedAt'] as String?,
      articleUrl: json['url'] as String? ?? json['articleUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      contentItems: contentItemsRaw != null
          ? List<ContentItem>.from(
              contentItemsRaw.whereType<Map<String, dynamic>>().map(
                (item) => ContentItem.fromJson(item),
              ),
            )
          : null,
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
    'videoUrl': videoUrl,
    'contentItems': contentItems?.map((item) => item.toJson()).toList() ?? [],
  };

  factory NewsModel.fromMap(Map<String, dynamic> map) {
    final contentItemsRaw = map['contentItems'] as List<dynamic>?;

    return NewsModel(
      title: map['title'] as String? ?? 'No title',
      description: map['description'] as String?,
      content: map['content'] as String?,
      imageUrl: map['imageUrl'] as String?,
      sourceName: map['sourceName'] as String?,
      publishedAt: map['publishedAt'] as String?,
      articleUrl: map['articleUrl'] as String?,
      videoUrl: map['videoUrl'] as String?,
      contentItems: contentItemsRaw != null
          ? List<ContentItem>.from(
              contentItemsRaw.whereType<Map<String, dynamic>>().map(
                (item) => ContentItem.fromJson(item),
              ),
            )
          : null,
    );
  }
}
