import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../models/tour_models.dart';
import '../../services/tour_service.dart';
import '../../widgets/custom_text_field.dart';
import 'tour_details_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 600 && screenWidth <= 1024;
    final isMobile = screenWidth <= 600;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: _buildAppBar(context),
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
            // Search section - improved for mobile
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _searchBarAnimation,
                child: Container(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _buildMobileSearchAndFilters(context),
                ),
              ),
            ),

            // Filters panel - mobile optimized
            if (_showFilters)
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _filterAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -20 * (1 - _filterAnimation.value)),
                      child: Opacity(
                        opacity: _filterAnimation.value,
                        child: _buildMobileFiltersPanel(),
                      ),
                    );
                  },
                ),
              ),

            // Results header - more compact on mobile
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 12 : 16,
                  isMobile ? 12 : 16,
                  isMobile ? 12 : 16,
                  isMobile ? 8 : 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _isLoading
                            ? 'Finding experiences...'
                            : _totalCount == 1
                            ? '1 experience found'
                            : '$_totalCount experiences found',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withOpacity(0.8),
                          fontSize: isMobile ? 14 : 16,
                        ),
                      ),
                    ),
                    if (_tours.isNotEmpty && !_isLoading)
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            isMobile ? 8 : 10,
                          ),
                        ),
                        child: IconButton(
                          onPressed: _toggleFilters,
                          icon: AnimatedRotation(
                            turns: _showFilters ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.tune_rounded,
                              size: isMobile ? 20 : 22,
                            ),
                          ),
                          color: colorScheme.primary,
                          tooltip: 'Filter & Sort',
                          padding: EdgeInsets.all(isMobile ? 8 : 10),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Tours grid/list - optimized for mobile
            if (_isLoading && _tours.isEmpty)
              SliverFillRemaining(child: _buildLoadingState())
            else if (_errorMessage != null)
              SliverFillRemaining(child: _buildErrorState())
            else if (_tours.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 12 : 16,
                  0,
                  isMobile ? 12 : 16,
                  isMobile ? 12 : 16,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
                    crossAxisSpacing: isMobile ? 0 : 16,
                    mainAxisSpacing: isMobile ? 16 : 16,
                    childAspectRatio: _calculateAspectRatio(isMobile, isTablet),
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index < _tours.length) {
                      return _buildMobileTourCard(_tours[index], isMobile);
                    } else if (_isLoadingMore) {
                      return _buildLoadingMoreCard(isMobile);
                    }
                    return null;
                  }, childCount: _tours.length + (_isLoadingMore ? 1 : 0)),
                ),
              ),

            // Bottom spacing for mobile
            SliverToBoxAdapter(child: SizedBox(height: isMobile ? 80 : 40)),
          ],
        ),
      ),
      floatingActionButton:
          _showFAB
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
                  label: const Text('Top'),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              )
              : null,
    );
  }

  double _calculateAspectRatio(bool isMobile, bool isTablet) {
    if (isMobile) return 1.2;
    if (isTablet) return 0.9;
    return 0.85;
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discover',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 24 : 28,
            ),
          ),
          Text(
            'Amazing experiences await',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withOpacity(0.9),
              fontSize: isMobile ? 13 : 14,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Add favorites/wishlist feature
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Favorites feature coming soon!'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.all(isMobile ? 12 : 16),
              ),
            );
          },
          icon: const Icon(Icons.favorite_border_rounded),
          color: colorScheme.onPrimary,
          tooltip: 'Favorites',
        ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileSearchAndFilters(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Column(
      children: [
        // Search bar - mobile optimized
        Container(
          height: isMobile ? 52 : 56,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(isMobile ? 14 : 16),
            border: Border.all(
              color:
                  _isSearchFocused
                      ? colorScheme.primary
                      : colorScheme.outline.withOpacity(0.2),
              width: _isSearchFocused ? 2 : 1,
            ),
            boxShadow:
                _isSearchFocused
                    ? [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
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
                hintText:
                    isMobile
                        ? 'Search experiences...'
                        : 'Where do you want to go?',
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontSize: isMobile ? 15 : 16,
                ),
                prefixIcon: Container(
                  width: isMobile ? 45 : 50,
                  height: isMobile ? 45 : 50,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.search_rounded,
                    color:
                        _isSearchFocused
                            ? colorScheme.primary
                            : colorScheme.outline,
                    size: isMobile ? 22 : 24,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 20,
                  vertical: isMobile ? 14 : 16,
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _loadTours(isRefresh: true);
                            setState(() {});
                          },
                          icon: Icon(
                            Icons.clear_rounded,
                            size: isMobile ? 20 : 22,
                          ),
                          color: colorScheme.outline,
                        )
                        : null,
              ),
              style: TextStyle(fontSize: isMobile ? 15 : 16),
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

        // Quick filters - mobile optimized
        const SizedBox(height: 12),
        Container(
          height: isMobile ? 36 : 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildQuickFilter('All', _selectedCategory == null, () {
                setState(() => _selectedCategory = null);
                _loadTours(isRefresh: true);
              }, isMobile),
              ...(_categories.isNotEmpty
                  ? _categories
                      .take(isMobile ? 3 : 4)
                      .map(
                        (category) => Padding(
                          padding: EdgeInsets.only(right: isMobile ? 6 : 8),
                          child: _buildQuickFilter(
                            category,
                            _selectedCategory == category,
                            () {
                              setState(() => _selectedCategory = category);
                              _loadTours(isRefresh: true);
                            },
                            isMobile,
                          ),
                        ),
                      )
                  : []),
              _buildMoreFiltersButton(isMobile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFilter(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isMobile,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(right: isMobile ? 6 : 8),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : colorScheme.surface,
            borderRadius: BorderRadius.circular(isMobile ? 18 : 20),
            border: Border.all(
              color:
                  isSelected
                      ? colorScheme.primary
                      : colorScheme.outline.withOpacity(0.3),
              width: 1,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: isMobile ? 13 : 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreFiltersButton(bool isMobile) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _toggleFilters();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color:
              _showFilters
                  ? colorScheme.primary.withOpacity(0.1)
                  : colorScheme.surface,
          borderRadius: BorderRadius.circular(isMobile ? 18 : 20),
          border: Border.all(
            color:
                _showFilters
                    ? colorScheme.primary.withOpacity(0.5)
                    : colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: isMobile ? 14 : 16,
              color: colorScheme.primary,
            ),
            SizedBox(width: isMobile ? 3 : 4),
            Text(
              'More',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: isMobile ? 13 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileFiltersPanel() {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Container(
      margin: EdgeInsets.fromLTRB(
        isMobile ? 12 : 16,
        0,
        isMobile ? 12 : 16,
        isMobile ? 12 : 16,
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters & Sort',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 18 : 20,
                ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: Icon(
                      Icons.clear_all_rounded,
                      size: isMobile ? 16 : 18,
                    ),
                    label: Text(
                      'Clear',
                      style: TextStyle(fontSize: isMobile ? 13 : 14),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.outline,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8 : 12,
                        vertical: isMobile ? 4 : 8,
                      ),
                    ),
                  ),
                  SizedBox(width: isMobile ? 4 : 8),
                  FilledButton.icon(
                    onPressed: _applyFilters,
                    icon: Icon(Icons.check_rounded, size: isMobile ? 16 : 18),
                    label: Text(
                      'Apply',
                      style: TextStyle(fontSize: isMobile ? 13 : 14),
                    ),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 16,
                        vertical: isMobile ? 4 : 8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 24),

          // Location and Activity in a row on mobile
          if (isMobile) ...[
            Row(
              children: [
                Expanded(
                  child: _buildMobileFilterSection(
                    'Location',
                    DropdownButton<String>(
                      value: _selectedLocation,
                      hint: const Text('Any location'),
                      isExpanded: true,
                      underline: const SizedBox(),
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Any location'),
                        ),
                        ..._locations.map(
                          (location) => DropdownMenuItem<String>(
                            value: location,
                            child: Text(location),
                          ),
                        ),
                      ],
                      onChanged:
                          (value) => setState(() => _selectedLocation = value),
                    ),
                    isMobile,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMobileFilterSection(
                    'Activity',
                    DropdownButton<String>(
                      value: _selectedActivityType,
                      hint: const Text('Any activity'),
                      isExpanded: true,
                      underline: const SizedBox(),
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Any activity'),
                        ),
                        ...['Indoor', 'Outdoor', 'Mixed'].map(
                          (type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          ),
                        ),
                      ],
                      onChanged:
                          (value) =>
                              setState(() => _selectedActivityType = value),
                    ),
                    isMobile,
                  ),
                ),
              ],
            ),
          ] else ...[
            // Desktop/tablet layout
            _buildFilterSection(
              'Location',
              DropdownButton<String>(
                value: _selectedLocation,
                hint: const Text('Any location'),
                isExpanded: true,
                underline: const SizedBox(),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Any location'),
                  ),
                  ..._locations.map(
                    (location) => DropdownMenuItem<String>(
                      value: location,
                      child: Text(location),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedLocation = value),
              ),
              isMobile,
            ),

            _buildFilterSection(
              'Activity Type',
              DropdownButton<String>(
                value: _selectedActivityType,
                hint: const Text('Any activity'),
                isExpanded: true,
                underline: const SizedBox(),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Any activity'),
                  ),
                  ...['Indoor', 'Outdoor', 'Mixed'].map(
                    (type) => DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    ),
                  ),
                ],
                onChanged:
                    (value) => setState(() => _selectedActivityType = value),
              ),
              isMobile,
            ),
          ],

          // Difficulty
          _buildFilterSection(
            'Difficulty',
            DropdownButton<String>(
              value: _selectedDifficulty,
              hint: const Text('Any difficulty'),
              isExpanded: true,
              underline: const SizedBox(),
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: colorScheme.onSurface,
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Any difficulty'),
                ),
                ...['Easy', 'Moderate', 'Challenging'].map(
                  (level) => DropdownMenuItem<String>(
                    value: level,
                    child: Text(level),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _selectedDifficulty = value),
            ),
            isMobile,
          ),

          // Price Range
          _buildFilterSection(
            'Price Range (\$)',
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildMobileNumberField(
                        'Min',
                        _minPrice?.toStringAsFixed(0) ?? '',
                        (value) => _minPrice = double.tryParse(value),
                        isMobile,
                      ),
                    ),
                    SizedBox(width: isMobile ? 8 : 16),
                    Expanded(
                      child: _buildMobileNumberField(
                        'Max',
                        _maxPrice?.toStringAsFixed(0) ?? '',
                        (value) => _maxPrice = double.tryParse(value),
                        isMobile,
                      ),
                    ),
                  ],
                ),
                if (isMobile && (_minPrice != null || _maxPrice != null)) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Range: ${_minPrice?.toStringAsFixed(0) ?? '0'} - ${_maxPrice?.toStringAsFixed(0) ?? '∞'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            isMobile,
          ),

          // Duration
          _buildFilterSection(
            'Duration (Days)',
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildMobileNumberField(
                        'Min',
                        _minDuration?.toString() ?? '',
                        (value) => _minDuration = int.tryParse(value),
                        isMobile,
                        isInt: true,
                      ),
                    ),
                    SizedBox(width: isMobile ? 8 : 16),
                    Expanded(
                      child: _buildMobileNumberField(
                        'Max',
                        _maxDuration?.toString() ?? '',
                        (value) => _maxDuration = int.tryParse(value),
                        isMobile,
                        isInt: true,
                      ),
                    ),
                  ],
                ),
                if (isMobile &&
                    (_minDuration != null || _maxDuration != null)) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Range: ${_minDuration ?? 'Any'} - ${_maxDuration ?? 'Any'} days',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            isMobile,
          ),

          // Sort
          _buildFilterSection(
            'Sort By',
            Column(
              children: [
                DropdownButton<String>(
                  value: _sortBy,
                  isExpanded: true,
                  underline: const SizedBox(),
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: colorScheme.onSurface,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'created',
                      child: Text('Newest First'),
                    ),
                    DropdownMenuItem(value: 'name', child: Text('Name')),
                    DropdownMenuItem(value: 'price', child: Text('Price')),
                    DropdownMenuItem(value: 'rating', child: Text('Rating')),
                    DropdownMenuItem(
                      value: 'duration',
                      child: Text('Duration'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _sortBy = value!),
                ),
                SizedBox(height: isMobile ? 6 : 8),
                InkWell(
                  onTap: () => setState(() => _sortAscending = !_sortAscending),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _sortAscending,
                          onChanged:
                              (value) =>
                                  setState(() => _sortAscending = value!),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        Text(
                          'Ascending order',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontSize: isMobile ? 14 : 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget child, bool isMobile) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withOpacity(0.8),
              fontSize: isMobile ? 14 : 16,
            ),
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10 : 12,
              vertical: isMobile ? 2 : 4,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFilterSection(String title, Widget child, bool isMobile) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withOpacity(0.8),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildMobileNumberField(
    String hint,
    String value,
    Function(String) onChanged,
    bool isMobile, {
    bool isInt = false,
  }) {
    return TextField(
      controller: TextEditingController(text: value),
      keyboardType:
          isInt
              ? TextInputType.number
              : const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(fontSize: isMobile ? 14 : 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: isMobile ? 14 : 16),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
      ),
      onChanged: onChanged,
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
            width: isMobile ? 60 : 80,
            height: isMobile ? 60 : 80,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
                strokeWidth: 3,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 20 : 24),
          Text(
            'Finding amazing experiences...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontSize: isMobile ? 16 : 18,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            'This won\'t take long',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
              fontSize: isMobile ? 13 : 14,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 18 : 20,
              ),
            ),
            SizedBox(height: isMobile ? 10 : 12),
            Text(
              _errorMessage ?? 'Failed to load experiences',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontSize: isMobile ? 14 : 16,
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
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 20 : 24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
              ),
              child: Icon(
                Icons.explore_off_rounded,
                size: isMobile ? 48 : 64,
                color: colorScheme.outline,
              ),
            ),
            SizedBox(height: isMobile ? 20 : 24),
            Text(
              'No experiences found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 18 : 20,
              ),
            ),
            SizedBox(height: isMobile ? 10 : 12),
            Text(
              'Try adjusting your search criteria or explore different categories',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontSize: isMobile ? 14 : 16,
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
    );
  }

  Widget _buildLoadingMoreCard(bool isMobile) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 2,
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              'Loading more...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontSize: isMobile ? 13 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTourCard(Tour tour, bool isMobile) {
    final colorScheme = Theme.of(context).colorScheme;

    return Hero(
      tag: 'tour_${tour.id}',
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        elevation: isMobile ? 3 : 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isMobile ? 14 : 16),
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        TourDetailsScreen(tourId: tour.id),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: animation.drive(
                        Tween(
                          begin: const Offset(0.03, 0.03),
                          end: Offset.zero,
                        ).chain(CurveTween(curve: Curves.easeOut)),
                      ),
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              Stack(
                children: [
                  Container(
                    height: isMobile ? 180 : 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                    ),
                    child:
                        tour.mainImageUrl != null &&
                                tour.mainImageUrl!.isNotEmpty
                            ? Image.network(
                              tour.mainImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      _buildImagePlaceholder(isMobile),
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        colorScheme.surfaceContainer,
                                        colorScheme.surfaceContainer
                                            .withOpacity(0.7),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                      strokeWidth: 2,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                );
                              },
                            )
                            : _buildImagePlaceholder(isMobile),
                  ),

                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Discount badge
                  if (tour.hasDiscount)
                    Positioned(
                      top: isMobile ? 10 : 12,
                      right: isMobile ? 10 : 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 6 : 8,
                          vertical: isMobile ? 3 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(
                            isMobile ? 10 : 12,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${tour.discountPercentage}% OFF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 10 : 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Rating badge
                  if (tour.averageRating != null)
                    Positioned(
                      bottom: isMobile ? 10 : 12,
                      left: isMobile ? 10 : 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 6 : 8,
                          vertical: isMobile ? 3 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(
                            isMobile ? 10 : 12,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: isMobile ? 12 : 14,
                            ),
                            SizedBox(width: isMobile ? 2 : 4),
                            Text(
                              tour.averageRating!.toStringAsFixed(1),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 10 : 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              ' (${tour.reviewCount})',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: isMobile ? 9 : 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Content section
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tour name
                      Text(
                        tour.name,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          fontSize: isMobile ? 15 : 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isMobile ? 6 : 8),

                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: isMobile ? 14 : 16,
                            color: colorScheme.primary,
                          ),
                          SizedBox(width: isMobile ? 3 : 4),
                          Expanded(
                            child: Text(
                              tour.location,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.7),
                                fontSize: isMobile ? 12 : 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 8 : 12),

                      // Details chips
                      Wrap(
                        spacing: isMobile ? 4 : 6,
                        runSpacing: isMobile ? 4 : 6,
                        children: [
                          _buildDetailChip(
                            icon: Icons.schedule_rounded,
                            label: tour.durationText,
                            backgroundColor: colorScheme.primaryContainer,
                            textColor: colorScheme.onPrimaryContainer,
                            isMobile: isMobile,
                          ),
                          _buildDetailChip(
                            icon: tour.activityIcon,
                            label: tour.activityType,
                            backgroundColor: colorScheme.secondaryContainer,
                            textColor: colorScheme.onSecondaryContainer,
                            isMobile: isMobile,
                          ),
                          _buildDetailChip(
                            icon: Icons.speed_rounded,
                            label: tour.difficultyLevel,
                            backgroundColor: tour.difficultyColor.withOpacity(
                              0.1,
                            ),
                            textColor: tour.difficultyColor,
                            isMobile: isMobile,
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Price and book button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (tour.hasDiscount)
                                  Text(
                                    tour.originalPrice,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      color: colorScheme.onSurface.withOpacity(
                                        0.6,
                                      ),
                                      fontSize: isMobile ? 11 : 12,
                                    ),
                                  ),
                                Text(
                                  tour.displayPrice,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isMobile ? 18 : 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: isMobile ? 8 : 12),
                          FilledButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => TourDetailsScreen(tourId: tour.id),
                                  transitionsBuilder: (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                  transitionDuration: const Duration(
                                    milliseconds: 300,
                                  ),
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 14 : 16,
                                vertical: isMobile ? 6 : 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  isMobile ? 10 : 12,
                                ),
                              ),
                            ),
                            child: Text(
                              'Book Now',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isMobile ? 13 : 14,
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
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(bool isMobile) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.landscape_rounded,
              size: isMobile ? 40 : 48,
              color: colorScheme.outline,
            ),
            SizedBox(height: isMobile ? 6 : 8),
            Text(
              'Image not available',
              style: TextStyle(
                color: colorScheme.outline,
                fontSize: isMobile ? 11 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 8,
        vertical: isMobile ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isMobile ? 10 : 12, color: textColor),
          SizedBox(width: isMobile ? 2 : 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 10 : 11,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
