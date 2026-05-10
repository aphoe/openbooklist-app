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

class BookmarkMenuButton extends StatefulWidget {
  const BookmarkMenuButton({
    super.key,
    required this.bookmark,
    required this.onAction,
  });

  final Bookmark bookmark;
  final void Function(BookmarkCardAction, Bookmark) onAction;

  @override
  State<BookmarkMenuButton> createState() => _BookmarkMenuButtonState();
}

class _BookmarkMenuButtonState extends State<BookmarkMenuButton> {
  OverlayEntry? _overlayEntry;

  void _showMenu(BuildContext context) {
    final renderBox = context.findRenderObject()! as RenderBox;
    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;
    final rightEdge =
        screenSize.width - buttonPosition.dx - renderBox.size.width;
    final topOffset = buttonPosition.dy + renderBox.size.height + 6;

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closeMenu,
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
          Positioned(
            top: topOffset,
            right: rightEdge,
            child: _BookmarkMenu(
              bookmark: widget.bookmark,
              onAction: _handleAction,
              onClose: _closeMenu,
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _handleAction(BookmarkCardAction action) {
    _closeMenu();
    widget.onAction(action, widget.bookmark);
  }

  @override
  void dispose() {
    _closeMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _overlayEntry == null ? _showMenu(context) : _closeMenu(),
      child: const Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
    );
  }
}

class _BookmarkMenu extends StatelessWidget {
  const _BookmarkMenu({
    required this.bookmark,
    required this.onAction,
    required this.onClose,
  });

  final Bookmark bookmark;
  final void Function(BookmarkCardAction) onAction;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 8,
      shadowColor: Colors.black26,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderGray),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MenuHeader(title: bookmark.title ?? 'Bookmark'),
            _MenuItems(onAction: onAction, onClose: onClose),
            _MenuFooter(bookmarkId: bookmark.id),
          ],
        ),
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderGray)),
      ),
      child: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryDark),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _MenuItems extends StatelessWidget {
  const _MenuItems({required this.onAction, required this.onClose});

  final void Function(BookmarkCardAction) onAction;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MenuItem(
            icon: Icons.open_in_new_outlined,
            label: 'Visit',
            onTap: () {
              onAction(BookmarkCardAction.visit);
              onClose();
            },
          ),
          _MenuItem(
            icon: Icons.info_outlined,
            label: 'Details',
            onTap: () {
              onAction(BookmarkCardAction.details);
              onClose();
            },
          ),
          _MenuItem(
            icon: Icons.refresh_outlined,
            label: 'Refresh Metadata',
            onTap: () {
              onAction(BookmarkCardAction.refreshMetadata);
              onClose();
            },
          ),
          _MenuItem(
            icon: Icons.image_outlined,
            label: 'Set Image',
            onTap: () {
              onAction(BookmarkCardAction.setImage);
              onClose();
            },
          ),
          _MenuItem(
            icon: Icons.edit_outlined,
            label: 'Edit',
            onTap: () {
              onAction(BookmarkCardAction.edit);
              onClose();
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Divider(color: AppColors.borderGray, height: 1),
          ),
          _MenuItem(
            icon: Icons.delete_outlined,
            label: 'Delete',
            isDangerous: true,
            onTap: () {
              onAction(BookmarkCardAction.delete);
              onClose();
            },
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDangerous = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDangerous;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isDangerous ? AppColors.danger : AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: isDangerous ? AppColors.danger : AppColors.textBlack,
                  fontWeight: isDangerous ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuFooter extends StatelessWidget {
  const _MenuFooter({required this.bookmarkId});

  final int bookmarkId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderGrayLight)),
        color: Color(0xFFFAFAFA),
      ),
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
