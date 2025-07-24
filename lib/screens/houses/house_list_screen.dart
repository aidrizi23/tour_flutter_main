import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/house_models.dart';
import '../../services/house_service.dart';
import '../../widgets/unified_list_screen.dart';
import '../../widgets/unified_filter_system.dart';
import 'house_detail_screen.dart';

class HouseListScreen extends StatelessWidget {
  const HouseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UnifiedListScreen<House, HouseFilterRequest>(
      config: HouseListScreenConfig(),
    );
  }
}

class HouseListScreenConfig extends UnifiedListScreenConfig<House, HouseFilterRequest> {
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
  String get emptyStateSubtitle => 'Try adjusting your filters to find more options';

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
    return HouseFilterRequest(
      searchTerm: searchTerm,
      propertyType: filters?['propertyType'],
      minPrice: filters?['minPrice']?.toDouble(),
      maxPrice: filters?['maxPrice']?.toDouble(),
      minBedrooms: filters?['minBedrooms']?.round(),
      maxBedrooms: filters?['maxBedrooms']?.round(),
      city: filters?['location']?.split(',').first.trim(),
      country: filters?['location']?.contains(',') == true
          ? filters?['location']?.split(',').last.trim()
          : null,
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
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '\$${priceRange.start.round()} - \$${priceRange.end.round()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: priceRange,
          min: 0,
          max: 1000,
          divisions: 20,
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
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${bedroomRange.start.round()} - ${bedroomRange.end.round()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: bedroomRange,
          min: 1,
          max: 5,
          divisions: 4,
          labels: RangeLabels(
            '${bedroomRange.start.round()}',
            '${bedroomRange.end.round()}',
          ),
          onChanged: (values) {
            onFilterChanged('minBedrooms', values.start.round());
            onFilterChanged('maxBedrooms', values.end.round());
          },
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guests',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Number of guests'),
            Row(
              children: [
                IconButton(
                  onPressed: guestCount > 1
                      ? () => onFilterChanged('guestCount', guestCount - 1)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '$guestCount',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: guestCount < 10
                      ? () => onFilterChanged('guestCount', guestCount + 1)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ],
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
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
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
                Icons.login,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateSelector(
                context,
                'Check-out',
                checkOutDate,
                (date) => onFilterChanged('checkOutDate', date),
                Icons.logout,
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

    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final firstDate = minDate != null && minDate.isAfter(now)
            ? minDate.add(const Duration(days: 1))
            : now;

        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? firstDate,
          firstDate: firstDate,
          lastDate: now.add(const Duration(days: 365)),
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedDate != null
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: selectedDate != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selectedDate != null
              ? colorScheme.primary.withValues(alpha: 0.1)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selectedDate != null
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? DateFormat('MMM d, yyyy').format(selectedDate)
                        : 'Select date',
                    style: TextStyle(
                      fontWeight: selectedDate != null
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 16,
                      color: selectedDate != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    overflow: TextOverflow.ellipsis,
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
  Widget buildItemCard(BuildContext context, House house, int index, bool isMobile, bool isTablet, bool isDesktop) {
    return _buildHouseCard(context, house);
  }

  @override
  void onItemTapped(BuildContext context, House house) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HouseDetailScreen(houseId: house.id),
      ),
    );
  }

  Widget _buildHouseCard(BuildContext context, House house) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with property type badge
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  house.mainImageUrl != null
                      ? Image.network(
                          house.mainImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: colorScheme.surfaceContainerLow,
                              child: Center(
                                child: Icon(
                                  house.propertyTypeIconData,
                                  size: 48,
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: colorScheme.surfaceContainerLow,
                          child: Center(
                            child: Icon(
                              house.propertyTypeIconData,
                              size: 48,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ),

                  // Property type badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: house.propertyTypeColor.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
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
                  ),

                  // Rating badge if available
                  if (house.averageRating != null)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              house.averageRating!.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // House details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        house.displayLocation,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Name
                Text(
                  house.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Features
                Row(
                  children: [
                    _buildFeaturePill(
                      context,
                      Icons.king_bed,
                      '${house.bedrooms} ${house.bedrooms > 1 ? 'beds' : 'bed'}',
                    ),
                    const SizedBox(width: 8),
                    _buildFeaturePill(
                      context,
                      Icons.bathtub,
                      '${house.bathrooms} ${house.bathrooms > 1 ? 'baths' : 'bath'}',
                    ),
                    const SizedBox(width: 8),
                    _buildFeaturePill(
                      context,
                      Icons.people,
                      '${house.maxGuests} ${house.maxGuests > 1 ? 'guests' : 'guest'}',
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      house.displayPrice,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
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

  Widget _buildFeaturePill(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}