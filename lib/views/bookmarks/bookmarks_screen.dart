import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/bookmarks/add_bookmark_modal.dart';
import '../../components/bookmarks/bookmark_card_action.dart';
import '../../components/bookmarks/bookmark_detail_modal.dart';
import '../../components/bookmarks/bottom_nav_bar.dart';
import '../../components/bookmarks/landscape_bookmark_card.dart';
import '../../components/bookmarks/portrait_bookmark_card.dart';
import '../../components/bookmarks/search_box.dart';
import '../../constants/constants.dart';
import '../../controllers/bookmarks_controller.dart';
import '../../controllers/refetch_metadata_controller.dart';
import '../../data/models/bookmark.dart';
import '../../services/display_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

enum _DisplayType { grid, list }

enum _SortOption { newest, oldest, alphabetical }

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  late final BookmarksController _controller;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _navIndex = 0;
  _DisplayType _displayType = _DisplayType.list;
  _SortOption _sortBy = _SortOption.newest;

  @override
  void initState() {
    super.initState();
    _controller = BookmarksController();
    _controller.fetchBookmarks(sort: _sortToApiValue(_sortBy));
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase().trim();
    });
  }

  String _sortToApiValue(_SortOption sort) {
    switch (sort) {
      case _SortOption.newest:
        return 'newest';
      case _SortOption.oldest:
        return 'oldest';
      case _SortOption.alphabetical:
        return 'alphabetical';
    }
  }

  List<Bookmark> get _sortedBookmarks {
    final list = [..._controller.bookmarks];
    switch (_sortBy) {
      case _SortOption.newest:
        list.sort((a, b) => b.id.compareTo(a.id));
      case _SortOption.oldest:
        list.sort((a, b) => a.id.compareTo(b.id));
      case _SortOption.alphabetical:
        list.sort(
          (a, b) => (a.title ?? a.domain).toLowerCase().compareTo(
            (b.title ?? b.domain).toLowerCase(),
          ),
        );
    }
    return list;
  }

  List<Bookmark> get _allBookmarks => _sortedBookmarks;

  List<Bookmark> get _filtered => _sortedBookmarks.where((b) {
    return (b.title?.toLowerCase().contains(_searchQuery) ?? false) ||
        b.domain.toLowerCase().contains(_searchQuery) ||
        (b.description?.toLowerCase().contains(_searchQuery) ?? false) ||
        b.tags.any((t) => t.name.toLowerCase().contains(_searchQuery));
  }).toList();

  Future<void> _handleAction(
    BookmarkCardAction action,
    Bookmark bookmark,
  ) async {
    switch (action) {
      case BookmarkCardAction.visit:
        final uri = Uri.tryParse(bookmark.url);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      case BookmarkCardAction.details:
        if (mounted) await showBookmarkDetailModal(context, bookmark);
      case BookmarkCardAction.refreshMetadata:
        if (mounted) await _refetchMetadata(bookmark);
      case BookmarkCardAction.delete:
        if (mounted) await _confirmDelete(bookmark);
      default:
        if (mounted) {
          DisplayService.showToast(
            context,
            title: 'Coming Soon',
            message: 'This feature is not yet available.',
            type: ToastificationType.info,
          );
        }
    }
  }

  Future<void> _confirmDelete(Bookmark bookmark) async {
    final label = bookmark.title ?? bookmark.domain;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Bookmark'),
        content: Text('Delete "$label"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      log('TODO: delete bookmark ${bookmark.id}');
      DisplayService.showToast(
        context,
        title: 'Not Connected',
        message: 'Delete API not yet connected.',
        type: ToastificationType.warning,
      );
    }
  }

  Future<void> _refetchMetadata(Bookmark bookmark) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _LoadingDialog(message: 'Refreshing metadata…'),
    );

    final error = await RefetchMetadataController().call(bookmark.id);

    if (!mounted) return;
    Navigator.of(context).pop();

    if (error == null) {
      DisplayService.showToast(
        context,
        title: 'Metadata Refreshed',
        message: 'Bookmark metadata has been updated.',
        type: ToastificationType.success,
      );
      await _controller.refresh();
    } else {
      DisplayService.showToast(
        context,
        title: 'Refresh Failed',
        message: error,
        type: ToastificationType.error,
      );
    }
  }

  Widget _buildContent() {
    if (_controller.isLoading && _controller.bookmarks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.error != null && _controller.bookmarks.isEmpty) {
      return _ErrorView(
        message: _controller.error!,
        onRetry: () => _controller.refresh(sort: _sortToApiValue(_sortBy)),
      );
    }

    if (_searchQuery.isNotEmpty) {
      final items = _filtered;
      if (items.isEmpty) return const _EmptyView();
      if (_displayType == _DisplayType.grid) {
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.65,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) =>
              PortraitBookmarkCard(bookmark: items[i], onAction: _handleAction),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) =>
            LandscapeBookmarkCard(bookmark: items[i], onAction: _handleAction),
      );
    }

    if (_controller.bookmarks.isEmpty) return const _EmptyView();

    return RefreshIndicator(
      onRefresh: () => _controller.refresh(sort: _sortToApiValue(_sortBy)),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _BookmarksSection(
              bookmarks: _allBookmarks,
              onAction: _handleAction,
              displayType: _displayType,
            ),
          ),
          if (_controller.hasMore || _controller.isLoading)
            SliverToBoxAdapter(
              child: _LoadMoreButton(
                isLoading: _controller.isLoading,
                onLoadMore: () =>
                    _controller.loadMore(sort: _sortToApiValue(_sortBy)),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.borderGray,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Text(
          appName,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: SearchBox(controller: _searchController),
          ),
          _ControlsBar(
            displayType: _displayType,
            sortBy: _sortBy,
            onDisplayTypeChanged: (t) => setState(() => _displayType = t),
            onSortChanged: (s) => setState(() {
              _sortBy = s;
              _controller.fetchBookmarks(sort: _sortToApiValue(s));
            }),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, _) => _buildContent(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        tooltip: 'New Bookmark',
        onPressed: () async {
          await showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            backgroundColor: AppColors.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => AddBookmarkModal(
              onSuccess: () =>
                  _controller.refresh(sort: _sortToApiValue(_sortBy)),
            ),
          );
        },
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

// ── Controls Bar ──────────────────────────────────────────────────────────────

class _ControlsBar extends StatelessWidget {
  const _ControlsBar({
    required this.displayType,
    required this.sortBy,
    required this.onDisplayTypeChanged,
    required this.onSortChanged,
  });

  final _DisplayType displayType;
  final _SortOption sortBy;
  final ValueChanged<_DisplayType> onDisplayTypeChanged;
  final ValueChanged<_SortOption> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _DisplayToggle(current: displayType, onChanged: onDisplayTypeChanged),
          const SizedBox(width: 10),
          _SortButton(current: sortBy, onChanged: onSortChanged),
        ],
      ),
    );
  }
}

class _DisplayToggle extends StatelessWidget {
  const _DisplayToggle({required this.current, required this.onChanged});

  final _DisplayType current;
  final ValueChanged<_DisplayType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            icon: Icons.grid_view,
            active: current == _DisplayType.grid,
            onTap: () => onChanged(_DisplayType.grid),
          ),
          _ToggleButton(
            icon: Icons.view_list,
            active: current == _DisplayType.list,
            onTap: () => onChanged(_DisplayType.list),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 20,
          color: active ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({required this.current, required this.onChanged});

  final _SortOption current;
  final ValueChanged<_SortOption> onChanged;

  String get _shortLabel {
    switch (current) {
      case _SortOption.newest:
        return 'Date Added (Newest)';
      case _SortOption.oldest:
        return 'Date Added (Oldest)';
      case _SortOption.alphabetical:
        return 'Alphabetical';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_SortOption>(
      initialValue: current,
      onSelected: onChanged,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: AppColors.borderGray),
      ),
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: _SortOption.newest,
          child: Text('Date Added (Newest)'),
        ),
        PopupMenuItem(
          value: _SortOption.oldest,
          child: Text('Date Added (Oldest)'),
        ),
        PopupMenuItem(
          value: _SortOption.alphabetical,
          child: Text('Alphabetical'),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderGray),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort: $_shortLabel',
              style: AppTextStyles.labelCaps.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ── Bookmarks ────────────────────────────────────────────────────────────

class _BookmarksSection extends StatelessWidget {
  const _BookmarksSection({
    required this.bookmarks,
    required this.onAction,
    required this.displayType,
  });

  final List<Bookmark> bookmarks;
  final void Function(BookmarkCardAction, Bookmark) onAction;
  final _DisplayType displayType;

  @override
  Widget build(BuildContext context) {
    if (bookmarks.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (displayType == _DisplayType.grid)
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.65,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: bookmarks
                  .map(
                    (b) =>
                        PortraitBookmarkCard(bookmark: b, onAction: onAction),
                  )
                  .toList(),
            )
          else
            ...bookmarks.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LandscapeBookmarkCard(bookmark: b, onAction: onAction),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Load More ─────────────────────────────────────────────────────────────────

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.isLoading, required this.onLoadMore});

  final bool isLoading;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: isLoading ? null : onLoadMore,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.transparent,
            side: const BorderSide(color: Colors.transparent),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  'Load More',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
        ),
      ),
    );
  }
}

// ── State views ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingDialog extends StatelessWidget {
  const _LoadingDialog({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.textBlack),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bookmark_border,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'No bookmarks yet',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
