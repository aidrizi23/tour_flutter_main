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
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load tours: ${e.toString()}';
      });
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

      setState(() {
        _tours.addAll(result.items);
        _hasMorePages = result.hasNextPage;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _currentPage--;
      });
    }
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

  void _clearFilters() {
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
      maxContentWidth = 1200;
      crossAxisCount = 3;
      childAspectRatio = 0.75;
    } else if (isTablet) {
      maxContentWidth = 800;
      crossAxisCount = 2;
      childAspectRatio = 0.8;
    } else {
      maxContentWidth = double.infinity;
      crossAxisCount = 1;
      childAspectRatio = 1.2;
    }

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: RefreshIndicator(
        onRefresh: () => _loadTours(isRefresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colorScheme.primary, colorScheme.secondary],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Discover Tours',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _totalCount > 0
                                ? '$_totalCount experiences'
                                : 'Find your adventure',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
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
                              color: colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Where would you like to go?',
                              prefixIcon: Icon(
                                Icons.search,
                                color: colorScheme.primary,
                              ),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_searchController.text.isNotEmpty)
                                    IconButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        _loadTours(isRefresh: true);
                                      },
                                      icon: Icon(
                                        Icons.clear,
                                        color: colorScheme.outline,
                                      ),
                                    ),
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    child: FilledButton.icon(
                                      onPressed: _toggleFilters,
                                      icon: Icon(
                                        _showFilters
                                            ? Icons.filter_alt
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
                            onSubmitted: (_) => _loadTours(isRefresh: true),
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
            SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: !_showFilters
                    ? const SizedBox.shrink()
                    : Container(
                        color: colorScheme.surface,
                        child: Center(
                          child: Container(
                            constraints:
                                BoxConstraints(maxWidth: maxContentWidth),
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
                            margin: const EdgeInsets.all(20),
                            child: const CircularProgressIndicator(),
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
                  : colorScheme.outline.withOpacity(0.3),
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(),
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
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Failed to load tours',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => _loadTours(isRefresh: true),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_off, size: 64, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'No tours found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _clearFilters,
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
