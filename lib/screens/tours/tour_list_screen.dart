import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/tour_models.dart';
import '../../services/tour_service.dart';
import '../../widgets/responsive_tour_card.dart';

class TourListScreen extends StatefulWidget {
  const TourListScreen({super.key});

  @override
  State<TourListScreen> createState() => _TourListScreenState();
}

class _TourListScreenState extends State<TourListScreen> {
  final TourService _tourService = TourService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounceTimer;
  final ValueNotifier<bool> _isSearching = ValueNotifier(false);

  List<Tour> _tours = [];
  List<Tour> _favoriteToursLocal = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMorePages = true;
  int _totalCount = 0;

  // Filter states
  String? _selectedCategory;
  String? _selectedLocation;
  String? _selectedDifficulty;
  String? _selectedActivityType;
  String _sortBy = 'created';
  bool _sortAscending = false;
  double? _minPrice;
  double? _maxPrice;

  List<String> _categories = [];
  List<String> _locations = [];
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadTours();
    _loadFilterOptions();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchDebounceTimer?.cancel();
    _isSearching.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        _hasMorePages) {
      _loadMoreTours();
    }
  }

  Future<void> _loadTours({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _tours.clear();
        _hasMorePages = true;
      });
    }

    setState(() {
      _isLoading = isRefresh || _tours.isEmpty;
      _errorMessage = null;
    });

    try {
      final filter = TourFilterRequest(
        searchTerm:
            _searchController.text.isNotEmpty ? _searchController.text : null,
        category: _selectedCategory,
        location: _selectedLocation,
        difficultyLevel: _selectedDifficulty,
        activityType: _selectedActivityType,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        sortBy: _sortBy,
        ascending: _sortAscending,
        pageIndex: _currentPage,
        pageSize: 12,
      );

      final result = await _tourService.getTours(filter: filter);

      if (mounted) {
        setState(() {
          if (isRefresh || _currentPage == 1) {
            _tours = result.items;
          } else {
            _tours.addAll(result.items);
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

  Future<void> _loadMoreTours() async {
    if (_isLoadingMore || !_hasMorePages) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      final filter = TourFilterRequest(
        searchTerm:
            _searchController.text.isNotEmpty ? _searchController.text : null,
        category: _selectedCategory,
        location: _selectedLocation,
        difficultyLevel: _selectedDifficulty,
        activityType: _selectedActivityType,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        sortBy: _sortBy,
        ascending: _sortAscending,
        pageIndex: _currentPage,
        pageSize: 12,
      );

      final result = await _tourService.getTours(filter: filter);

      if (mounted) {
        setState(() {
          _tours.addAll(result.items);
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
          onPressed: () => _loadTours(isRefresh: true),
        ),
      ),
    );
  }

  Future<void> _loadFilterOptions() async {
    try {
      final categories = await _tourService.getCategories();
      final locations = await _tourService.getLocations();

      setState(() {
        _categories = categories;
        _locations = locations;
      });
    } catch (e) {
      debugPrint("Error loading filter options: $e");
    }
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  void _onSearchChanged(String value) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _performSearch();
      }
    });
    _isSearching.value = true;
  }

  void _performSearch() {
    _isSearching.value = false;
    _loadTours(isRefresh: true);
  }

  void _clearFilters() {
    _searchDebounceTimer?.cancel();
    setState(() {
      _selectedCategory = null;
      _selectedLocation = null;
      _selectedDifficulty = null;
      _selectedActivityType = null;
      _minPrice = null;
      _maxPrice = null;
      _sortBy = 'created';
      _sortAscending = false;
      _searchController.clear();
    });
    _isSearching.value = false;
    _loadTours(isRefresh: true);
  }

  void _applyFilters() {
    _toggleFilters();
    _loadTours(isRefresh: true);
  }

  void _toggleFavorite(Tour tour) {
    setState(() {
      if (_favoriteToursLocal.any((t) => t.id == tour.id)) {
        _favoriteToursLocal.removeWhere((t) => t.id == tour.id);
      } else {
        _favoriteToursLocal.add(tour);
      }
    });
  }

  bool _isFavorite(Tour tour) {
    return _favoriteToursLocal.any((t) => t.id == tour.id);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;
    final isMobile = screenWidth <= 600;
    final colorScheme = Theme.of(context).colorScheme;

    // Calculate responsive constraints
    double maxContentWidth;
    int crossAxisCount;
    double childAspectRatio;

    if (isDesktop) {
      maxContentWidth = 1400;
      crossAxisCount = screenWidth > 1600 ? 4 : 3;
      childAspectRatio = 0.75;
    } else if (isTablet) {
      maxContentWidth = 1000;
      crossAxisCount = 2;
      childAspectRatio = 0.8;
    } else {
      maxContentWidth = double.infinity;
      crossAxisCount = 1;
      childAspectRatio = 1.15;
    }

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: RefreshIndicator(
        onRefresh: () => _loadTours(isRefresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Container(
                color: colorScheme.surface,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Discover Tours',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _totalCount > 0
                                        ? '$_totalCount amazing experiences await you'
                                        : 'Find your perfect adventure',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.7,
                                      ),
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
                              child: Icon(
                                Icons.explore_rounded,
                                color: colorScheme.primary,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Search and Filters
            SliverToBoxAdapter(
              child: Container(
                color: colorScheme.surface,
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _isSearching,
                            builder: (context, isSearching, _) {
                              return TextField(
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                                decoration: InputDecoration(
                                  hintText: 'Where would you like to go?',
                                  hintStyle: TextStyle(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                  prefixIcon:
                                      isSearching
                                          ? Padding(
                                            padding: const EdgeInsets.all(14.0),
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                          )
                                          : Icon(
                                            Icons.search_rounded,
                                            color: colorScheme.primary,
                                          ),
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_searchController.text.isNotEmpty)
                                        IconButton(
                                          onPressed: () {
                                            _searchController.clear();
                                            _onSearchChanged('');
                                          },
                                          icon: Icon(
                                            Icons.clear_rounded,
                                            color: colorScheme.outline,
                                          ),
                                          tooltip: 'Clear search',
                                        ),
                                      Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        child: FilledButton.icon(
                                          onPressed: _toggleFilters,
                                          icon: Icon(
                                            _showFilters
                                                ? Icons.filter_alt_rounded
                                                : Icons.filter_alt_outlined,
                                            size: 18,
                                          ),
                                          label: const Text('Filters'),
                                          style: FilledButton.styleFrom(
                                            backgroundColor:
                                                _showFilters
                                                    ? colorScheme.primary
                                                    : colorScheme
                                                        .surfaceContainerHigh,
                                            foregroundColor:
                                                _showFilters
                                                    ? Colors.white
                                                    : colorScheme.onSurface,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            elevation: _showFilters ? 2 : 0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                onSubmitted: (_) => _performSearch(),
                              );
                            },
                          ),
                        ),

                        // Quick Filters
                        if (!isMobile) ...[
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildQuickFilter(
                                'All',
                                _selectedCategory == null,
                                () {
                                  setState(() => _selectedCategory = null);
                                  _loadTours(isRefresh: true);
                                },
                              ),
                              ...(_categories
                                  .take(5)
                                  .map(
                                    (category) => _buildQuickFilter(
                                      category,
                                      _selectedCategory == category,
                                      () {
                                        setState(
                                          () => _selectedCategory = category,
                                        );
                                        _loadTours(isRefresh: true);
                                      },
                                    ),
                                  )),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Filters Panel
            if (_showFilters)
              SliverToBoxAdapter(
                child: Container(
                  color: colorScheme.surface,
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      margin: const EdgeInsets.all(16),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Filter Results',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: _clearFilters,
                                        child: const Text('Clear All'),
                                      ),
                                      const SizedBox(width: 8),
                                      FilledButton(
                                        onPressed: _applyFilters,
                                        child: const Text('Apply'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildFiltersContent(isDesktop, isTablet),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Content
            if (_isLoading && _tours.isEmpty)
              SliverFillRemaining(child: _buildLoadingState())
            else if (_errorMessage != null)
              SliverFillRemaining(child: _buildErrorState())
            else if (_tours.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Tours Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: childAspectRatio,
                              ),
                          itemCount: _tours.length,
                          itemBuilder: (context, index) {
                            final tour = _tours[index];
                            return ResponsiveTourCard(
                              tour: tour,
                              isDesktop: isDesktop,
                              isTablet: isTablet,
                              onFavoriteToggle: () => _toggleFavorite(tour),
                              isFavorite: _isFavorite(tour),
                            );
                          },
                        ),

                        // Load More Indicator
                        if (_isLoadingMore)
                          Container(
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
                                  'Loading more tours...',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 20),
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

  Widget _buildQuickFilter(String label, bool isSelected, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        HapticFeedback.lightImpact();
        onTap();
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

  Widget _buildFiltersContent(bool isDesktop, bool isTablet) {
    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: _buildLocationFilter()),
          const SizedBox(width: 16),
          Expanded(child: _buildActivityFilter()),
          const SizedBox(width: 16),
          Expanded(child: _buildDifficultyFilter()),
          const SizedBox(width: 16),
          Expanded(child: _buildSortFilter()),
        ],
      );
    } else if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildLocationFilter()),
              const SizedBox(width: 16),
              Expanded(child: _buildActivityFilter()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDifficultyFilter()),
              const SizedBox(width: 16),
              Expanded(child: _buildSortFilter()),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildLocationFilter(),
          const SizedBox(height: 16),
          _buildActivityFilter(),
          const SizedBox(height: 16),
          _buildDifficultyFilter(),
          const SizedBox(height: 16),
          _buildSortFilter(),
        ],
      );
    }
  }

  Widget _buildLocationFilter() {
    return _buildDropdownFilter(
      'Location',
      _selectedLocation,
      ['Any Location', ..._locations],
      (value) => setState(
        () => _selectedLocation = value == 'Any Location' ? null : value,
      ),
    );
  }

  Widget _buildActivityFilter() {
    return _buildDropdownFilter(
      'Activity Type',
      _selectedActivityType,
      ['Any Activity', 'Indoor', 'Outdoor', 'Mixed'],
      (value) => setState(
        () => _selectedActivityType = value == 'Any Activity' ? null : value,
      ),
    );
  }

  Widget _buildDifficultyFilter() {
    return _buildDropdownFilter(
      'Difficulty',
      _selectedDifficulty,
      ['Any Difficulty', 'Easy', 'Moderate', 'Challenging'],
      (value) => setState(
        () => _selectedDifficulty = value == 'Any Difficulty' ? null : value,
      ),
    );
  }

  Widget _buildSortFilter() {
    return _buildDropdownFilter('Sort By', _sortBy, [
      'created',
      'name',
      'price',
      'rating',
      'duration',
    ], (value) => setState(() => _sortBy = value!));
  }

  Widget _buildDropdownFilter(
    String title,
    String? currentValue,
    List<String> options,
    Function(String?) onChanged,
  ) {
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
          value: currentValue ?? options.first,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items:
              options.map((option) {
                return DropdownMenuItem(value: option, child: Text(option));
              }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
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
              'Finding amazing tours for you...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This might take a moment',
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

  Widget _buildErrorState() {
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
              'Unable to load tours',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _errorMessage ?? 'Failed to load tours',
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
                OutlinedButton.icon(
                  onPressed: _clearFilters,
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
                FilledButton.icon(
                  onPressed: () => _loadTours(isRefresh: true),
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

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    final hasActiveFilters =
        _selectedCategory != null ||
        _selectedLocation != null ||
        _selectedDifficulty != null ||
        _selectedActivityType != null ||
        _searchController.text.isNotEmpty;

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
                hasActiveFilters
                    ? Icons.search_off_rounded
                    : Icons.explore_off_rounded,
                size: 48,
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasActiveFilters
                  ? 'No matching tours found'
                  : 'No tours available',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              hasActiveFilters
                  ? 'Try adjusting your search criteria or filters to find more options'
                  : 'Check back later for new tour experiences',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (hasActiveFilters) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _clearFilters,
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
                    onPressed: _toggleFilters,
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
            ] else ...[
              FilledButton.icon(
                onPressed: () => _loadTours(isRefresh: true),
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
