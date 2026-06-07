import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatefulWidget {
  final String? initialQuery;
  final Function(String) onSearch;
  final VoidCallback? onFilterTap;
  final List<String> recentSearches;
  final List<String> suggestions;

  const SearchBarWidget({
    super.key,
    this.initialQuery,
    required this.onSearch,
    this.onFilterTap,
    this.recentSearches = const [],
    this.suggestions = const [],
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  bool _isExpanded = false;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _controller.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSuggestions = widget.recentSearches;
      } else {
        _filteredSuggestions = widget.suggestions
            .where((suggestion) => suggestion.toLowerCase().contains(query))
            .take(5)
            .toList();
      }
    });
  }

  void _onSuggestionTap(String suggestion) {
    _controller.text = suggestion;
    setState(() => _isExpanded = false);
    widget.onSearch(suggestion);
  }

  void _onSubmitted(String query) {
    setState(() => _isExpanded = false);
    widget.onSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.colorScheme.shadow
                    .withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: _onSubmitted,
                  onTap: () => setState(() => _isExpanded = true),
                  decoration: InputDecoration(
                    hintText: 'Search scholarships...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'search',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                    suffixIcon: _controller.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _controller.clear();
                              widget.onSearch('');
                            },
                            child: Padding(
                              padding: EdgeInsets.all(3.w),
                              child: CustomIconWidget(
                                iconName: 'clear',
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 6.h,
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
              ),
              GestureDetector(
                onTap: widget.onFilterTap,
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'tune',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Suggestions dropdown
        if (_isExpanded && _filteredSuggestions.isNotEmpty)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow
                      .withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_controller.text.isEmpty &&
                    widget.recentSearches.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'history',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Recent Searches',
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredSuggestions.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.1),
                  ),
                  itemBuilder: (context, index) {
                    final suggestion = _filteredSuggestions[index];
                    final isRecent = widget.recentSearches.contains(suggestion);

                    return ListTile(
                      leading: CustomIconWidget(
                        iconName: isRecent ? 'history' : 'search',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      title: Text(
                        suggestion,
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      onTap: () => _onSuggestionTap(suggestion),
                      dense: true,
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}
