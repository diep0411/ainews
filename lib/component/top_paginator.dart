import 'package:flutter/material.dart';

/// Paginator for the TOP HEADLINE section.
/// Shows numbered buttons with prev/next arrows and ellipsis for large page counts.
class TopPaginator extends StatelessWidget {
  /// 0-indexed current page.
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const TopPaginator({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  static const int _maxVisible = 5;

  List<int?> _buildPageItems() {
    if (totalPages <= _maxVisible) {
      return List.generate(totalPages, (i) => i);
    }
    final items = <int>{0, totalPages - 1};
    for (var i = (currentPage - 1).clamp(0, totalPages - 1);
        i <= (currentPage + 1).clamp(0, totalPages - 1);
        i++) {
      items.add(i);
    }
    final sorted = items.toList()..sort();
    final result = <int?>[];
    for (var i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i] - sorted[i - 1] > 1) {
        result.add(null); // null = ellipsis
      }
      result.add(sorted[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final pageItems = _buildPageItems();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ArrowButton(
            icon: Icons.chevron_left,
            enabled: currentPage > 0,
            onTap: () => onPageChanged(currentPage - 1),
          ),
          const SizedBox(width: 2),
          ...pageItems.map((page) {
            if (page == null) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '...',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              );
            }
            final isActive = page == currentPage;
            return GestureDetector(
              onTap: () => onPageChanged(page),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isActive ? Colors.blue : Colors.transparent,
                  border: Border.all(
                    color: isActive ? Colors.blue : Colors.grey.shade300,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${page + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : Colors.black54,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 2),
          _ArrowButton(
            icon: Icons.chevron_right,
            enabled: currentPage < totalPages - 1,
            onTap: () => onPageChanged(currentPage + 1),
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _ArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(
          icon,
          size: 22,
          color: enabled ? Colors.blue : Colors.grey.shade300,
        ),
      ),
    );
  }
}
