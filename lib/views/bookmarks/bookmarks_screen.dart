import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/bookmarks/bookmark_card_action.dart';
import '../../components/bookmarks/bottom_nav_bar.dart';
import '../../components/bookmarks/landscape_bookmark_card.dart';
import '../../components/bookmarks/search_box.dart';
import '../../constants/constants.dart';
import '../../controllers/bookmarks_controller.dart';
import '../../data/models/bookmark.dart';
import '../../services/display_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = BookmarksController();
    _controller.fetchBookmarks();
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

  List<Bookmark> get _recentlySaved =>
      _controller.bookmarks.take(6).toList();

  List<Bookmark> get _favorites =>
      _controller.bookmarks.where((b) => b.favorite).toList();

  List<Bookmark> get _filtered => _controller.bookmarks.where((b) {
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

  Widget _buildContent() {
    if (_controller.isLoading && _controller.bookmarks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.error != null && _controller.bookmarks.isEmpty) {
      return _ErrorView(
        message: _controller.error!,
        onRetry: _controller.refresh,
      );
    }

    // Search results replace the dashboard
    if (_searchQuery.isNotEmpty) {
      final items = _filtered;
      if (items.isEmpty) return const _EmptyView();
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) => LandscapeBookmarkCard(
          bookmark: items[i],
          onAction: _handleAction,
        ),
      );
    }

    if (_controller.bookmarks.isEmpty) return const _EmptyView();

    return RefreshIndicator(
      onRefresh: _controller.refresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _RecentlySavedSection(
              bookmarks: _recentlySaved,
              onAction: _handleAction,
            ),
          ),
          if (_favorites.isNotEmpty)
            SliverToBoxAdapter(
              child: _FavoritesSection(bookmarks: _favorites),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SearchBox(controller: _searchController),
              ),
              Container(height: 1, color: AppColors.borderGray),
            ],
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => _buildContent(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        tooltip: 'New Bookmark',
        onPressed: () {},
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

// ── Recently Saved ────────────────────────────────────────────────────────────

class _RecentlySavedSection extends StatelessWidget {
  const _RecentlySavedSection({
    required this.bookmarks,
    required this.onAction,
  });

  final List<Bookmark> bookmarks;
  final void Function(BookmarkCardAction, Bookmark) onAction;

  @override
  Widget build(BuildContext context) {
    if (bookmarks.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recently Saved',
            style: AppTextStyles.body2.copyWith(
              fontSize: 18,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 12),
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

// ── Favorites ────────────────────────────────────────────────────────────────

class _FavoritesSection extends StatelessWidget {
  const _FavoritesSection({required this.bookmarks});

  final List<Bookmark> bookmarks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Favorites',
            style: AppTextStyles.body2.copyWith(
              fontSize: 18,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grayLight),
            ),
            child: Column(
              children: bookmarks.asMap().entries.map((e) {
                return Column(
                  children: [
                    if (e.key > 0)
                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: AppColors.grayLight,
                      ),
                    _FavoriteItem(bookmark: e.value),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteItem extends StatelessWidget {
  const _FavoriteItem({required this.bookmark});

  final Bookmark bookmark;

  String get _initials {
    final parts = bookmark.domain.split('.');
    final base =
        parts.length >= 2 ? parts[parts.length - 2] : bookmark.domain;
    return base
        .substring(0, base.length >= 2 ? 2 : base.length)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _initials,
                style: AppTextStyles.labelCaps.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookmark.title ?? bookmark.domain,
                  style: AppTextStyles.bodySmallSB.copyWith(
                    color: AppColors.textBlack,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  bookmark.domain,
                  style: AppTextStyles.regular.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.star, size: 20, color: Color(0xFFFBBF24)),
        ],
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
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
