import 'package:flutter/material.dart';

import '../../data/models/tag_option.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

class SearchableMultiSelect extends StatefulWidget {
  const SearchableMultiSelect({
    super.key,
    required this.label,
    required this.options,
    required this.selectedTags,
    required this.onChanged,
    this.hint = 'Search or add tags',
    this.isLoading = false,
  });

  final String label;
  final List<TagOption> options;
  final List<TagOption> selectedTags;
  final ValueChanged<List<TagOption>> onChanged;
  final String hint;
  final bool isLoading;

  @override
  State<SearchableMultiSelect> createState() => _SearchableMultiSelectState();
}

class _SearchableMultiSelectState extends State<SearchableMultiSelect> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() => _showSuggestions = true);
    } else {
      setState(() => _showSuggestions = false);
    }
  }

  void _toggleSuggestions() {
    if (widget.isLoading) return;
    setState(() => _showSuggestions = !_showSuggestions);
    if (!_showSuggestions) {
      _searchController.clear();
      _focusNode.unfocus();
    }
  }

  List<TagOption> get _filtered {
    final query = _searchController.text.toLowerCase().trim();
    final selectedSlugs = widget.selectedTags.map((t) => t.slug).toSet();
    if (query.isEmpty) {
      return widget.options
          .where((o) => !selectedSlugs.contains(o.slug))
          .toList();
    }
    return widget.options
        .where(
          (o) =>
              !selectedSlugs.contains(o.slug) &&
              o.name.toLowerCase().contains(query),
        )
        .toList();
  }

  bool get _hasExactMatch {
    final query = _searchController.text.trim().toLowerCase();
    return widget.options.any((o) => o.name.toLowerCase() == query);
  }

  bool get _showAddOption {
    final text = _searchController.text.trim();
    return text.isNotEmpty && !_hasExactMatch;
  }

  void _addTag(TagOption tag) {
    widget.onChanged([...widget.selectedTags, tag]);
    _searchController.clear();
  }

  void _addCustom() {
    final text = _searchController.text.trim();
    if (text.isEmpty) return;
    _addTag(TagOption.custom(text));
  }

  void _removeTag(TagOption tag) {
    widget.onChanged(
      widget.selectedTags.where((t) => t.slug != tag.slug).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showPanel =
        _showSuggestions && (_filtered.isNotEmpty || _showAddOption);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: AppTextStyles.labelCaps.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.textGrayLighter,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? AppColors.primary
                  : AppColors.borderGray,
              width: _focusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.selectedTags.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.selectedTags
                      .map((tag) => _TagChip(tag: tag, onRemove: _removeTag))
                      .toList(),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Expanded(
                    child: widget.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textBlack,
                            ),
                            decoration: InputDecoration(
                              hintText: widget.hint,
                              hintStyle: AppTextStyles.body.copyWith(
                                color: AppColors.textMuted,
                              ),
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                  ),
                  if (_showSuggestions)
                    GestureDetector(
                      onTap: _toggleSuggestions,
                      child: Icon(
                        Icons.expand_less,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (showPanel)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderGray),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  if (_showAddOption)
                    _AddCustomTile(
                      text: _searchController.text.trim(),
                      onTap: _addCustom,
                    ),
                  ..._filtered.map(
                    (tag) => ListTile(
                      dense: true,
                      title: Text(
                        tag.name,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textBlack,
                        ),
                      ),
                      onTap: () => _addTag(tag),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.tag, required this.onRemove});

  final TagOption tag;
  final ValueChanged<TagOption> onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0x4D0792FB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag.name,
            style: AppTextStyles.regular.copyWith(color: AppColors.primary),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => onRemove(tag),
            child: const Icon(
              Icons.close,
              size: 14,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddCustomTile extends StatelessWidget {
  const _AddCustomTile({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.add, size: 18, color: AppColors.primary),
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Add ',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            TextSpan(
              text: '"$text"',
              style: AppTextStyles.body2.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
