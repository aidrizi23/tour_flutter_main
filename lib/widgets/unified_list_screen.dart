import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'unified_filter_system.dart';

/// Base configuration for unified list screens
abstract class UnifiedListScreenConfig<T, F extends BaseFilterRequest> {
  // Screen metadata
  String get screenTitle;
  String get screenSubtitle;
  IconData get screenIcon;
  String get itemTypeSingular;
  String get itemTypePlural;
  String get searchHint;
  String get emptyStateTitle;
  String get emptyStateSubtitle;
  String get loadingMessage;

  // Data operations
  Future<PagedResult<T>> loadItems(F filter);
  Future<List<String>> loadFilterOptions(String filterType);

  // Filter management
  F createFilter({
    String? searchTerm,
    Map<String, dynamic>? filters,
    String sortBy = 'created',
    bool ascending = false,
    int pageIndex = 1,
    int pageSize = 12,
  });

  List<QuickFilterOption> get quickFilterOptions;
  List<Widget> buildFilterSections(
    BuildContext context,
    Map<String, dynamic> currentFilters,
    Function(String, dynamic) onFilterChanged,
  );

  // Item rendering
  Widget buildItemCard(
    BuildContext context,
    T item,
    int index,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  );

  // Navigation
  void onItemTapped(BuildContext context, T item);
}

class PagedResult<T> {
  final List<T> items;
  final bool hasNextPage;
  final int totalCount;

  const PagedResult({
    required this.items,
    required this.hasNextPage,
    required this.totalCount,
  });
}

/// Unified list screen widget that provides consistent layout and behavior
class UnifiedListScreen<T, F extends BaseFilterRequest> extends StatefulWidget {
  final UnifiedListScreenConfig<T, F> config;

  const UnifiedListScreen({super.key, required this.config});

  @override
  State<UnifiedListScreen<T, F>> createState() =>
      _UnifiedListScreenState<T, F>();
}

class _UnifiedListScreenState<T, F extends BaseFilterRequest>
    extends State<UnifiedListScreen<T, F>>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounceTimer;

  List<T> _items = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMorePages = true;
  int _totalCount = 0;

  // Filter states
  Map<String, dynamic> _filters = {};
  String _sortBy = 'created';
  bool _sortAscending = false;
  bool _showFilters = false;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _filterAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _filterAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _loadItems();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchDebounceTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        _hasMorePages) {
      _loadMoreItems();
    }
  }

  Future<void> _loadItems({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _items.clear();
        _hasMorePages = true;
      });
    }

    setState(() {
      _isLoading = isRefresh || _items.isEmpty;
      _errorMessage = null;
    });

    try {
      final filter = widget.config.createFilter(
        searchTerm:
            _searchController.text.isNotEmpty ? _searchController.text : null,
        filters: _filters,
        sortBy: _sortBy,
        ascending: _sortAscending,
        pageIndex: _currentPage,
      );

      final result = await widget.config.loadItems(filter);

      if (mounted) {
        setState(() {
          if (isRefresh || _currentPage == 1) {
            _items = result.items;
          } else {
            _items.addAll(result.items);
          }
          _hasMorePages = result.hasNextPage;
          _totalCount = result.totalCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = _getErrorMessage(e);
        });
      }
    }
  }

  Future<void> _loadMoreItems() async {
    if (_isLoadingMore || !_hasMorePages) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      final filter = widget.config.createFilter(
        searchTerm:
            _searchController.text.isNotEmpty ? _searchController.text : null,
        filters: _filters,
        sortBy: _sortBy,
        ascending: _sortAscending,
        pageIndex: _currentPage,
      );

      final result = await widget.config.loadItems(filter);

      if (mounted) {
        setState(() {
          _items.addAll(result.items);
          _hasMorePages = result.hasNextPage;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _currentPage--;
        });
        _showErrorSnackBar(_getErrorMessage(e));
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Please check your internet connection and try again';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again';
    } else if (errorString.contains('server')) {
      return 'Server error. Please try again later';
    } else {
      return 'Something went wrong. Please try again';
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => _loadItems(isRefresh: true),
        ),
      ),
    );
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });

    if (_showFilters) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadItems(isRefresh: true);
      }
    });
  }

  void _clearFilters() {
    _searchDebounceTimer?.cancel();
    setState(() {
      _filters.clear();
      _sortBy = 'created';
      _sortAscending = false;
      _searchController.clear();
    });
    _loadItems(isRefresh: true);
  }

  void _applyFilters() {
    _toggleFilters();
    _loadItems(isRefresh: true);
  }

  void _onQuickFilterSelected(String? filterValue) {
    setState(() {
      if (filterValue == null) {
        _filters.remove(
          'category',
        ); // Assuming most quick filters are categories
      } else {
        _filters['category'] = filterValue;
      }
    });
    _loadItems(isRefresh: true);
  }

  void _onFilterChanged(String key, dynamic value) {
    setState(() {
      if (value == null) {
        _filters.remove(key);
      } else {
        _filters[key] = value;
      }
    });
  }

  bool get _hasActiveFilters {
    return _filters.isNotEmpty ||
        _searchController.text.isNotEmpty ||
        _sortBy != 'created' ||
        _sortAscending;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;
    final isMobile = screenWidth <= 600;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: RefreshIndicator(
        onRefresh: () => _loadItems(isRefresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: UnifiedScreenHeader(
                title: widget.config.screenTitle,
                subtitle: widget.config.screenSubtitle,
                icon: widget.config.screenIcon,
                itemCount: _totalCount > 0 ? _totalCount : null,
                itemType: widget.config.itemTypePlural,
              ),
            ),

            // Search and Filters
            SliverToBoxAdapter(
              child: Container(
                color: colorScheme.surface,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search Bar
                    UnifiedSearchBar(
                      controller: _searchController,
                      hintText: widget.config.searchHint,
                      onFiltersPressed: _toggleFilters,
                      showFilters: _showFilters,
                      onSubmitted: () => _loadItems(isRefresh: true),
                      onChanged: _onSearchChanged,
                    ),

                    // Quick Filters (only on tablet/desktop)
                    if (!isMobile) ...[
                      const SizedBox(height: 16),
                      UnifiedQuickFilters(
                        options: [
                          const QuickFilterOption(label: 'All'),
                          ...widget.config.quickFilterOptions,
                        ],
                        onFilterSelected: _onQuickFilterSelected,
                        selectedFilter: _filters['category'],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Filters Panel
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _filterAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -20 * (1 - _filterAnimation.value)),
                    child: Opacity(
                      opacity: _filterAnimation.value,
                      child: UnifiedFilterPanel(
                        isVisible: _showFilters,
                        filterSections: widget.config.buildFilterSections(
                          context,
                          _filters,
                          _onFilterChanged,
                        ),
                        onClearFilters: _clearFilters,
                        onApplyFilters: _applyFilters,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Content
            if (_isLoading && _items.isEmpty)
              SliverFillRemaining(
                child: UnifiedLoadingState(
                  message: widget.config.loadingMessage,
                ),
              )
            else if (_errorMessage != null)
              SliverFillRemaining(
                child: UnifiedErrorState(
                  title: 'Unable to load ${widget.config.itemTypePlural}',
                  message: _errorMessage,
                  onRetry: () => _loadItems(isRefresh: true),
                  onClearFilters: _hasActiveFilters ? _clearFilters : null,
                ),
              )
            else if (_items.isEmpty)
              SliverFillRemaining(
                child: UnifiedEmptyState(
                  title: widget.config.emptyStateTitle,
                  subtitle: widget.config.emptyStateSubtitle,
                  icon: widget.config.screenIcon,
                  hasActiveFilters: _hasActiveFilters,
                  onClearFilters: _hasActiveFilters ? _clearFilters : null,
                  onRefresh: () => _loadItems(isRefresh: true),
                ),
              )
            else
              SliverToBoxAdapter(
                child: UnifiedResponsiveGrid<T>(
                  items: _items,
                  itemBuilder:
                      (item, index) => GestureDetector(
                        onTap: () => widget.config.onItemTapped(context, item),
                        child: widget.config.buildItemCard(
                          context,
                          item,
                          index,
                          isMobile,
                          isTablet,
                          isDesktop,
                        ),
                      ),
                  isLoadingMore: _isLoadingMore,
                  loadingMoreBuilder: () => _buildLoadingMoreIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Loading more ${widget.config.itemTypePlural}...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
