import 'package:flutter/material.dart';

import '../../data/models/bookmark.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import 'bookmark_card_action.dart';

/// Landscape card — thumbnail on left, content on right.
/// Fixed height of 100px; designed for use in a ListView.
class LandscapeBookmarkCard extends StatelessWidget {
  const LandscapeBookmarkCard({
    super.key,
    required this.bookmark,
    required this.onAction,
  });

  final Bookmark bookmark;
  final void Function(BookmarkCardAction, Bookmark) onAction;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 100,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              left: BorderSide(
                color: accentForBookmark(bookmark),
                width: 4,
              ),
              top: const BorderSide(color: AppColors.borderGray),
              right: const BorderSide(color: AppColors.borderGray),
              bottom: const BorderSide(color: AppColors.borderGray),
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 88, child: _buildImage()),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              bookmark.title ?? bookmark.domain,
                              style: AppTextStyles.bodySmallSB,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          BookmarkMenuButton(
                            bookmark: bookmark,
                            onAction: onAction,
                          ),
                        ],
                      ),
                      Text(
                        bookmark.domain,
                        style: AppTextStyles.regular.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (bookmark.tags.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        BookmarkTagsRow(tags: bookmark.tags),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final url = bookmark.imageUrl;
    if (url == null || url.isEmpty) return _placeholder();
    return Image.network(
      url,
      width: 88,
      height: double.infinity,
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
        size: 24,
      ),
    ),
  );
}
