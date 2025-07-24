import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/tour_models.dart';
import '../../services/tour_service.dart';
import '../../widgets/unified_list_screen.dart';
import '../../widgets/unified_filter_system.dart';
import 'tour_details_screen_new.dart';

class TourListScreenUnified extends StatelessWidget {
  const TourListScreenUnified({super.key});

  @override
  Widget build(BuildContext context) {
    return UnifiedListScreen<Tour, TourFilterRequest>(
      config: TourListScreenConfig(),
    );
  }
}

class TourListScreenConfig extends UnifiedListScreenConfig<Tour, TourFilterRequest> {
  final TourService _tourService = TourService();
  List<String> _categories = [];
  List<String> _locations = [];
  List<Tour> _favoriteToursLocal = [];

  @override
  String get screenTitle => 'Discover Amazing Tours';

  @override
  String get screenSubtitle => 'Find your perfect adventure';

  @override
  IconData get screenIcon => Icons.explore_rounded;

  @override
  String get itemTypeSingular => 'tour';

  @override
  String get itemTypePlural => 'tours';

  @override
  String get searchHint => 'Where would you like to explore?';

  @override
  String get emptyStateTitle => 'No tours found';

  @override
  String get emptyStateSubtitle => 'Try adjusting your search criteria or filters';

  @override
  String get loadingMessage => 'Finding amazing tours for you...';

  @override
  Future<PagedResult<Tour>> loadItems(TourFilterRequest filter) async {
    final result = await _tourService.getTours(filter: filter);
    return PagedResult(
      items: result.items,
      hasNextPage: result.hasNextPage,
      totalCount: result.totalCount,
    );
  }

  @override
  Future<List<String>> loadFilterOptions(String filterType) async {
    switch (filterType) {
      case 'categories':
        if (_categories.isEmpty) {
          _categories = await _tourService.getCategories();
        }
        return _categories;
      case 'locations':
        if (_locations.isEmpty) {
          _locations = await _tourService.getLocations();
        }
        return _locations;
      default:
        return [];
    }
  }

  @override
  TourFilterRequest createFilter({
    String? searchTerm,
    Map<String, dynamic>? filters,
    String sortBy = 'created',
    bool ascending = false,
    int pageIndex = 1,
    int pageSize = 12,
  }) {
    return TourFilterRequest(
      searchTerm: searchTerm,
      category: filters?['category'] ?? filters?['category'],
      location: filters?['location'],
      difficultyLevel: filters?['difficulty'],
      activityType: filters?['activityType'],
      minPrice: filters?['minPrice']?.toDouble(),
      maxPrice: filters?['maxPrice']?.toDouble(),
      minDuration: filters?['minDuration']?.round(),
      maxDuration: filters?['maxDuration']?.round(),
      sortBy: sortBy,
      ascending: ascending,
      pageIndex: pageIndex,
      pageSize: pageSize,
    );
  }

  @override
  List<QuickFilterOption> get quickFilterOptions => [
    const QuickFilterOption(label: 'Adventure', value: 'Adventure'),
    const QuickFilterOption(label: 'Cultural', value: 'Cultural'),
    const QuickFilterOption(label: 'Nature', value: 'Nature'),
    const QuickFilterOption(label: 'Food & Wine', value: 'Food & Wine'),
    const QuickFilterOption(label: 'Historical', value: 'Historical'),
  ];

  @override
  List<Widget> buildFilterSections(
    BuildContext context,
    Map<String, dynamic> currentFilters,
    Function(String, dynamic) onFilterChanged,
  ) {
    return [
      _buildCategoryLocationFilter(context, currentFilters, onFilterChanged),
      _buildDifficultyActivityFilter(context, currentFilters, onFilterChanged),
      _buildPriceRangeFilter(context, currentFilters, onFilterChanged),
      _buildDurationFilter(context, currentFilters, onFilterChanged),
      _buildSortFilter(context, currentFilters, onFilterChanged),
    ];
  }

  Widget _buildCategoryLocationFilter(
    BuildContext context,
    Map<String, dynamic> currentFilters,
    Function(String, dynamic) onFilterChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: UnifiedDropdownFilter(
            title: 'Category',
            currentValue: currentFilters['category'],
            options: ['Any Category', ..._categories],
            defaultOption: 'Any Category',
            onChanged: (value) => onFilterChanged('category', value),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: UnifiedDropdownFilter(
            title: 'Location',
            currentValue: currentFilters['location'],
            options: ['Any Location', ..._locations],
            defaultOption: 'Any Location',
            onChanged: (value) => onFilterChanged('location', value),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyActivityFilter(
    BuildContext context,
    Map<String, dynamic> currentFilters,
    Function(String, dynamic) onFilterChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: UnifiedDropdownFilter(
            title: 'Difficulty',
            currentValue: currentFilters['difficulty'],
            options: ['Any Difficulty', 'Easy', 'Moderate', 'Challenging'],
            defaultOption: 'Any Difficulty',
            onChanged: (value) => onFilterChanged('difficulty', value),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: UnifiedDropdownFilter(
            title: 'Activity Type',
            currentValue: currentFilters['activityType'],
            options: ['Any Activity', 'Indoor', 'Outdoor', 'Mixed'],
            defaultOption: 'Any Activity',
            onChanged: (value) => onFilterChanged('activityType', value),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRangeFilter(
    BuildContext context,
    Map<String, dynamic> currentFilters,
    Function(String, dynamic) onFilterChanged,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final priceRange = RangeValues(
      currentFilters['minPrice']?.toDouble() ?? 0,
      currentFilters['maxPrice']?.toDouble() ?? 2000,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Price Range',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '\$${priceRange.start.round()} - \$${priceRange.end.round()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: priceRange,
          min: 0,
          max: 2000,
          divisions: 40,
          labels: RangeLabels(
            '\$${priceRange.start.round()}',
            '\$${priceRange.end.round()}',
          ),
          onChanged: (values) {
            onFilterChanged('minPrice', values.start);
            onFilterChanged('maxPrice', values.end);
          },
        ),
      ],
    );
  }

  Widget _buildDurationFilter(
    BuildContext context,
    Map<String, dynamic> currentFilters,
    Function(String, dynamic) onFilterChanged,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final durationRange = RangeValues(
      currentFilters['minDuration']?.toDouble() ?? 1,
      currentFilters['maxDuration']?.toDouble() ?? 14,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Duration (Days)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${durationRange.start.round()} - ${durationRange.end.round()} days',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: durationRange,
          min: 1,
          max: 14,
          divisions: 13,
          labels: RangeLabels(
            '${durationRange.start.round()}d',
            '${durationRange.end.round()}d',
          ),
          onChanged: (values) {
            onFilterChanged('minDuration', values.start.round());
            onFilterChanged('maxDuration', values.end.round());
          },
        ),
      ],
    );
  }

  Widget _buildSortFilter(
    BuildContext context,
    Map<String, dynamic> currentFilters,
    Function(String, dynamic) onFilterChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: UnifiedDropdownFilter(
            title: 'Sort By',
            currentValue: currentFilters['sortBy'] ?? 'created',
            options: ['created', 'name', 'price', 'rating', 'duration'],
            defaultOption: 'created',
            onChanged: (value) => onFilterChanged('sortBy', value),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort Order',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: currentFilters['ascending'] ?? false,
                    onChanged: (value) => onFilterChanged('ascending', value),
                  ),
                  const Text('Ascending'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _toggleFavorite(Tour tour) {
    if (_favoriteToursLocal.any((t) => t.id == tour.id)) {
      _favoriteToursLocal.removeWhere((t) => t.id == tour.id);
    } else {
      _favoriteToursLocal.add(tour);
    }
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
  Widget buildItemCard(BuildContext context, Tour tour, int index, bool isMobile, bool isTablet, bool isDesktop) {
    return _buildTourCard(context, tour, isDesktop, isTablet);
  }

  @override
  void onItemTapped(BuildContext context, Tour tour) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TourDetailsScreenNew(tourId: tour.id),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Widget _buildTourCard(BuildContext context, Tour tour, bool isDesktop, bool isTablet) {
    final colorScheme = Theme.of(context).colorScheme;

    return Hero(
      tag: 'tour_${tour.id}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: isDesktop ? 12 : 6,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 24 : 20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced image section with smooth loading
            Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: isDesktop ? 260 : (isTablet ? 240 : 220),
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
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(isDesktop ? 24 : 20),
                            topRight: Radius.circular(isDesktop ? 24 : 20),
                          ),
                          child: Image.network(
                            tour.mainImageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return AnimatedOpacity(
                                  opacity: 1.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: child,
                                );
                              }
                              return Container(
                                color: colorScheme.surfaceContainer,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                _buildImagePlaceholder(context, isDesktop),
                          ),
                        )
                      : _buildImagePlaceholder(context, isDesktop),
                ),

                // Enhanced gradient overlay
                Container(
                  height: isDesktop ? 260 : (isTablet ? 240 : 220),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isDesktop ? 24 : 20),
                      topRight: Radius.circular(isDesktop ? 24 : 20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.4),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),

                // Enhanced rating badge with animation
                if (tour.averageRating != null)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tour.averageRating!.toStringAsFixed(1),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isDesktop ? 14 : 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Enhanced favorite button with haptic feedback
                Positioned(
                  top: 16,
                  right: 16,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _toggleFavorite(tour);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              _isFavorite(tour)
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              key: ValueKey(_isFavorite(tour)),
                              color: _isFavorite(tour) ? Colors.red : Colors.white,
                              size: isDesktop ? 22 : 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Enhanced duration badge
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${tour.durationInDays} day${tour.durationInDays != 1 ? 's' : ''}',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: isDesktop ? 13 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Enhanced content section
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 24 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enhanced category badge
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tour.category.toUpperCase(),
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: isDesktop ? 11 : 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Enhanced tour name
                    Flexible(
                      child: Text(
                        tour.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          fontSize: isDesktop ? 20 : 18,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Enhanced location with smooth icon
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: colorScheme.primary,
                          size: isDesktop ? 18 : 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            tour.location,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                              fontSize: isDesktop ? 15 : 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Enhanced features preview with animations
                    if (tour.features.isNotEmpty) ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: tour.features.take(3).map((feature) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondaryContainer.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getFeatureIcon(feature.name),
                                      size: 14,
                                      color: colorScheme.onSecondaryContainer,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      feature.name,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSecondaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const Spacer(),

                    // Enhanced rating display
                    if (tour.averageRating != null && tour.reviewCount != null) ...[
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            final rating = tour.averageRating!;
                            if (index < rating.floor()) {
                              return Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: isDesktop ? 18 : 16,
                              );
                            } else if (index < rating) {
                              return Icon(
                                Icons.star_half_rounded,
                                color: Colors.amber,
                                size: isDesktop ? 18 : 16,
                              );
                            } else {
                              return Icon(
                                Icons.star_outline_rounded,
                                color: colorScheme.outline,
                                size: isDesktop ? 18 : 16,
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
                      const SizedBox(height: 16),
                    ],

                    // Enhanced pricing section
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
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: isDesktop ? 15 : 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${tour.discountPercentage ?? 0}% OFF',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isDesktop ? 11 : 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${tour.discountedPrice!.toStringAsFixed(0)}',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isDesktop ? 28 : 24,
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  '\$${tour.price.toStringAsFixed(0)}',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isDesktop ? 28 : 24,
                                  ),
                                ),
                              ],
                              Text(
                                'per person',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  fontSize: isDesktop ? 13 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Enhanced difficulty and activity badges
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: tour.difficultyColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: tour.difficultyColor.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                tour.difficultyLevel,
                                style: TextStyle(
                                  fontSize: isDesktop ? 12 : 11,
                                  fontWeight: FontWeight.w700,
                                  color: tour.difficultyColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  tour.activityIcon,
                                  size: isDesktop ? 14 : 12,
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tour.activityType,
                                  style: TextStyle(
                                    fontSize: isDesktop ? 12 : 11,
                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                    fontWeight: FontWeight.w500,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context, bool isDesktop) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: isDesktop ? 260 : 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isDesktop ? 24 : 20),
          topRight: Radius.circular(isDesktop ? 24 : 20),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.1),
            colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isDesktop ? 24 : 20),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.image_not_supported_rounded,
                size: isDesktop ? 56 : 48,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: isDesktop ? 16 : 12),
            Text(
              'Image not available',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: isDesktop ? 16 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}