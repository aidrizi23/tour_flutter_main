import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'unified_filter_system.dart';
import 'animated_card.dart';
import '../utils/animation_utils.dart';

/// Enhanced unified list screen with smooth animations and mobile optimizations
class EnhancedUnifiedListScreen<T, F extends BaseFilterRequest>
    extends StatefulWidget {
  final UnifiedListScreenConfig<T, F> config;

  const EnhancedUnifiedListScreen({super.key, required this.config});

  @override
  State<EnhancedUnifiedListScreen<T, F>> createState() =>
      _EnhancedUnifiedListScreenState<T, F>();
}

class _EnhancedUnifiedListScreenState<T, F extends BaseFilterRequest>
    extends State<EnhancedUnifiedListScreen<T, F>>
    with TickerProviderStateMixin {
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

  // Animation controllers
  late AnimationController _filterAnimationController;
  late AnimationController _listAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _filterAnimation;
  late Animation<double> _fabScaleAnimation;

  // Scroll state
  double _scrollOffset = 0;
  bool _showFab = false;

  @override
  void initState() {
    super.initState();

    _filterAnimationController = AnimationController(
      duration: AnimationDurations.normal,
      vsync: this,
    );

    _listAnimationController = AnimationController(
      duration: AnimationDurations.slow,
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: AnimationDurations.fast,
      vsync: this,
    );

    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: AnimationCurves.smoothInOut,
    );

    _fabScaleAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: AnimationCurves.overshoot,
    );

    _loadItems();
    _scrollController.addListener(_onScroll);
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchDebounceTimer?.cancel();
    _filterAnimationController.dispose();
    _listAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    setState(() {
      _scrollOffset = offset;

      // Show FAB when scrolled down
      if (offset > 200 && !_showFab) {
        _showFab = true;
        _fabAnimationController.forward();
      } else if (offset <= 200 && _showFab) {
        _showFab = false;
        _fabAnimationController.reverse();
      }
    });

    // Load more items when near bottom
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        _hasMorePages) {
      _loadMoreItems();
    }
  }

  void _scrollToTop() {
    HapticUtils.mediumImpact();
    _scrollController.animateTo(
      0,
      duration: AnimationDurations.slow,
      curve: AnimationCurves.smoothOut,
    );
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
    HapticUtils.lightImpact();
    setState(() {
      _showFilters = !_showFilters;
    });

    if (_showFilters) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
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
    HapticUtils.lightImpact();
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
    HapticUtils.mediumImpact();
    _toggleFilters();
    _loadItems(isRefresh: true);
  }

  void _onQuickFilterSelected(String? filterValue) {
    HapticUtils.selectionClick();
    setState(() {
      if (filterValue == null) {
        _filters.remove('category');
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
      body: Stack(
        children: [
          CustomRefreshIndicator(
            onRefresh: () => _loadItems(isRefresh: true),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Enhanced Header with Parallax
                SliverToBoxAdapter(child: _buildEnhancedHeader(context)),

                // Search and Filters with Animation
                SliverToBoxAdapter(
                  child: _buildSearchSection(context, isMobile),
                ),

                // Animated Filters Panel
                SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _filterAnimation,
                    builder: (context, child) {
                      return SizeTransition(
                        sizeFactor: _filterAnimation,
                        child: FadeTransition(
                          opacity: _filterAnimation,
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

                // Content with Staggered Animations
                if (_isLoading && _items.isEmpty)
                  SliverFillRemaining(child: _buildLoadingState(context))
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
                    child: _buildAnimatedGrid(
                      context,
                      isMobile,
                      isTablet,
                      isDesktop,
                    ),
                  ),

                // Loading More Indicator
                if (_isLoadingMore)
                  SliverToBoxAdapter(child: _buildLoadingMoreIndicator()),

                // Bottom Padding
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),

          // Floating Action Button
          Positioned(
            right: 16,
            bottom: 16,
            child: AnimatedBuilder(
              animation: _fabScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fabScaleAnimation.value,
                  child: FloatingActionButton(
                    onPressed: _scrollToTop,
                    backgroundColor: colorScheme.primary,
                    child: const Icon(Icons.arrow_upward_rounded),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;

    // Parallax effect based on scroll
    final parallaxOffset = _scrollOffset * 0.5;

    return Container(
      height: 200,
      child: Stack(
        children: [
          // Background with gradient and parallax
          Positioned(
            top: -parallaxOffset,
            left: 0,
            right: 0,
            child: Container(
              height: 200 + parallaxOffset,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.primary.withOpacity(0.1),
                    colorScheme.surface,
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 20 : 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: AnimationDurations.normal,
                              style:
                                  Theme.of(
                                    context,
                                  ).textTheme.headlineLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                    fontSize: isMobile ? 28 : 32,
                                  ) ??
                                  const TextStyle(),
                              child: Text(widget.config.screenTitle),
                            ),
                            const SizedBox(height: 8),
                            AnimatedDefaultTextStyle(
                              duration: AnimationDurations.normal,
                              style:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(
                                      0.7,
                                    ),
                                  ) ??
                                  const TextStyle(),
                              child: Text(
                                _totalCount > 0
                                    ? '$_totalCount amazing ${widget.config.itemTypePlural} await you'
                                    : widget.config.screenSubtitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      BounceAnimation(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.config.screenIcon,
                            color: colorScheme.primary,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context, bool isMobile) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Enhanced Search Bar
          UnifiedSearchBar(
            controller: _searchController,
            hintText: widget.config.searchHint,
            onFiltersPressed: _toggleFilters,
            showFilters: _showFilters,
            onSubmitted: () => _loadItems(isRefresh: true),
            onChanged: _onSearchChanged,
          ),

          // Quick Filters with Animation
          if (!isMobile) ...[
            const SizedBox(height: 16),
            AnimatedOpacity(
              duration: AnimationDurations.fast,
              opacity: _showFilters ? 0.5 : 1.0,
              child: UnifiedQuickFilters(
                options: [
                  const QuickFilterOption(label: 'All'),
                  ...widget.config.quickFilterOptions,
                ],
                onFilterSelected: _onQuickFilterSelected,
                selectedFilter: _filters['category'],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Custom loading animation
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 2),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * 3.14159,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            widget.config.loadingMessage,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedGrid(
    BuildContext context,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive constraints
    int crossAxisCount;
    double childAspectRatio;
    double crossAxisSpacing;
    double mainAxisSpacing;

    if (isDesktop) {
      crossAxisCount = screenWidth > 1600 ? 4 : 3;
      childAspectRatio = 0.72;
      crossAxisSpacing = 20;
      mainAxisSpacing = 24;
    } else if (isTablet) {
      crossAxisCount = 2;
      childAspectRatio = 0.75;
      crossAxisSpacing = 16;
      mainAxisSpacing = 20;
    } else {
      crossAxisCount = 1;
      childAspectRatio = 1.1;
      crossAxisSpacing = 16;
      mainAxisSpacing = 16;
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1400),
        padding: EdgeInsets.all(isDesktop ? 20 : 16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];

            return TweenAnimationBuilder<double>(
              duration: Duration(
                milliseconds: 300 + (index * 50).clamp(0, 800),
              ),
              tween: Tween<double>(begin: 0, end: 1),
              curve: AnimationCurves.smoothOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: AnimatedCard(
                      onTap: () {
                        HapticUtils.lightImpact();
                        widget.config.onItemTapped(context, item);
                      },
                      child: widget.config.buildItemCard(
                        context,
                        item,
                        index,
                        isMobile,
                        isTablet,
                        isDesktop,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      child: Center(
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
                color: colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Base configuration for unified list screens (reusing from original)
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
