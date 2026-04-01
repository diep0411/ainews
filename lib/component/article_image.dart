import 'package:flutter/material.dart';

/// Reusable image widget that renders a network image with a grey placeholder
/// fallback for missing or broken URLs.
class ArticleImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const ArticleImage({
    super.key,
    required this.imageUrl,
    this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    final normalizedImageUrl = _normalizeImageUrl(imageUrl);

    return ClipRRect(
      borderRadius: borderRadius,
      child: normalizedImageUrl != null
          ? Image.network(
              normalizedImageUrl,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  String? _normalizeImageUrl(String? rawUrl) {
    final value = rawUrl?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.startsWith('//')) {
      return 'https:$value';
    }

    if (value.startsWith('www.')) {
      return 'https://$value';
    }

    final uri = Uri.tryParse(value);
    if (uri == null) {
      return null;
    }

    final scheme = uri.scheme.toLowerCase();
    if (scheme == 'http' || scheme == 'https') {
      return Uri.encodeFull(uri.toString());
    }

    return null;
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade300,
      child: const Icon(Icons.image, size: 40, color: Colors.white70),
    );
  }
}
