import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Base class for all filter requests to ensure consistency
abstract class BaseFilterRequest {
  final String? searchTerm;
  final String? location;
  final double? minPrice;
  final double? maxPrice;
  final String sortBy;
  final bool ascending;
  final int pageIndex;
  final int pageSize;

  const BaseFilterRequest({
    this.searchTerm,
    this.location,
    this.minPrice,
    this.maxPrice,
    required this.sortBy,
    required this.ascending,
    required this.pageIndex,
    required this.pageSize,
  });
}

/// Unified search bar component
class UnifiedSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onFiltersPressed;
  final bool showFilters;
  final VoidCallback? onSubmitted;
  final ValueChanged<String>? onChanged;

  const UnifiedSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    this.onFiltersPressed,
    this.showFilters = false,
    this.onSubmitted,
    this.onChanged,
  });

  @override
  State<UnifiedSearchBar> createState() => _UnifiedSearchBarState();
}

class _UnifiedSearchBarState extends State<UnifiedSearchBar> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              _isFocused
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.2),
          width: _isFocused ? 2 : 1,
        ),
        boxShadow:
            _isFocused
                ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
        },
        child: TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _isFocused ? colorScheme.primary : colorScheme.outline,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.controller.text.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      widget.controller.clear();
                      widget.onChanged?.call('');
                    },
                    icon: Icon(Icons.clear_rounded, color: colorScheme.outline),
                    tooltip: 'Clear search',
                  ),
                if (widget.onFiltersPressed != null)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilledButton.icon(
                      onPressed: widget.onFiltersPressed,
                      icon: Icon(
                        widget.showFilters
                            ? Icons.filter_alt_rounded
                            : Icons.filter_alt_outlined,
                        size: 18,
                      ),
                      label: Text(isMobile ? 'Filter' : 'Filters'),
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            widget.showFilters
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerHigh,
                        foregroundColor:
                            widget.showFilters
                                ? Colors.white
                                : colorScheme.onSurface,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 16,
                          vertical: 8,
                        ),
                        elevation: widget.showFilters ? 2 : 0,
                      ),
                    ),
                  ),
              ],
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          onSubmitted: (value) => widget.onSubmitted?.call(),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}

/// Unified header component for all list screens
class UnifiedScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final int? itemCount;
  final String itemType;

  const UnifiedScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.itemCount,
    required this.itemType,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;

    return Container(
      color: colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        fontSize: isMobile ? 28 : 32,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      itemCount != null
                          ? '$itemCount amazing $itemType await you'
                          : subtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Unified quick filter chips
class UnifiedQuickFilters extends StatelessWidget {
  final List<QuickFilterOption> options;
  final Function(String?) onFilterSelected;
  final String? selectedFilter;

  const UnifiedQuickFilters({
    super.key,
    required this.options,
    required this.onFilterSelected,
    this.selectedFilter,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;

    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children:
              options.map((option) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildQuickFilterChip(context, option),
                );
              }).toList(),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          options
              .map((option) => _buildQuickFilterChip(context, option))
              .toList(),
    );
  }

  Widget _buildQuickFilterChip(BuildContext context, QuickFilterOption option) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = selectedFilter == option.value;

    return FilterChip(
      label: Text(option.label),
      selected: isSelected,
      onSelected: (_) {
        HapticFeedback.lightImpact();
        onFilterSelected(isSelected ? null : option.value);
      },
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color:
              isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class QuickFilterOption {
  final String label;
  final String? value;

  const QuickFilterOption({required this.label, this.value});
}

/// Unified filter panel component
class UnifiedFilterPanel extends StatelessWidget {
  final List<Widget> filterSections;
  final VoidCallback onClearFilters;
  final VoidCallback onApplyFilters;
  final bool isVisible;

  const UnifiedFilterPanel({
    super.key,
    required this.filterSections,
    required this.onClearFilters,
    required this.onApplyFilters,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;

    if (!isVisible) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Results',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: onClearFilters,
                        child: const Text('Clear All'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: onApplyFilters,
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildFilterGrid(isDesktop, isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterGrid(bool isDesktop, bool isTablet) {
    if (isDesktop) {
      return _buildDesktopLayout();
    } else if (isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        for (int i = 0; i < filterSections.length; i += 4)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                for (int j = i; j < i + 4 && j < filterSections.length;) ...[
                  Expanded(child: filterSections[j]),
                  if (j < i + 3 && j < filterSections.length - 1)
                    const SizedBox(width: 16),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        for (int i = 0; i < filterSections.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(child: filterSections[i]),
                if (i + 1 < filterSections.length) ...[
                  const SizedBox(width: 16),
                  Expanded(child: filterSections[i + 1]),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children:
          filterSections
              .map(
                (section) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: section,
                ),
              )
              .toList(),
    );
  }
}

/// Unified dropdown filter component
class UnifiedDropdownFilter extends StatelessWidget {
  final String title;
  final String? currentValue;
  final List<String> options;
  final Function(String?) onChanged;
  final String defaultOption;

  const UnifiedDropdownFilter({
    super.key,
    required this.title,
    this.currentValue,
    required this.options,
    required this.onChanged,
    required this.defaultOption,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: currentValue ?? defaultOption,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items:
              options.map((option) {
                return DropdownMenuItem(value: option, child: Text(option));
              }).toList(),
          onChanged:
              (value) => onChanged(value == defaultOption ? null : value),
        ),
      ],
    );
  }
}

/// Unified loading state
class UnifiedLoadingState extends StatelessWidget {
  final String message;
  final String subMessage;

  const UnifiedLoadingState({
    super.key,
    required this.message,
    this.subMessage = 'This might take a moment',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Unified error state
class UnifiedErrorState extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback onRetry;
  final VoidCallback? onClearFilters;

  const UnifiedErrorState({
    super.key,
    required this.title,
    this.message,
    required this.onRetry,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                message ?? 'Something went wrong',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onClearFilters != null) ...[
                  OutlinedButton.icon(
                    onPressed: onClearFilters,
                    icon: const Icon(Icons.clear_all_rounded),
                    label: const Text('Clear Filters'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Unified empty state
class UnifiedEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool hasActiveFilters;
  final VoidCallback? onClearFilters;
  final VoidCallback? onRefresh;

  const UnifiedEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.hasActiveFilters = false,
    this.onClearFilters,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                hasActiveFilters ? Icons.search_off_rounded : icon,
                size: 48,
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (hasActiveFilters && onClearFilters != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: onClearFilters,
                    icon: const Icon(Icons.clear_all_rounded),
                    label: const Text('Clear All Filters'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: () {
                      // Show filters panel
                    },
                    icon: const Icon(Icons.tune_rounded),
                    label: const Text('Adjust Filters'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (onRefresh != null) ...[
              FilledButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Unified responsive grid layout
class UnifiedResponsiveGrid<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(T item, int index) itemBuilder;
  final Widget Function()? loadingMoreBuilder;
  final bool isLoadingMore;
  final double maxContentWidth;

  const UnifiedResponsiveGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.loadingMoreBuilder,
    this.isLoadingMore = false,
    this.maxContentWidth = 1400,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;

    // Calculate responsive constraints
    int crossAxisCount;
    double childAspectRatio;

    if (isDesktop) {
      crossAxisCount = screenWidth > 1600 ? 4 : 3;
      childAspectRatio = 0.75;
    } else if (isTablet) {
      crossAxisCount = 2;
      childAspectRatio = 0.8;
    } else {
      crossAxisCount = 1;
      childAspectRatio = 1.15;
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) => itemBuilder(items[index], index),
            ),
            if (isLoadingMore && loadingMoreBuilder != null) ...[
              const SizedBox(height: 20),
              loadingMoreBuilder!(),
            ],
          ],
        ),
      ),
    );
  }
}
