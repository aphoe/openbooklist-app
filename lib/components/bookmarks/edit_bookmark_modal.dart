import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../controllers/edit_bookmark_controller.dart';
import '../../data/models/bookmark.dart';
import '../../data/models/category_option.dart';
import '../../data/models/tag_option.dart';
import '../../services/display_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../forms/primary_button.dart';
import '../forms/searchable_multi_select.dart';
import '../forms/searchable_select.dart';
import '../forms/text_input.dart';

Future<bool> showEditBookmarkModal(
  BuildContext context,
  Bookmark bookmark,
) async {
  return await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => EditBookmarkModal(bookmark: bookmark),
      ) ??
      false;
}

class EditBookmarkModal extends StatefulWidget {
  const EditBookmarkModal({super.key, required this.bookmark});

  final Bookmark bookmark;

  @override
  State<EditBookmarkModal> createState() => _EditBookmarkModalState();
}

class _EditBookmarkModalState extends State<EditBookmarkModal> {
  late final EditBookmarkController _controller;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _urlController;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  CategoryOption? _selectedCategory;
  List<TagOption> _selectedTags = [];
  bool _preloaded = false;

  @override
  void initState() {
    super.initState();
    _controller = EditBookmarkController();
    _urlController = TextEditingController(text: widget.bookmark.url);
    _titleController = TextEditingController(text: widget.bookmark.title);
    _descriptionController =
        TextEditingController(text: widget.bookmark.description);
    _controller.addListener(_onControllerChanged);
    _controller.fetchMeta();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    if (!_preloaded &&
        !_controller.isLoadingMeta &&
        _controller.categories.isNotEmpty) {
      _preloaded = true;
      final existingCategorySlug = widget.bookmark.category?.slug;
      final matchedCategory = existingCategorySlug != null
          ? _controller.categories
              .where((c) => c.slug == existingCategorySlug)
              .firstOrNull
          : null;
      final existingSlugs =
          widget.bookmark.tags.map((t) => t.slug).toSet();
      final matchedTags = _controller.tags
          .where((t) => existingSlugs.contains(t.slug))
          .toList();
      setState(() {
        _selectedCategory = matchedCategory;
        _selectedTags = matchedTags;
      });
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _urlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateUrl(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'URL is required';
    final uri = Uri.tryParse(v);
    if (uri == null || !uri.scheme.startsWith('http')) {
      return 'Enter a valid URL (https://...)';
    }
    if (!uri.hasAuthority || uri.host.isEmpty) {
      return 'Enter a valid URL (https://...)';
    }
    return null;
  }

  String? _validateTitle(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Title is required';
    if (v.length > 255) return 'Title must not exceed 255 characters';
    return null;
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await _controller.submit(
      bookmarkId: widget.bookmark.id,
      url: _urlController.text.trim(),
      title: _titleController.text.trim(),
      categorySlug: _selectedCategory?.slug,
      tagSlugs: _selectedTags.map((t) => t.slug).toList(),
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      DisplayService.showToast(
        context,
        title: 'Bookmark Saved',
        message: 'Your changes have been saved.',
        type: ToastificationType.success,
      );
    } else {
      DisplayService.showToast(
        context,
        title: 'Failed to Save',
        message:
            _controller.submitError ?? 'An unexpected error occurred.',
        type: ToastificationType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const _DragHandle(),
            _ModalHeader(
              bookmark: widget.bookmark,
              onClose: () => Navigator.of(context).pop(false),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_controller.metaError != null) ...[
                        _MetaErrorBanner(
                          message: _controller.metaError!,
                        ),
                        const SizedBox(height: 16),
                      ],
                      const SizedBox(height: 4),
                      TextInput(
                        label: 'Web Page URL',
                        controller: _urlController,
                        hint: 'https://example.com',
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(Icons.link),
                        validator: _validateUrl,
                      ),
                      const SizedBox(height: 20),
                      TextInput(
                        label: 'Title',
                        controller: _titleController,
                        hint: 'Page title',
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(Icons.title),
                        validator: _validateTitle,
                      ),
                      const SizedBox(height: 20),
                      SearchableSelect(
                        label: 'Category',
                        options: _controller.categories,
                        selectedSlug: _selectedCategory?.slug,
                        onChanged: (opt) =>
                            setState(() => _selectedCategory = opt),
                        hint: 'Select a category',
                        isLoading: _controller.isLoadingMeta,
                      ),
                      const SizedBox(height: 20),
                      SearchableMultiSelect(
                        label: 'Tags',
                        options: _controller.tags,
                        selectedTags: _selectedTags,
                        onChanged: (tags) =>
                            setState(() => _selectedTags = tags),
                        isLoading: _controller.isLoadingMeta,
                      ),
                      const SizedBox(height: 20),
                      TextInput(
                        label: 'Description',
                        controller: _descriptionController,
                        hint: 'Brief description...',
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        prefixIcon: const Icon(Icons.description),
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(
                        label: 'Save Changes',
                        isLoading: _controller.isSubmitting,
                        onPressed:
                            _controller.isSubmitting ? null : _onSubmit,
                        trailingIcon: Icons.save_outlined,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
      child: Center(
        child: Container(
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.borderGray,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _ModalHeader extends StatelessWidget {
  const _ModalHeader({required this.bookmark, required this.onClose});

  final Bookmark bookmark;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Bookmark',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bookmark.title ?? bookmark.domain,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 20),
            color: AppColors.textSecondary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _MetaErrorBanner extends StatelessWidget {
  const _MetaErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.yellow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
