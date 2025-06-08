import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/tour_models.dart';
import '../../services/tour_service.dart';
import '../../utils/layout_utils.dart';
import 'tour_details_screen_new.dart';

class TourListScreenNew extends StatefulWidget {
  const TourListScreenNew({super.key});

  @override
  State<TourListScreenNew> createState() => _TourListScreenNewState();
}

class _TourListScreenNewState extends State<TourListScreenNew>
    with TickerProviderStateMixin {
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
  bool _isSearchFocused = false;

  late AnimationController _filterController;
  late AnimationController _listController;
  late Animation<double> _filterFadeAnimation;
  late Animation<double> _listAnimation;

  @override
  void initState() {
    super.initState();
    _filterController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _listController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _filterFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _filterController, curve: Curves.easeIn));

    _listAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _listController, curve: Curves.easeOutCubic),
    );

    _loadTours();
    _loadFilterOptions();
    _scrollController.addListener(_onScroll);

    _listController.forward();
  }

  @override
  void dispose() {
    _filterController.dispose();
    _listController.dispose();
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
    HapticFeedback.lightImpact();
    setState(() {
      _showFilters = !_showFilters;
    });

    if (_showFilters) {
      _filterController.forward();
    } else {
      _filterController.reverse();
    }
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

  IconData _getFeatureIcon(String featureName) {
    final name = featureName.toLowerCase();
    if (name.contains('guide')) return Icons.person_rounded;
    if (name.contains('transport')) return Icons.directions_bus_rounded;
    if (name.contains('meal') || name.contains('food')) return Icons.restaurant_rounded;
    if (name.contains('hotel') || name.contains('accommodation')) return Icons.hotel_rounded;
    if (name.contains('ticket') || name.contains('entry')) return Icons.confirmation_number_rounded;
    if (name.contains('wifi')) return Icons.wifi_rounded;
    if (name.contains('photo')) return Icons.camera_alt_rounded;
    if (name.contains('group') || name.contains('small')) return Icons.group_rounded;
    if (name.contains('equipment')) return Icons.build_rounded;
    if (name.contains('insurance')) return Icons.security_rounded;
    return Icons.check_circle_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () => _loadTours(isRefresh: true),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
            // Modern App Bar
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Discover Amazing Tours',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge
                                          ?.copyWith(
                                            color: colorScheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _totalCount > 0
                                          ? '$_totalCount adventures await you'
                                          : 'Find your perfect adventure',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: colorScheme.onPrimary
                                                .withValues(alpha: 0.9),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.onPrimary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.explore_rounded,
                                  color: colorScheme.onPrimary,
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
            ),

            // Search Section
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _listAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -30 * (1 - _listAnimation.value)),
                    child: Opacity(
                      opacity: _listAnimation.value,
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _buildSearchSection(colorScheme),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Filters Panel
            if (_showFilters)
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _filterFadeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -20 * (1 - _filterFadeAnimation.value)),
                      child: Opacity(
                        opacity: _filterFadeAnimation.value,
                        child: _buildFiltersPanel(colorScheme),
                      ),
                    );
                  },
                ),
              ),

            // Quick Stats
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _isLoading
                            ? 'Loading tours...'
                            : '$_totalCount tours found',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    if (!_isLoading && _tours.isNotEmpty)
                      Row(
                        children: [
                          IconButton(
                            onPressed: _toggleFilters,
                            icon: AnimatedRotation(
                              turns: _showFilters ? 0.5 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                Icons.tune_rounded,
                                color: colorScheme.primary,
                              ),
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Content
            if (_isLoading && _tours.isEmpty)
              SliverFillRemaining(child: _buildLoadingState(colorScheme))
            else if (_errorMessage != null)
              SliverFillRemaining(child: _buildErrorState(colorScheme))
            else if (_tours.isEmpty)
              SliverFillRemaining(child: _buildEmptyState(colorScheme))
            else
              _buildToursGrid(isDesktop, isTablet, colorScheme),
          ],
        ),
      );
  }

  Widget _buildSearchSection(ColorScheme colorScheme) {
    return Column(
      children: [
        // Search bar
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isSearchFocused = hasFocus;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isSearchFocused
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.2),
                width: _isSearchFocused ? 2 : 1,
              ),
              boxShadow: _isSearchFocused
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: ValueListenableBuilder<bool>(
              valueListenable: _isSearching,
              builder: (context, isSearching, _) {
                return TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Where would you like to explore?',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    prefixIcon: isSearching
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
                            color: _isSearchFocused
                                ? colorScheme.primary
                                : colorScheme.outline,
                          ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            icon: Icon(
                              Icons.clear_rounded,
                              color: colorScheme.outline,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Quick filter chips
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildQuickFilter(
                'All',
                _selectedCategory == null,
                () {
                  setState(() => _selectedCategory = null);
                  _loadTours(isRefresh: true);
                },
                colorScheme,
              ),
              const SizedBox(width: 8),
              ...(_categories.take(5).map(
                (category) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildQuickFilter(
                    category,
                    _selectedCategory == category,
                    () {
                      setState(() => _selectedCategory = category);
                      _loadTours(isRefresh: true);
                    },
                    colorScheme,
                  ),
                ),
              )),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _buildMoreFiltersButton(colorScheme),
              ),
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
    ColorScheme colorScheme,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
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
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreFiltersButton(ColorScheme colorScheme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _toggleFilters();
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _showFilters
                ? colorScheme.primary.withValues(alpha: 0.1)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _showFilters
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: _showFilters ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedRotation(
                turns: _showFilters ? 0.25 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.tune_rounded,
                  size: 16,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _showFilters ? 'Hide Filters' : 'More Filters',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersPanel(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          _buildFiltersContent(),
        ],
      ),
    );
  }

  Widget _buildFiltersContent() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildFilterDropdown('Location', _selectedLocation, [
          'Any Location',
          ..._locations
        ], (value) => setState(() => _selectedLocation = value)),
        _buildFilterDropdown('Activity Type', _selectedActivityType, [
          'Any Activity',
          'Indoor',
          'Outdoor',
          'Mixed'
        ], (value) => setState(() => _selectedActivityType = value)),
        _buildFilterDropdown('Difficulty', _selectedDifficulty, [
          'Any Difficulty',
          'Easy',
          'Moderate',
          'Challenging'
        ], (value) => setState(() => _selectedDifficulty = value)),
        _buildFilterDropdown('Sort By', _sortBy, [
          'created',
          'name',
          'price',
          'rating',
          'duration',
        ], (value) => setState(() => _sortBy = value!)),
      ],
    );
  }

  Widget _buildFilterDropdown(
    String title,
    String? currentValue,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: currentValue ?? options.first,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: options.map((option) {
              return DropdownMenuItem(value: option, child: Text(option));
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildToursGrid(bool isDesktop, bool isTablet, ColorScheme colorScheme) {
    final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);
    final childAspectRatio = isDesktop ? 0.7 : (isTablet ? 0.75 : 0.95);

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index < _tours.length) {
              return _buildModernTourCard(_tours[index], isDesktop, isTablet, colorScheme);
            } else if (_isLoadingMore) {
              return _buildLoadingMoreCard(colorScheme);
            }
            return null;
          },
          childCount: _tours.length + (_isLoadingMore ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildModernTourCard(Tour tour, bool isDesktop, bool isTablet, ColorScheme colorScheme) {
    return Hero(
      tag: 'tour_${tour.id}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: isDesktop ? 8 : 4,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).push(
                LayoutUtils.createLayoutRoute(
                  child: TourDetailsScreenNew(tourId: tour.id),
                  context: context,
                  currentIndex: 0,
                  isAdmin: false,
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section - made larger
                Stack(
                  children: [
                    Container(
                      height: isDesktop ? 240 : (isTablet ? 220 : 200),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.surfaceContainer,
                            colorScheme.surfaceContainer.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                      child: tour.mainImageUrl != null && tour.mainImageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              child: Image.network(
                                tour.mainImageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildImagePlaceholder(colorScheme),
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                      strokeWidth: 2,
                                      color: colorScheme.primary,
                                    ),
                                  );
                                },
                              ),
                            )
                          : _buildImagePlaceholder(colorScheme),
                    ),

                    // Gradient overlay
                    Container(
                      height: isDesktop ? 240 : (isTablet ? 220 : 200),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),

                    // Rating badge
                    if (tour.averageRating != null)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tour.averageRating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Favorite button
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _toggleFavorite(tour);
                          },
                          icon: Icon(
                            _isFavorite(tour)
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _isFavorite(tour) ? Colors.red : Colors.white,
                            size: 20,
                          ),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ),

                    // Duration badge
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${tour.durationInDays} day${tour.durationInDays != 1 ? 's' : ''}',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Content section
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isDesktop ? 20 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tour.category.toUpperCase(),
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Tour name
                        Text(
                          tour.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            fontSize: isDesktop ? 18 : 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: colorScheme.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                tour.location,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                                  fontSize: isDesktop ? 14 : 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Price and additional details
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Rating and reviews count
                            if (tour.averageRating != null && tour.reviewCount != null) ...[
                              Row(
                                children: [
                                  ...List.generate(5, (index) {
                                    final rating = tour.averageRating!;
                                    if (index < rating.floor()) {
                                      return Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber,
                                        size: 16,
                                      );
                                    } else if (index < rating) {
                                      return Icon(
                                        Icons.star_half_rounded,
                                        color: Colors.amber,
                                        size: 16,
                                      );
                                    } else {
                                      return Icon(
                                        Icons.star_outline_rounded,
                                        color: colorScheme.outline,
                                        size: 16,
                                      );
                                    }
                                  }),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${tour.averageRating!.toStringAsFixed(1)} (${tour.reviewCount} reviews)',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                            
                            // Features preview
                            if (tour.features.isNotEmpty) ...[
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: tour.features.take(2).map((feature) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getFeatureIcon(feature.name),
                                          size: 12,
                                          color: colorScheme.onSecondaryContainer,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          feature.name,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: colorScheme.onSecondaryContainer,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                            ],
                            
                            // Pricing information
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (tour.discountedPrice != null && tour.discountedPrice! < tour.price) ...[
                                        Row(
                                          children: [
                                            Text(
                                              '\$${tour.price.toStringAsFixed(0)}',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: colorScheme.onSurface.withValues(alpha: 0.5),
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '${tour.discountPercentage ?? 0}% OFF',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '\$${tour.discountedPrice!.toStringAsFixed(0)}',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: isDesktop ? 24 : 20,
                                          ),
                                        ),
                                      ] else ...[
                                        Text(
                                          '\$${tour.price.toStringAsFixed(0)}',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: isDesktop ? 24 : 20,
                                          ),
                                        ),
                                      ],
                                      Text(
                                        'per person',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Difficulty and activity type badges
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: tour.difficultyColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: tour.difficultyColor.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Text(
                                        tour.difficultyLevel,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: tour.difficultyColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          tour.activityIcon,
                                          size: 12,
                                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          tour.activityType,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
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
      ),
    );
  }

  Widget _buildImagePlaceholder(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_rounded,
              size: 48,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'No image',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMoreCard(ColorScheme colorScheme) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 2,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading more tours...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                CircularProgressIndicator(
                  color: colorScheme.primary,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 24),
                Text(
                  'Finding amazing tours...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  shape: BoxShape.circle,
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
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? 'Failed to load tours',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear_all_rounded),
                    label: const Text('Clear Filters'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: () => _loadTours(isRefresh: true),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    final hasActiveFilters = _selectedCategory != null ||
        _selectedLocation != null ||
        _selectedDifficulty != null ||
        _selectedActivityType != null ||
        _searchController.text.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                hasActiveFilters
                    ? 'Try adjusting your search criteria or filters'
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
                      label: const Text('Clear Filters'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: _toggleFilters,
                      icon: const Icon(Icons.tune_rounded),
                      label: const Text('Adjust Filters'),
                    ),
                  ],
                ),
              ] else ...[
                FilledButton.icon(
                  onPressed: () => _loadTours(isRefresh: true),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Refresh'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}