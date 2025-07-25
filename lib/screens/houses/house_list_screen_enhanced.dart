import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/house_models.dart';
import '../../services/house_service.dart';
import '../../widgets/enhanced_unified_list_screen.dart';
import '../../widgets/unified_filter_system.dart';
import '../../widgets/animated_card.dart';
import '../../utils/animation_utils.dart';
import 'house_detail_screen.dart';

class HouseListScreenEnhanced extends StatelessWidget {
  const HouseListScreenEnhanced({super.key});

  @override
  Widget build(BuildContext context) {
    return EnhancedUnifiedListScreen<House, HouseFilterRequest>(
      config: HouseListScreenConfig(),
    );
  }
}

class HouseListScreenConfig
    extends UnifiedListScreenConfig<House, HouseFilterRequest> {
  final HouseService _houseService = HouseService();
  List<String> _propertyTypes = [];
  List<String> _popularDestinations = [];

  @override
  String get screenTitle => 'Find Your Perfect Stay';

  @override
  String get screenSubtitle => 'Discover amazing accommodations';

  @override
  IconData get screenIcon => Icons.home_rounded;

  @override
  String get itemTypeSingular => 'property';

  @override
  String get itemTypePlural => 'accommodations';

  @override
  String get searchHint => 'Search destinations, properties...';

  @override
  String get emptyStateTitle => 'No accommodations found';

  @override
  String get emptyStateSubtitle =>
      'Try adjusting your filters to find more options';

  @override
  String get loadingMessage => 'Finding perfect accommodations for you...';

  @override
  Future<PagedResult<House>> loadItems(HouseFilterRequest filter) async {
    final result = await _houseService.getHouses(filter: filter);
    return PagedResult(
      items: result.items,
      hasNextPage: result.hasNextPage,
      totalCount: result.totalCount,
    );
  }

  @override
  Future<List<String>> loadFilterOptions(String filterType) async {
    switch (filterType) {
      case 'propertyTypes':
        if (_propertyTypes.isEmpty) {
          _propertyTypes = await _houseService.getPropertyTypes();
        }
        return _propertyTypes;
      case 'destinations':
        if (_popularDestinations.isEmpty) {
          _popularDestinations = await _houseService.getPopularDestinations();
        }
        return _popularDestinations;
      default:
        return [];
    }
  }

  @override
  HouseFilterRequest createFilter({
    String? searchTerm,
    Map<String, dynamic>? filters,
    String sortBy = 'created',
    bool ascending = false,
    int pageIndex = 1,
    int pageSize = 10,
  }) {
    String? location = filters?['location'];
    String? city;
    String? country;
    if (location != null && location is String && location.contains(',')) {
      city = location.split(',').first.trim();
      country = location.split(',').last.trim();
    } else if (location != null &&
        location is String &&
        location.isNotEmpty &&
        location != 'Any Location') {
      city = location.trim();
      country = null;
    }

    return HouseFilterRequest(
      searchTerm: searchTerm,
      propertyType: filters?['propertyType'],
      minPrice: filters?['minPrice']?.toDouble(),
      maxPrice: filters?['maxPrice']?.toDouble(),
      minBedrooms: filters?['minBedrooms']?.round(),
      maxBedrooms: filters?['maxBedrooms']?.round(),
      city: city,
      country: country,
      minGuests: filters?['guestCount'] ?? 2,
      availableFrom: filters?['checkInDate'],
      availableTo: filters?['checkOutDate'],
      pageIndex: pageIndex,
      pageSize: pageSize,
      sortBy: sortBy,
      ascending: ascending,
    );
  }

  @override
  List<QuickFilterOption> get quickFilterOptions => [
    const QuickFilterOption(label: 'House', value: 'House'),
    const QuickFilterOption(label: 'Apartment', value: 'Apartment'),
    const QuickFilterOption(label: 'Villa', value: 'Villa'),
    const QuickFilterOption(label: 'Cottage', value: 'Cottage'),
  ];

  @override
  List<Widget> buildFilterSections(
    BuildContext context,
    Map<String, dynamic> currentFilters,
    Function(String, dynamic) onFilterChanged,
  ) {
    return [
      _buildPropertyTypeFilter(context, currentFilters, onFilterChanged),
      _buildPriceRangeFilter(context, currentFilters, onFilterChanged),
      _buildBedroomFilter(context, currentFilters, onFilterChanged),
      _buildGuestCountFilter(context, currentFilters, onFilterChanged),
      _buildLocationFilter(context, currentFilters, onFilterChanged),
      _buildDateFilter(context, currentFilters, onFilterChanged),
    ];
  }

  Widget _buildPropertyTypeFilter(
    BuildContext context,
    Map<String, dynamic> currentFilters,
    Function(String, dynamic) onFilterChanged,
  ) {
    return UnifiedDropdownFilter(
      title: 'Property Type',
      currentValue: currentFilters['propertyType'],
      options: ['Any Property', ..._propertyTypes],
      defaultOption: 'Any Property',
      onChanged: (value) => onFilterChanged('propertyType', value),
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
      currentFilters['maxPrice']?.toDouble() ?? 1000,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Price Range',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            AnimatedDefaultTextStyle(
              duration: AnimationDurations.fast,
              style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ) ??
                  const TextStyle(),
              child: Text(
                '\$${priceRange.start.round()} - \$${priceRange.end.round()}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: colorScheme.primary,
            inactiveTrackColor: colorScheme.primary.withOpacity(0.2),
            thumbColor: colorScheme.primary,
            overlayColor: colorScheme.primary.withOpacity(0.2),
            valueIndicatorColor: colorScheme.primary,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: RangeSlider(
            values: priceRange,
            min: 0,
            max: 1000,
            divisions: 20,
            labels: RangeLabels(
              '\$${priceRange.start.round()}',
              '\$${priceRange.end.round()}',
            ),
            onChanged: (values) {
              HapticUtils.selectionClick();
              onFilterChanged('minPrice', values.start);
              onFilterChanged('maxPrice', values.end);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBedroomFilter(
    BuildContext context,
    Map<String, dynamic> currentFilters,
    Function(String, dynamic) onFilterChanged,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final bedroomRange = RangeValues(
      currentFilters['minBedrooms']?.toDouble() ?? 1,
      currentFilters['maxBedrooms']?.toDouble() ?? 5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bedrooms',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            AnimatedDefaultTextStyle(
              duration: AnimationDurations.fast,
              style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ) ??
                  const TextStyle(),
              child: Text(
                '${bedroomRange.start.round()} - ${bedroomRange.end.round()}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: colorScheme.secondary,
            inactiveTrackColor: colorScheme.secondary.withOpacity(0.2),
            thumbColor: colorScheme.secondary,
            overlayColor: colorScheme.secondary.withOpacity(0.2),
            valueIndicatorColor: colorScheme.secondary,
          ),
          child: RangeSlider(
            values: bedroomRange,
            min: 1,
            max: 5,
            divisions: 4,
            labels: RangeLabels(
              '${bedroomRange.start.round()}',
              '${bedroomRange.end.round()}',
            ),
            onChanged: (values) {
              HapticUtils.selectionClick();
              onFilterChanged('minBedrooms', values.start.round());
              onFilterChanged('maxBedrooms', values.end.round());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGuestCountFilter(
    BuildContext context,
    Map<String, dynamic> currentFilters,
    Function(String, dynamic) onFilterChanged,
  ) {
    final guestCount = currentFilters['guestCount'] ?? 2;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guests',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Number of guests'),
              Row(
                children: [
                  BounceAnimation(
                    onTap:
                        guestCount > 1
                            ? () =>
                                onFilterChanged('guestCount', guestCount - 1)
                            : null,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            guestCount > 1
                                ? colorScheme.primary.withOpacity(0.1)
                                : colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.remove_rounded,
                        color:
                            guestCount > 1
                                ? colorScheme.primary
                                : colorScheme.outline.withOpacity(0.5),
                      ),
                    ),
                  ),
                  Container(
                    width: 48,
                    alignment: Alignment.center,
                    child: AnimatedSwitcher(
                      duration: AnimationDurations.fast,
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Text(
                        '$guestCount',
                        key: ValueKey(guestCount),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  BounceAnimation(
                    onTap:
                        guestCount < 10
                            ? () =>
                                onFilterChanged('guestCount', guestCount + 1)
                            : null,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            guestCount < 10
                                ? colorScheme.primary.withOpacity(0.1)
                                : colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color:
                            guestCount < 10
                                ? colorScheme.primary
                                : colorScheme.outline.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationFilter(
    BuildContext context,
    Map<String, dynamic> currentFilters,
    Function(String, dynamic) onFilterChanged,
  ) {
    return UnifiedDropdownFilter(
      title: 'Location',
      currentValue: currentFilters['location'],
      options: ['Any Location', ..._popularDestinations],
      defaultOption: 'Any Location',
      onChanged: (value) => onFilterChanged('location', value),
    );
  }

  Widget _buildDateFilter(
    BuildContext context,
    Map<String, dynamic> currentFilters,
    Function(String, dynamic) onFilterChanged,
  ) {
    final checkInDate = currentFilters['checkInDate'] as DateTime?;
    final checkOutDate = currentFilters['checkOutDate'] as DateTime?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Check-in & Check-out Dates',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateSelector(
                context,
                'Check-in',
                checkInDate,
                (date) => onFilterChanged('checkInDate', date),
                Icons.login_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateSelector(
                context,
                'Check-out',
                checkOutDate,
                (date) => onFilterChanged('checkOutDate', date),
                Icons.logout_rounded,
                minDate: checkInDate,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    String label,
    DateTime? selectedDate,
    Function(DateTime) onDateSelected,
    IconData icon, {
    DateTime? minDate,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return BounceAnimation(
      onTap: () async {
        final now = DateTime.now();
        final firstDate =
            minDate != null && minDate.isAfter(now)
                ? minDate.add(const Duration(days: 1))
                : now;

        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? firstDate,
          firstDate: firstDate,
          lastDate: now.add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(colorScheme: colorScheme),
              child: child!,
            );
          },
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: AnimatedContainer(
        duration: AnimationDurations.fast,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                selectedDate != null
                    ? colorScheme.primary
                    : colorScheme.outline.withOpacity(0.3),
            width: selectedDate != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color:
              selectedDate != null
                  ? colorScheme.primary.withOpacity(0.05)
                  : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color:
                      selectedDate != null
                          ? colorScheme.primary
                          : colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: AnimationDurations.fast,
                    style: TextStyle(
                      fontWeight:
                          selectedDate != null
                              ? FontWeight.bold
                              : FontWeight.normal,
                      fontSize: 16,
                      color:
                          selectedDate != null
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withOpacity(0.5),
                    ),
                    child: Text(
                      selectedDate != null
                          ? DateFormat('MMM d, yyyy').format(selectedDate)
                          : 'Select date',
                      overflow: TextOverflow.ellipsis,
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

  @override
  Widget buildItemCard(
    BuildContext context,
    House house,
    int index,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    return _buildEnhancedHouseCard(context, house, isMobile, index);
  }

  @override
  void onItemTapped(BuildContext context, House house) {
    Navigator.of(
      context,
    ).push(SmoothPageRoute(page: HouseDetailScreen(houseId: house.id)));
  }

  Widget _buildEnhancedHouseCard(
    BuildContext context,
    House house,
    bool isMobile,
    int index,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Image Section with Hero Animation
          Hero(
            tag: 'house_${house.id}',
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image or Placeholder
                    house.mainImageUrl != null
                        ? Image.network(
                          house.mainImageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SkeletonCard(
                              showShimmer: true,
                              borderRadius: BorderRadius.zero,
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder(context, house);
                          },
                        )
                        : _buildImagePlaceholder(context, house),

                    // Gradient Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Property Type Badge with Animation
                    Positioned(
                      top: 12,
                      left: 12,
                      child: TweenAnimationBuilder<double>(
                        duration: Duration(
                          milliseconds: 600 + (index * 100).clamp(0, 1000),
                        ),
                        tween: Tween(begin: 0.0, end: 1.0),
                        curve: AnimationCurves.overshoot,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: house.propertyTypeColor.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: house.propertyTypeColor.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    house.propertyTypeIconData,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    house.propertyType,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Rating Badge with Glow Effect
                    if (house.averageRating != null)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GlassmorphicCard(
                          blur: 10,
                          opacity: 0.2,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          borderRadius: BorderRadius.circular(16),
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
                                house.averageRating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Location Overlay
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              house.displayLocation,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Enhanced Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name with Animation
                AnimatedDefaultTextStyle(
                  duration: AnimationDurations.normal,
                  style:
                      Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ) ??
                      const TextStyle(),
                  child: Text(
                    house.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 12),

                // Features with Animated Icons
                Row(
                  children: [
                    _buildAnimatedFeaturePill(
                      context,
                      Icons.king_bed_rounded,
                      '${house.bedrooms} ${house.bedrooms > 1 ? 'beds' : 'bed'}',
                      colorScheme.primary,
                      index * 100,
                    ),
                    const SizedBox(width: 8),
                    _buildAnimatedFeaturePill(
                      context,
                      Icons.bathtub_rounded,
                      '${house.bathrooms} ${house.bathrooms > 1 ? 'baths' : 'bath'}',
                      colorScheme.secondary,
                      index * 100 + 100,
                    ),
                    const SizedBox(width: 8),
                    _buildAnimatedFeaturePill(
                      context,
                      Icons.people_rounded,
                      '${house.maxGuests} ${house.maxGuests > 1 ? 'guests' : 'guest'}',
                      colorScheme.tertiary,
                      index * 100 + 200,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Price with Pulse Animation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          duration: Duration(
                            milliseconds: 800 + (index * 50).clamp(0, 1000),
                          ),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: AnimationCurves.overshoot,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.8 + (0.2 * value),
                              child: Text(
                                house.displayPrice,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    BounceAnimation(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isMobile ? 'View' : 'View Details',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context, House house) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            house.propertyTypeColor.withOpacity(0.1),
            house.propertyTypeColor.withOpacity(0.2),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              house.propertyTypeIconData,
              size: 48,
              color: house.propertyTypeColor.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No Image',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedFeaturePill(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
    int delay,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: AnimationCurves.smoothOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 4),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
