import 'package:flutter/material.dart';

import '../../data/models/bookmark.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import 'bookmark_card_action.dart';

/// Portrait card — image fills top portion (3:4 ratio), content below.
/// Designed for use in a 2-column GridView.
class PortraitBookmarkCard extends StatelessWidget {
  const PortraitBookmarkCard({
    super.key,
    required this.bookmark,
    required this.onAction,
  });

  final Bookmark bookmark;
  final void Function(BookmarkCardAction, Bookmark) onAction;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            left: BorderSide(color: accentForBookmark(bookmark), width: 4),
            top: const BorderSide(color: AppColors.borderGray),
            right: const BorderSide(color: AppColors.borderGray),
            bottom: const BorderSide(color: AppColors.borderGray),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 110, child: _CardImage(bookmark: bookmark)),
            Expanded(
              child: _CardContent(bookmark: bookmark, onAction: onAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _image(),
        if (bookmark.category != null)
          Positioned(
            top: 10,
            left: 10,
            child: _CategoryChip(name: bookmark.category!.name),
          ),
      ],
    );
  }

  Widget _image() {
    final url = bookmark.imageUrl;
    if (url == null || url.isEmpty) return _placeholder();
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _placeholder(),
    );
  }

  Widget _placeholder() => Container(
    color: AppColors.surfaceContainer,
    child: const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.textMuted,
        size: 36,
      ),
    ),
  );
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        name.toUpperCase(),
        style: AppTextStyles.labelCaps.copyWith(
          color: AppColors.white,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({required this.bookmark, required this.onAction});

  final Bookmark bookmark;
  final void Function(BookmarkCardAction, Bookmark) onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  bookmark.title ?? bookmark.domain,
                  style: AppTextStyles.body2,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              BookmarkMenuButton(bookmark: bookmark, onAction: onAction),
            ],
          ),
          if (bookmark.tags.isNotEmpty) ...[
            const SizedBox(height: 6),
            BookmarkTagsRow(tags: bookmark.tags),
          ],
        ],
      ),
    );
  }
}
