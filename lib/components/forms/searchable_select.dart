import 'package:flutter/material.dart';

import '../../data/models/category_option.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

class SearchableSelect extends StatefulWidget {
  const SearchableSelect({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.selectedSlug,
    this.hint = 'Select an option',
    this.isLoading = false,
  });

  final String label;
  final List<CategoryOption> options;
  final ValueChanged<CategoryOption?> onChanged;
  final String? selectedSlug;
  final String hint;
  final bool isLoading;

  @override
  State<SearchableSelect> createState() => _SearchableSelectState();
}

class _SearchableSelectState extends State<SearchableSelect>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  final _searchController = TextEditingController();
  late final AnimationController _animController;
  late final Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _heightFactor = _animController.drive(CurveTween(curve: Curves.easeInOut));
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<CategoryOption> get _filtered {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) return widget.options;
    return widget.options
        .where((o) => o.name.toLowerCase().contains(query))
        .toList();
  }

  CategoryOption? get _selected => widget.options
      .where((o) => o.slug == widget.selectedSlug)
      .firstOrNull;

  void _toggle() {
    if (widget.isLoading) return;
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      _animController.forward();
    } else {
      _animController.reverse();
      _searchController.clear();
    }
  }

  void _close() {
    setState(() => _isOpen = false);
    _animController.reverse();
    _searchController.clear();
  }

  void _select(CategoryOption option) {
    widget.onChanged(option);
    _close();
  }

  void _clear() {
    widget.onChanged(null);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;

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
        GestureDetector(
          onTap: _toggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.textGrayLighter,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isOpen ? AppColors.primary : AppColors.borderGray,
                width: _isOpen ? 2 : 1,
              ),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          selected?.name ?? widget.hint,
                          style: AppTextStyles.body.copyWith(
                            color: selected != null
                                ? AppColors.textBlack
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                      if (selected != null) ...[
                        GestureDetector(
                          onTap: _clear,
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Icon(
                        _isOpen ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
          ),
        ),
        SizeTransition(
          sizeFactor: _heightFactor,
          axisAlignment: -1,
          child: Container(
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _searchController,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textBlack,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: AppTextStyles.body.copyWith(
                        color: AppColors.textMuted,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                          color: AppColors.borderGray,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                          color: AppColors.borderGray,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.borderGray),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: _filtered.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'No options found',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final option = _filtered[i];
                            final isSelected =
                                option.slug == widget.selectedSlug;
                            return ListTile(
                              dense: true,
                              title: Text(
                                option.name,
                                style: AppTextStyles.body.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textBlack,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: AppColors.primary,
                                    )
                                  : null,
                              onTap: () => _select(option),
                            );
                          },
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
