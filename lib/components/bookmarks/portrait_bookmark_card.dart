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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.borderGrayLight, width: 0.8),
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
            child: BookmarkCategoryChip(name: bookmark.category!.name),
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
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              BookmarkMenuButton(bookmark: bookmark, onAction: onAction),
            ],
          ),
          if (bookmark.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            BookmarkTagsRow(tags: bookmark.tags),
          ],
        ],
      ),
    );
  }
}
