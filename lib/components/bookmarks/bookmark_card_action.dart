import 'package:flutter/material.dart';

import '../../data/models/bookmark.dart';
import '../../data/models/bookmark_tag.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

enum BookmarkCardAction {
  visit,
  details,
  refreshMetadata,
  setImage,
  edit,
  delete,
}

Color accentForBookmark(Bookmark bookmark) {
  const colors = [
    AppColors.primary,
    AppColors.warning,
    AppColors.success,
    AppColors.danger,
  ];
  final id = bookmark.category?.id ?? bookmark.id;
  return colors[id % colors.length];
}

class BookmarkMenuButton extends StatelessWidget {
  const BookmarkMenuButton({
    super.key,
    required this.bookmark,
    required this.onAction,
  });

  final Bookmark bookmark;
  final void Function(BookmarkCardAction, Bookmark) onAction;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<BookmarkCardAction>(
      icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
      padding: EdgeInsets.zero,
      itemBuilder: (_) => [
        PopupMenuItem(
          value: BookmarkCardAction.visit,
          child: Row(
            children: [
              const Icon(
                Icons.open_in_new_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 12),
              const Text('Visit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: BookmarkCardAction.details,
          child: Row(
            children: [
              const Icon(
                Icons.info_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 12),
              const Text('Details'),
            ],
          ),
        ),
        PopupMenuItem(
          value: BookmarkCardAction.refreshMetadata,
          child: Row(
            children: [
              const Icon(
                Icons.refresh_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 12),
              const Text('Refresh Metadata'),
            ],
          ),
        ),
        PopupMenuItem(
          value: BookmarkCardAction.setImage,
          child: Row(
            children: [
              const Icon(
                Icons.image_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 12),
              const Text('Set Image'),
            ],
          ),
        ),
        PopupMenuItem(
          value: BookmarkCardAction.edit,
          child: Row(
            children: [
              const Icon(
                Icons.edit_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 12),
              const Text('Edit'),
            ],
          ),
        ),
        const PopupMenuDivider(color: AppColors.borderGrayLight),
        PopupMenuItem(
          value: BookmarkCardAction.delete,
          child: Row(
            children: [
              const Icon(
                Icons.delete_outlined,
                size: 18,
                color: AppColors.danger,
              ),
              const SizedBox(width: 12),
              Text(
                'Delete',
                style: AppTextStyles.body.copyWith(color: AppColors.danger),
              ),
            ],
          ),
        ),
      ],
      onSelected: (action) => onAction(action, bookmark),
    );
  }
}

class BookmarkCategoryChip extends StatelessWidget {
  const BookmarkCategoryChip({super.key, required this.name});

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

class BookmarkTagsRow extends StatelessWidget {
  const BookmarkTagsRow({super.key, required this.tags});

  final List<BookmarkTag> tags;

  @override
  Widget build(BuildContext context) {
    final visible = tags.take(3).toList();
    final extra = tags.length - visible.length;
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...visible.map((t) => _TagChip(name: t.name)),
        if (extra > 0) _TagChip(name: '+$extra'),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        name.toUpperCase(),
        style: AppTextStyles.labelCaps.copyWith(
          color: AppColors.primary,
          fontSize: 9,
        ),
      ),
    );
  }
}
