import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for HapticFeedback
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

  List<String> _categories = [];
  List<String> _locations = [];

  late AnimationController _fabAnimationController;
  late AnimationController _filterAnimationController;
  late Animation<double> _fabAnimation;
  late Animation<double> _filterAnimation;

  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeOut),
    );
    _filterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _filterAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _fabAnimationController.forward();
    _loadTours();
    _loadFilterOptions();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _filterAnimationController.dispose();
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
        pageSize: 10, // Number of items per page
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
        pageSize: 10,
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
        _currentPage--; // Revert page increment on error
        // Optionally show a message if loading more fails
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
      // Handle error silently for filter options, or show a subtle message
      debugPrint("Error loading filter options: $e");
    }
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });

    if (_showFilters) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
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
      _sortBy = 'created';
      _sortAscending = false;
      _searchController.clear(); // Also clear search term
    });
    _loadTours(isRefresh: true);
  }

  void _applyFilters() {
    _toggleFilters(); // Close the filter panel
    _loadTours(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            floating: true, // Makes app bar appear on scroll up
            snap: true, // Snaps app bar into view
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Discover Tours',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
              centerTitle: true,
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
              ),
            ),
            actions: [
              IconButton(
                onPressed: _toggleFilters,
                icon: Icon(
                  Icons.filter_list_rounded,
                  color: colorScheme.onPrimary,
                ),
                tooltip: 'Filters',
              ),
            ],
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CustomSearchField(
                controller: _searchController,
                hint: 'Search tours, locations, activities...',
                onSubmitted: (_) => _loadTours(isRefresh: true),
                onChanged: (value) {
                  // Debounce search or search on submit
                  if (value.isEmpty && _searchController.text.isNotEmpty) {
                    _loadTours(isRefresh: true);
                  }
                },
              ),
            ),
          ),

          // Filters Panel
          if (_showFilters)
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _filterAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.5),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _filterAnimationController,
                      curve: Curves.easeInOutCubic,
                    ),
                  ),
                  child: _buildFiltersPanel(),
                ),
              ),
            ),

          // Results Count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                _isLoading ? 'Loading...' : '$_totalCount tours found',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Tours Grid/List
          if (_isLoading && _tours.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Loading tours...',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 70,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Oops! Something went wrong.',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _loadTours(isRefresh: true),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_tours.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 80,
                      color: colorScheme.outline.withOpacity(0.7),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No Tours Found',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your search or filters.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (_selectedCategory != null ||
                        _selectedLocation != null ||
                        _searchController
                            .text
                            .isNotEmpty) // Show clear filters if any filter is active
                      ElevatedButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.clear_all_rounded),
                        label: const Text('Clear Filters'),
                      ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                16,
              ), // Adjusted padding
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio:
                      isDesktop
                          ? 0.9
                          : (isTablet ? 0.85 : 0.95), // Adjusted aspect ratio
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index < _tours.length) {
                    return _buildTourCard(_tours[index]);
                  } else if (_isLoadingMore) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return null; // Should not happen
                }, childCount: _tours.length + (_isLoadingMore ? 1 : 0)),
              ),
            ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: () => _loadTours(isRefresh: true),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Refresh'),
          backgroundColor:
              colorScheme.secondary, // Changed to secondary for contrast
          foregroundColor: colorScheme.onSecondary,
        ),
      ),
    );
  }

  Widget _buildFiltersPanel() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16), // Consistent margin
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            colorScheme
                .surfaceContainer, // Slightly different background for filters
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 15,
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
                'Filters',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear_all_rounded, size: 20),
                label: const Text('Clear All'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Category Filter
          _buildDropdownFilter(
            'Category',
            _selectedCategory,
            _categories,
            (value) => setState(() => _selectedCategory = value),
            Icons.category_rounded,
          ),
          const SizedBox(height: 16),

          // Location Filter
          _buildDropdownFilter(
            'Location',
            _selectedLocation,
            _locations,
            (value) => setState(() => _selectedLocation = value),
            Icons.location_city_rounded,
          ),
          const SizedBox(height: 16),

          // Difficulty Filter
          _buildDropdownFilter(
            'Difficulty',
            _selectedDifficulty,
            TourService.difficultyLevels,
            (value) => setState(() => _selectedDifficulty = value),
            Icons.speed_rounded,
          ),
          const SizedBox(height: 16),

          // Activity Type Filter
          _buildDropdownFilter(
            'Activity Type',
            _selectedActivityType,
            TourService.activityTypes,
            (value) => setState(() => _selectedActivityType = value),
            Icons.directions_walk_rounded,
          ),
          const SizedBox(height: 16),

          // Price Range
          Text(
            'Price Range',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: TextEditingController(
                    text: _minPrice?.toStringAsFixed(0) ?? '',
                  ),
                  label: 'Min Price',
                  prefixIcon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _minPrice = double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller: TextEditingController(
                    text: _maxPrice?.toStringAsFixed(0) ?? '',
                  ),
                  label: 'Max Price',
                  prefixIcon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _maxPrice = double.tryParse(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sort Options
          _buildDropdownFilter(
            'Sort By',
            _sortBy,
            TourService.sortOptions
                .map((s) => s[0].toUpperCase() + s.substring(1))
                .toList(), // Capitalize
            (value) => setState(
              () => _sortBy = value!.toLowerCase(),
            ), // Store lowercase
            Icons.sort_by_alpha_rounded,
            showClearOption: false,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: _sortAscending,
                onChanged: (value) {
                  setState(() => _sortAscending = value ?? false);
                },
                activeColor: colorScheme.primary,
              ),
              Text(
                'Ascending order',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Apply Filters Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _applyFilters,
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Apply Filters'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(
    String label,
    String? value,
    List<String> options,
    Function(String?) onChanged,
    IconData icon, {
    bool showClearOption = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final allOptions =
        showClearOption ? [null, ...options] : options; // Use null for 'All'

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color:
                colorScheme
                    .surfaceContainerHighest, // Slightly different background
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: colorScheme.primary,
              ),
              dropdownColor: colorScheme.surfaceContainerHighest,
              items:
                  allOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(
                        option ?? 'All', // Display 'All' if option is null
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    );
                  }).toList(),
              onChanged: onChanged, // Directly use the passed onChanged
            ),
          ),
        ),
      ],
    );
  }

  // --- Updated Tour Card Widget ---
  Widget _buildTourCard(Tour tour) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior:
          Clip.antiAlias, // Ensures content respects card's rounded corners
      elevation: 3, // Subtle shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // More rounded corners
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact(); // Add haptic feedback
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TourDetailsScreen(tourId: tour.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Make children stretch
          children: [
            // Image Section
            SizedBox(
              height: 150, // Adjusted image height
              child: Stack(
                fit: StackFit.expand,
                children: [
                  tour.mainImageUrl != null && tour.mainImageUrl!.isNotEmpty
                      ? Image.network(
                        tour.mainImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                _buildImagePlaceholder(colorScheme),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                              strokeWidth: 2,
                            ),
                          );
                        },
                      )
                      : _buildImagePlaceholder(colorScheme),
                  // Gradient overlay for text on image
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.6),
                        ],
                        stops: const [0.5, 0.7, 1.0],
                      ),
                    ),
                  ),
                  // Discount Badge
                  if (tour.hasDiscount)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${tour.discountPercentage}% OFF',
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Rating Badge
                  if (tour.averageRating != null && tour.averageRating! > 0)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tour.averageRating!.toStringAsFixed(1),
                              style: textTheme.labelMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content Section
            Padding(
              padding: const EdgeInsets.all(12.0), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tour Name
                  Text(
                    tour.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          tour.location,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Tour Details Chips (Duration, Activity, Difficulty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildCompactDetailChip(
                        icon: Icons.access_time_rounded,
                        label: tour.durationText,
                        colorScheme: colorScheme,
                      ),
                      _buildCompactDetailChip(
                        icon: tour.activityIcon,
                        label: tour.activityType,
                        colorScheme: colorScheme,
                      ),
                      _buildCompactDetailChip(
                        icon:
                            Icons
                                .speed_rounded, // Using a consistent icon for difficulty
                        label: tour.difficultyLevel,
                        chipColor: tour.difficultyColor.withOpacity(
                          0.15,
                        ), // Use tour's difficulty color
                        textColor: tour.difficultyColor,
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10), // Spacer
                  // Price and Book Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Align items vertically
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (tour.hasDiscount)
                            Text(
                              tour.originalPrice,
                              style: textTheme.labelSmall?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: colorScheme.onSurfaceVariant.withOpacity(
                                  0.7,
                                ),
                              ),
                            ),
                          Text(
                            tour.displayPrice,
                            style: textTheme.titleLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      TourDetailsScreen(tourId: tour.id),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          textStyle: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ).copyWith(
                          backgroundColor: MaterialStateProperty.all(
                            colorScheme.primary,
                          ),
                          foregroundColor: MaterialStateProperty.all(
                            colorScheme.onPrimary,
                          ),
                        ),
                        child: const Text('Book'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest, // Use a theme color
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 50,
          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildCompactDetailChip({
    required IconData icon,
    required String label,
    required ColorScheme colorScheme,
    Color? chipColor, // Optional custom chip color
    Color? textColor, // Optional custom text color
  }) {
    return Chip(
      avatar: Icon(
        icon,
        size: 14,
        color: textColor ?? colorScheme.onSecondaryContainer.withOpacity(0.8),
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor ?? colorScheme.onSecondaryContainer,
        ),
      ),
      backgroundColor:
          chipColor ?? colorScheme.secondaryContainer.withOpacity(0.7),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      labelPadding: const EdgeInsets.only(left: 2, right: 4), // Adjust padding
      materialTapTargetSize:
          MaterialTapTargetSize.shrinkWrap, // Make chip smaller
      visualDensity: VisualDensity.compact,
    );
  }
}
