import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../controllers/add_bookmark_controller.dart';
import '../../data/models/category_option.dart';
import '../../data/models/tag_option.dart';
import '../../services/display_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../forms/primary_button.dart';
import '../forms/searchable_multi_select.dart';
import '../forms/searchable_select.dart';
import '../forms/text_input.dart';

class AddBookmarkModal extends StatefulWidget {
  const AddBookmarkModal({super.key, required this.onSuccess});

  final VoidCallback onSuccess;

  @override
  State<AddBookmarkModal> createState() => _AddBookmarkModalState();
}

class _AddBookmarkModalState extends State<AddBookmarkModal> {
  late final AddBookmarkController _controller;
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();

  CategoryOption? _selectedCategory;
  List<TagOption> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _controller = AddBookmarkController();
    _controller.fetchMeta();
  }

  @override
  void dispose() {
    _controller.dispose();
    _urlController.dispose();
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

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await _controller.submit(
      url: _urlController.text.trim(),
      categorySlug: _selectedCategory?.slug,
      tagSlugs: _selectedTags.map((t) => t.slug).toList(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      widget.onSuccess();
      DisplayService.showToast(
        context,
        title: 'Bookmark Saved',
        message: 'Your bookmark has been added.',
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
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const _DragHandle(),
            _ModalHeader(
              onClose: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, _) => SingleChildScrollView(
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
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.link),
                          validator: _validateUrl,
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
                        const SizedBox(height: 28),
                        PrimaryButton(
                          label: 'Save Bookmark',
                          isLoading: _controller.isSubmitting,
                          onPressed:
                              _controller.isSubmitting ? null : _onSubmit,
                          trailingIcon: Icons.bookmark_add_outlined,
                        ),
                      ],
                    ),
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
  const _ModalHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Text(
            'New Bookmark',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
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
