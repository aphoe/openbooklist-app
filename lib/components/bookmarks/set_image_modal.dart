import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../controllers/set_image_controller.dart';
import '../../data/models/bookmark.dart';
import '../../services/display_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../forms/primary_button.dart';
import '../forms/text_input.dart';

Future<bool> showSetImageModal(
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
        builder: (_) => SetImageModal(bookmark: bookmark),
      ) ??
      false;
}

class SetImageModal extends StatefulWidget {
  const SetImageModal({super.key, required this.bookmark});

  final Bookmark bookmark;

  @override
  State<SetImageModal> createState() => _SetImageModalState();
}

class _SetImageModalState extends State<SetImageModal> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  String _imageSource = 'url';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  String? _validateImageUrl(String? value) {
    if (_imageSource != 'url') return null;
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Image URL is required';
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

    setState(() => _isSubmitting = true);

    final error = await SetImageController().call(
      bookmarkId: widget.bookmark.id,
      imageSource: _imageSource,
      imageUrl: _imageSource == 'url' ? _urlController.text.trim() : null,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error == null) {
      Navigator.of(context).pop(true);
    } else {
      DisplayService.showToast(
        context,
        title: 'Update Failed',
        message: error,
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
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const _DragHandle(),
            _ModalHeader(onClose: () => Navigator.of(context).pop(false)),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'IMAGE SOURCE',
                        style: AppTextStyles.labelCaps.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RadioGroup<String>(
                        groupValue: _imageSource,
                        onChanged: (v) {
                          if (v != null) setState(() => _imageSource = v);
                        },
                        child: Column(
                          children: [
                            _SourceOption(
                              value: 'url',
                              isSelected: _imageSource == 'url',
                              title: 'Image URL',
                              description: 'Upload from a direct image link',
                              onTap: () =>
                                  setState(() => _imageSource = 'url'),
                            ),
                            const SizedBox(height: 8),
                            _SourceOption(
                              value: 'screenshot',
                              isSelected: _imageSource == 'screenshot',
                              title: 'Website Screenshot',
                              description:
                                  'Capture the bookmark page automatically',
                              onTap: () =>
                                  setState(() => _imageSource = 'screenshot'),
                            ),
                          ],
                        ),
                      ),
                      if (_imageSource == 'url') ...[
                        const SizedBox(height: 20),
                        TextInput(
                          label: 'Image URL',
                          controller: _urlController,
                          hint: 'https://example.com/image.jpg',
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.link),
                          validator: _validateImageUrl,
                        ),
                      ],
                      const SizedBox(height: 28),
                      PrimaryButton(
                        label: 'Update Image',
                        isLoading: _isSubmitting,
                        onPressed: _isSubmitting ? null : _onSubmit,
                        trailingIcon: Icons.image_outlined,
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
  const _ModalHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Text(
            'Set Bookmark Image',
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

class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.value,
    required this.isSelected,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final String value;
  final bool isSelected;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderGray,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<String>(
              value: value,
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textBlack,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
