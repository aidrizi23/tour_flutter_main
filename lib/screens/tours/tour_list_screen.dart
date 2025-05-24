import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/tour_models.dart';
import '../../services/tour_service.dart';
import '../../widgets/responsive_tour_card.dart';
import '../../widgets/modern_widgets.dart';

class TourListScreen extends StatefulWidget {
  const TourListScreen({super.key});

  @override
  State<TourListScreen> createState() => _TourListScreenState();
}

class _TourListScreenState extends State<TourListScreen>
    with TickerProviderStateMixin {
  final TourService _tourService = TourService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  List<Tour> _tours = [];
  List<Tour> _favoriteToursLocal = []; // Local favorites storage
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
  int? _minDuration;
  int? _maxDuration;

  List<String> _categories = [];
  List<String> _locations = [];

  late AnimationController _searchBarController;
  late AnimationController _filterController;
  late AnimationController _fabController;
  late Animation<double> _searchBarAnimation;
  late Animation<double> _filterAnimation;
  late Animation<double> _fabAnimation;

  bool _showFilters = false;
  bool _isSearchFocused = false;
  bool _showFAB = false;

  @override
  void initState() {
    super.initState();
    _searchBarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _searchBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _searchBarController, curve: Curves.easeInOut),
    );
    _filterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _filterController, curve: Curves.easeInOut),
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );

    _searchBarController.forward();
    _loadTours();
    _loadFilterOptions();
    _scrollController.addListener(_onScroll);

    // Show FAB after initial load
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showFAB = true;
        });
        _fabController.forward();
      }
    });
  }

  @override
  void dispose() {
    _searchBarController.dispose();
    _filterController.dispose();
    _fabController.dispose();
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
        minDuration: _minDuration,
        maxDuration: _maxDuration,
        sortBy: _sortBy,
        ascending: _sortAscending,
        pageIndex: _currentPage,
        pageSize: 15,
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
        minDuration: _minDuration,
        maxDuration: _maxDuration,
        sortBy: _sortBy,
        ascending: _sortAscending,
        pageIndex: _currentPage,
        pageSize: 15,
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

    if (_showFilters) {
      _filterController.forward();
    } else {
      _filterController.reverse();
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedLocation = null;
      _selectedDifficulty = null;
      _selectedActivityType = null;
      _minPrice = null;
      _maxPrice = null;
      _minDuration = null;
      _maxDuration = null;
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
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;
    final isMobile = screenWidth <= 600;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () => _loadTours(isRefresh: true),
        color: colorScheme.primary,
        backgroundColor: colorScheme.surface,
        strokeWidth: 3,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Modern App Bar
            SliverAppBar(
              expandedHeight: isMobile ? 120 : 140,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isMobile ? 16 : 24,
                        isMobile ? 16 : 24,
                        isMobile ? 16 : 24,
                        isMobile ? 8 : 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Discover Amazing Tours',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 24 : 32,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _totalCount > 0
                                ? '$_totalCount experiences waiting for you'
                                : 'Find your next adventure',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onPrimary.withOpacity(0.9),
                              fontSize: isMobile ? 14 : 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Search and filter section
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _searchBarAnimation,
                child: _buildModernSearchSection(),
              ),
            ),

            // Filters panel
            if (_showFilters)
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _filterAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -20 * (1 - _filterAnimation.value)),
                      child: Opacity(
                        opacity: _filterAnimation.value,
                        child: _buildFiltersPanel(),
                      ),
                    );
                  },
                ),
              ),

            // Main content
            if (_isLoading && _tours.isEmpty)
              SliverFillRemaining(child: _buildLoadingState())
            else if (_errorMessage != null)
              SliverFillRemaining(child: _buildErrorState())
            else if (_tours.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              _buildToursList(isDesktop, isTablet, isMobile),
          ],
        ),
      ),
      floatingActionButton:
          _showFAB && !isMobile
              ? ScaleTransition(
                scale: _fabAnimation,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  icon: const Icon(Icons.keyboard_arrow_up_rounded),
                  label: const Text('Back to Top'),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              )
              : null,
    );
  }

  Widget _buildModernSearchSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;

    return Container(
      color: colorScheme.surface,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : (isTablet ? 24 : 32),
        isMobile ? 16 : 24,
        isMobile ? 16 : (isTablet ? 24 : 32),
        isMobile ? 12 : 16,
      ),
      child: Column(
        children: [
          // Search bar with booking.com style
          Container(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 600 : (isMobile ? double.infinity : 800),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      _isSearchFocused
                          ? colorScheme.primary
                          : colorScheme.outline.withOpacity(0.3),
                  width: _isSearchFocused ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Focus(
                onFocusChange: (hasFocus) {
                  setState(() {
                    _isSearchFocused = hasFocus;
                  });
                },
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Where would you like to go?',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontSize: isMobile ? 16 : 18,
                    ),
                    prefixIcon: Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.search_rounded,
                        color:
                            _isSearchFocused
                                ? colorScheme.primary
                                : colorScheme.outline,
                        size: isMobile ? 24 : 28,
                      ),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _loadTours(isRefresh: true);
                              setState(() {});
                            },
                            icon: Icon(
                              Icons.clear_rounded,
                              color: colorScheme.outline,
                            ),
                          ),
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: FilledButton.icon(
                            onPressed: _toggleFilters,
                            icon: AnimatedRotation(
                              turns: _showFilters ? 0.5 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                Icons.tune_rounded,
                                size: isMobile ? 18 : 20,
                              ),
                            ),
                            label: Text(
                              isMobile ? 'Filter' : 'Filters',
                              style: TextStyle(fontSize: isMobile ? 14 : 16),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  _showFilters
                                      ? colorScheme.primary
                                      : colorScheme.surfaceContainerHigh,
                              foregroundColor:
                                  _showFilters
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurface,
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 12 : 16,
                                vertical: isMobile ? 8 : 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: isMobile ? 16 : 20,
                    ),
                  ),
                  style: TextStyle(fontSize: isMobile ? 16 : 18),
                  onSubmitted: (_) => _loadTours(isRefresh: true),
                  onChanged: (value) {
                    setState(() {});
                    if (value.isEmpty) {
                      _loadTours(isRefresh: true);
                    }
                  },
                ),
              ),
            ),
          ),

          if (!isMobile) ...[
            const SizedBox(height: 16),
            // Quick filters for desktop/tablet
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildQuickFilter(
                  'All Categories',
                  _selectedCategory == null,
                  () {
                    setState(() => _selectedCategory = null);
                    _loadTours(isRefresh: true);
                  },
                ),
                ...(_categories.isNotEmpty
                    ? _categories
                        .take(isTablet ? 4 : 6)
                        .map(
                          (category) => _buildQuickFilter(
                            category,
                            _selectedCategory == category,
                            () {
                              setState(() => _selectedCategory = category);
                              _loadTours(isRefresh: true);
                            },
                          ),
                        )
                    : []),
              ],
            ),
          ],
        ],
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
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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

  Widget _buildFiltersPanel() {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;

    return Container(
      margin: EdgeInsets.fromLTRB(
        isMobile ? 16 : 32,
        0,
        isMobile ? 16 : 32,
        16,
      ),
      child: ModernCard(
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Your Search',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear_all_rounded),
                      label: const Text('Clear All'),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _applyFilters,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Filter content in grid for desktop/tablet
            if (!isMobile)
              GridView.count(
                crossAxisCount: screenWidth > 1200 ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFilterDropdown(
                    'Location',
                    _selectedLocation,
                    ['Any Location', ..._locations],
                    (value) => setState(
                      () =>
                          _selectedLocation =
                              value == 'Any Location' ? null : value,
                    ),
                  ),
                  _buildFilterDropdown(
                    'Activity Type',
                    _selectedActivityType,
                    ['Any Activity', 'Indoor', 'Outdoor', 'Mixed'],
                    (value) => setState(
                      () =>
                          _selectedActivityType =
                              value == 'Any Activity' ? null : value,
                    ),
                  ),
                  _buildFilterDropdown(
                    'Difficulty',
                    _selectedDifficulty,
                    ['Any Difficulty', 'Easy', 'Moderate', 'Challenging'],
                    (value) => setState(
                      () =>
                          _selectedDifficulty =
                              value == 'Any Difficulty' ? null : value,
                    ),
                  ),
                  _buildFilterDropdown('Sort By', _sortBy, [
                    'created',
                    'name',
                    'price',
                    'rating',
                    'duration',
                  ], (value) => setState(() => _sortBy = value!)),
                ],
              )
            else
              // Mobile filter layout
              Column(
                children: [
                  _buildMobileFilterSection(
                    'Location',
                    _selectedLocation,
                    ['Any Location', ..._locations],
                    (value) {
                      setState(
                        () =>
                            _selectedLocation =
                                value == 'Any Location' ? null : value,
                      );
                    },
                  ),
                  _buildMobileFilterSection(
                    'Activity Type',
                    _selectedActivityType,
                    ['Any Activity', 'Indoor', 'Outdoor', 'Mixed'],
                    (value) {
                      setState(
                        () =>
                            _selectedActivityType =
                                value == 'Any Activity' ? null : value,
                      );
                    },
                  ),
                  _buildMobileFilterSection(
                    'Difficulty',
                    _selectedDifficulty,
                    ['Any Difficulty', 'Easy', 'Moderate', 'Challenging'],
                    (value) {
                      setState(
                        () =>
                            _selectedDifficulty =
                                value == 'Any Difficulty' ? null : value,
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(
    String title,
    String? currentValue,
    List<String> options,
    Function(String?) onChanged,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: currentValue ?? options.first,
            isExpanded: true,
            underline: const SizedBox(),
            items:
                options.map((option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFilterSection(
    String title,
    String? currentValue,
    List<String> options,
    Function(String?) onChanged,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: currentValue ?? options.first,
              isExpanded: true,
              underline: const SizedBox(),
              items:
                  options.map((option) {
                    return DropdownMenuItem(value: option, child: Text(option));
                  }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToursList(bool isDesktop, bool isTablet, bool isMobile) {
    return SliverToBoxAdapter(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 1400 : double.infinity,
        ),
        margin: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32 : (isTablet ? 24 : 16),
        ),
        child: Column(
          children: [
            // Tours grid/list
            if (isDesktop)
              // Desktop: Single column list
              Column(
                children:
                    _tours.map((tour) {
                      return ResponsiveTourCard(
                        tour: tour,
                        isDesktop: true,
                        onFavoriteToggle: () => _toggleFavorite(tour),
                        isFavorite: _isFavorite(tour),
                      );
                    }).toList(),
              )
            else if (isTablet)
              // Tablet: Two column grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: _tours.length,
                itemBuilder: (context, index) {
                  final tour = _tours[index];
                  return ResponsiveTourCard(
                    tour: tour,
                    isTablet: true,
                    onFavoriteToggle: () => _toggleFavorite(tour),
                    isFavorite: _isFavorite(tour),
                  );
                },
              )
            else
              // Mobile: Single column
              Column(
                children:
                    _tours.map((tour) {
                      return ResponsiveTourCard(
                        tour: tour,
                        onFavoriteToggle: () => _toggleFavorite(tour),
                        isFavorite: _isFavorite(tour),
                      );
                    }).toList(),
              ),

            // Loading more indicator
            if (_isLoadingMore)
              Container(
                margin: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(width: 16),
                    Text(
                      'Loading more tours...',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),

            // Bottom spacing
            SizedBox(height: isMobile ? 80 : 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isMobile ? 80 : 100,
            height: isMobile ? 80 : 100,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
                strokeWidth: 4,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 24 : 32),
          Text(
            'Discovering amazing tours...',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            'This won\'t take long',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        child: ModernCard(
          padding: EdgeInsets.all(isMobile ? 24 : 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 20 : 24),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: isMobile ? 48 : 64,
                  color: colorScheme.error,
                ),
              ),
              SizedBox(height: isMobile ? 20 : 24),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isMobile ? 10 : 12),
              Text(
                _errorMessage ?? 'Failed to load tours',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 24 : 32),
              FilledButton.icon(
                onPressed: () => _loadTours(isRefresh: true),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 24,
                    vertical: isMobile ? 12 : 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        child: ModernCard(
          padding: EdgeInsets.all(isMobile ? 24 : 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 20 : 24),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.explore_off_rounded,
                  size: isMobile ? 48 : 64,
                  color: colorScheme.outline,
                ),
              ),
              SizedBox(height: isMobile ? 20 : 24),
              Text(
                'No tours found',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isMobile ? 10 : 12),
              Text(
                'Try adjusting your search or filters to find more options',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 24 : 32),
              OutlinedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('Clear Filters'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 24,
                    vertical: isMobile ? 12 : 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
