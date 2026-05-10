import 'package:flutter/material.dart';

import '../../controllers/bookmark_detail_controller.dart';
import '../../data/models/bookmark.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

Future<void> showBookmarkDetailModal(
  BuildContext context,
  Bookmark bookmark,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _BookmarkDetailSheet(bookmark: bookmark),
  );
}

class _BookmarkDetailSheet extends StatefulWidget {
  const _BookmarkDetailSheet({required this.bookmark});

  final Bookmark bookmark;

  @override
  State<_BookmarkDetailSheet> createState() => _BookmarkDetailSheetState();
}

class _BookmarkDetailSheetState extends State<_BookmarkDetailSheet> {
  late final BookmarkDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BookmarkDetailController();
    _controller.fetch(widget.bookmark.id);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          const _DragHandle(),
          _SheetHeader(
            title: widget.bookmark.title ?? widget.bookmark.domain,
            onClose: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, _) {
                if (_controller.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (_controller.error != null) {
                  return _ErrorBody(message: _controller.error!);
                }
                final detail = _controller.detail;
                if (detail == null) return const SizedBox.shrink();
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: _DetailBody(detail: detail),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.borderGray,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderGrayLight)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyLargeMedium.copyWith(
                color: AppColors.textBlack,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail});

  final dynamic detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (detail.imageUrl != null) ...[
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              detail.imageUrl!,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (_, e, s) => const SizedBox.shrink(),
            ),
          ),
        ],
        const SizedBox(height: 20),
        _InfoRow(
          icon: Icons.language_outlined,
          label: 'Domain',
          value: detail.domain,
        ),
        if (detail.dateAdded != null) ...[
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date Added',
            value: detail.dateAdded!,
          ),
        ],
        if (detail.category != null) ...[
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.folder_outlined,
            label: 'Category',
            value: detail.category!,
          ),
        ],
        if (detail.tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionLabel('Tags'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: (detail.tags as List<String>)
                .map((tag) => _TagChip(label: tag))
                .toList(),
          ),
        ],
        if (detail.description != null) ...[
          const SizedBox(height: 20),
          _SectionLabel('Description'),
          const SizedBox(height: 8),
          Text(
            detail.description!,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTextStyles.labelCaps.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textBlack,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.labelCaps.copyWith(
        color: AppColors.textMuted,
        fontSize: 10,
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 40,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
