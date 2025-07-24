import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/car_models.dart';
import '../../services/car_service.dart';
import '../../widgets/unified_list_screen.dart';
import '../../widgets/unified_filter_system.dart';
import 'car_details_screen.dart';

class CarListScreen extends StatelessWidget {
  const CarListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UnifiedListScreen<Car, CarFilterRequest>(
      config: CarListScreenConfig(),
    );
  }
}

class CarListScreenConfig extends UnifiedListScreenConfig<Car, CarFilterRequest> {
  final CarService _carService = CarService();
  List<String> _makes = [];
  List<String> _locations = [];

  @override
  String get screenTitle => 'Car Rentals';

  @override
  String get screenSubtitle => 'Find the perfect ride for your journey';

  @override
  IconData get screenIcon => Icons.directions_car_rounded;

  @override
  String get itemTypeSingular => 'car';

  @override
  String get itemTypePlural => 'cars';

  @override
  String get searchHint => 'Search cars, makes, models...';

  @override
  String get emptyStateTitle => 'No cars found';

  @override
  String get emptyStateSubtitle => 'Try adjusting your search criteria or rental dates';

  @override
  String get loadingMessage => 'Finding available cars...';

  @override
  Future<PagedResult<Car>> loadItems(CarFilterRequest filter) async {
    final result = await _carService.getCars(filter: filter);
    return PagedResult(
      items: result.items,
      hasNextPage: result.hasNextPage,
      totalCount: result.totalCount,
    );
  }

  @override
  Future<List<String>> loadFilterOptions(String filterType) async {
    switch (filterType) {
      case 'makes':
        if (_makes.isEmpty) {
          _makes = await _carService.getMakes();
        }
        return _makes;
      case 'locations':
        if (_locations.isEmpty) {
          _locations = await _carService.getLocations();
        }
        return _locations;
      default:
        return [];
    }
  }

  @override
  CarFilterRequest createFilter({
    String? searchTerm,
    Map<String, dynamic>? filters,
    String sortBy = 'created',
    bool ascending = false,
    int pageIndex = 1,
    int pageSize = 15,
  }) {
    return CarFilterRequest(
      searchTerm: searchTerm,
      make: filters?['make'],
      model: filters?['model'],
      category: filters?['category'],
      transmission: filters?['transmission'],
      fuelType: filters?['fuelType'],
      location: filters?['location'],
      minYear: filters?['minYear'],
      maxYear: filters?['maxYear'],
      minSeats: filters?['minSeats'],
      maxSeats: filters?['maxSeats'],
      minDailyRate: filters?['minPrice']?.toDouble(),
      maxDailyRate: filters?['maxPrice']?.toDouble(),
      startDate: filters?['startDate'],
      endDate: filters?['endDate'],
      sortBy: sortBy,
      ascending: ascending,
      pageIndex: pageIndex,
      pageSize: pageSize,
    );
  }

  @override
  List<QuickFilterOption> get quickFilterOptions => [
    const QuickFilterOption(label: 'Economy', value: 'Economy'),
    const QuickFilterOption(label: 'Compact', value: 'Compact'),
    const QuickFilterOption(label: 'SUV', value: 'SUV'),
    const QuickFilterOption(label: 'Luxury', value: 'Luxury'),
  ];

  @override
  List<Widget> buildFilterSections(
    BuildContext context,
    Map<String, dynamic> currentFilters,
    Function(String, dynamic) onFilterChanged,
  ) {
    return [
      _buildMakeModelFilter(context, currentFilters, onFilterChanged),
      _buildTransmissionFuelFilter(context, currentFilters, onFilterChanged),
      _buildLocationFilter(context, currentFilters, onFilterChanged),
      _buildYearRangeFilter(context, currentFilters, onFilterChanged),
      _buildSeatsFilter(context, currentFilters, onFilterChanged),
      _buildPriceRangeFilter(context, currentFilters, onFilterChanged),
      _buildDateFilter(context, currentFilters, onFilterChanged),
      _buildSortFilter(context, currentFilters, onFilterChanged),
    ];
  }

  Widget _buildMakeModelFilter(
    BuildContext context,
    Map<String, dynamic> currentFilters,
    Function(String, dynamic) onFilterChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: UnifiedDropdownFilter(
            title: 'Make',
            currentValue: currentFilters['make'],
            options: ['Any Make', ..._makes],
            defaultOption: 'Any Make',
            onChanged: (value) => onFilterChanged('make', value),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Model',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: currentFilters['model'] ?? '',
                decoration: const InputDecoration(
                  hintText: 'Any model',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (value) => onFilterChanged('model', value.isNotEmpty ? value : null),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransmissionFuelFilter(
    BuildContext context,
    Map<String, dynamic> currentFilters,
    Function(String, dynamic) onFilterChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: UnifiedDropdownFilter(
            title: 'Transmission',
            currentValue: currentFilters['transmission'],
            options: ['Any Transmission', ...CarService.transmissionTypes],
            defaultOption: 'Any Transmission',
            onChanged: (value) => onFilterChanged('transmission', value),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: UnifiedDropdownFilter(
            title: 'Fuel Type',
            currentValue: currentFilters['fuelType'],
            options: ['Any Fuel Type', ...CarService.fuelTypes],
            defaultOption: 'Any Fuel Type',
            onChanged: (value) => onFilterChanged('fuelType', value),
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
      options: ['Any Location', ..._locations],
      defaultOption: 'Any Location',
      onChanged: (value) => onFilterChanged('location', value),
    );
  }

  Widget _buildYearRangeFilter(
    BuildContext context,
    Map<String, dynamic> currentFilters,
    Function(String, dynamic) onFilterChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildNumberField(
            'Min Year',
            currentFilters['minYear']?.toString() ?? '',
            (value) => onFilterChanged('minYear', int.tryParse(value)),
            isInt: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildNumberField(
            'Max Year',
            currentFilters['maxYear']?.toString() ?? '',
            (value) => onFilterChanged('maxYear', int.tryParse(value)),
            isInt: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSeatsFilter(
    BuildContext context,
    Map<String, dynamic> currentFilters,
    Function(String, dynamic) onFilterChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildNumberField(
            'Min Seats',
            currentFilters['minSeats']?.toString() ?? '',
            (value) => onFilterChanged('minSeats', int.tryParse(value)),
            isInt: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildNumberField(
            'Max Seats',
            currentFilters['maxSeats']?.toString() ?? '',
            (value) => onFilterChanged('maxSeats', int.tryParse(value)),
            isInt: true,
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
    return Row(
      children: [
        Expanded(
          child: _buildNumberField(
            'Min Price',
            currentFilters['minPrice']?.toString() ?? '',
            (value) => onFilterChanged('minPrice', double.tryParse(value)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildNumberField(
            'Max Price',
            currentFilters['maxPrice']?.toString() ?? '',
            (value) => onFilterChanged('maxPrice', double.tryParse(value)),
          ),
        ),
      ],
    );
  }

  Widget _buildDateFilter(
    BuildContext context,
    Map<String, dynamic> currentFilters,
    Function(String, dynamic) onFilterChanged,
  ) {
    final startDate = currentFilters['startDate'] as DateTime?;
    final endDate = currentFilters['endDate'] as DateTime?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rental Period',
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
                'Pick-up',
                startDate,
                (date) => onFilterChanged('startDate', date),
                Icons.calendar_today_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateSelector(
                context,
                'Drop-off',
                endDate,
                (date) => onFilterChanged('endDate', date),
                Icons.event_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortFilter(
    BuildContext context,
    Map<String, dynamic> currentFilters,
    Function(String, dynamic) onFilterChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UnifiedDropdownFilter(
          title: 'Sort By',
          currentValue: currentFilters['sortBy'] ?? 'created',
          options: CarService.sortOptions,
          defaultOption: 'created',
          onChanged: (value) => onFilterChanged('sortBy', value),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: currentFilters['ascending'] ?? false,
              onChanged: (value) => onFilterChanged('ascending', value),
            ),
            Text(
              'Ascending order',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberField(
    String hint,
    String value,
    Function(String) onChanged, {
    bool isInt = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hint,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          keyboardType: isInt
              ? TextInputType.number
              : const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    String label,
    DateTime? selectedDate,
    Function(DateTime) onDateSelected,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          HapticFeedback.selectionClick();
          final date = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (date != null) {
            onDateSelected(date);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: selectedDate != null
                ? colorScheme.primary.withValues(alpha: 0.1)
                : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selectedDate != null
                  ? colorScheme.primary.withValues(alpha: 0.3)
                  : colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: selectedDate != null
                    ? colorScheme.primary
                    : colorScheme.outline,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      selectedDate != null
                          ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                          : 'Select date',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: selectedDate != null
                            ? colorScheme.onSurface
                            : colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget buildItemCard(BuildContext context, Car car, int index, bool isMobile, bool isTablet, bool isDesktop) {
    return _buildCarCard(context, car, isDesktop);
  }

  @override
  void onItemTapped(BuildContext context, Car car) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CarDetailsScreen(carId: car.id),
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

  Widget _buildCarCard(BuildContext context, Car car, bool isDesktop) {
    final colorScheme = Theme.of(context).colorScheme;

    return Hero(
      tag: 'car_${car.id}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: isDesktop ? 8 : 4,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 24 : 20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Stack(
              children: [
                Container(
                  height: isDesktop ? 220 : 180,
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
                  child: car.mainImageUrl != null && car.mainImageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(isDesktop ? 24 : 20),
                            topRight: Radius.circular(isDesktop ? 24 : 20),
                          ),
                          child: Image.network(
                            car.mainImageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: isDesktop ? 220 : 180,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildImagePlaceholder(context, isDesktop),
                          ),
                        )
                      : _buildImagePlaceholder(context, isDesktop),
                ),

                // Rating badge
                if (car.averageRating != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
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
                            car.averageRating!.toStringAsFixed(1),
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

                // Availability badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: car.isAvailable ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      car.isAvailable ? 'Available' : 'Unavailable',
                      style: const TextStyle(
                        color: Colors.white,
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
                    // Car name and year
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${car.make} ${car.model}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              fontSize: isDesktop ? 18 : 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${car.year}',
                            style: TextStyle(
                              color: colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
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
                            car.location,
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
                    const SizedBox(height: 12),

                    // Car details chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildDetailChip(
                          icon: car.categoryIcon,
                          label: car.category,
                          backgroundColor: car.categoryColor.withValues(alpha: 0.1),
                          textColor: car.categoryColor,
                        ),
                        _buildDetailChip(
                          icon: Icons.people_rounded,
                          label: '${car.seats}',
                          backgroundColor: colorScheme.secondaryContainer,
                          textColor: colorScheme.onSecondaryContainer,
                        ),
                        _buildDetailChip(
                          icon: car.transmissionIcon,
                          label: car.transmission.substring(0, 1),
                          backgroundColor: colorScheme.tertiaryContainer,
                          textColor: colorScheme.onTertiaryContainer,
                        ),
                        _buildDetailChip(
                          icon: car.fuelIcon,
                          label: car.fuelType.substring(0, 1),
                          backgroundColor: colorScheme.primaryContainer,
                          textColor: colorScheme.onPrimaryContainer,
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Price section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Rate',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  fontSize: isDesktop ? 12 : 11,
                                ),
                              ),
                              Text(
                                car.displayPrice,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isDesktop ? 22 : 18,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Book Now Button
                        car.isAvailable
                            ? FilledButton.icon(
                                onPressed: () => onItemTapped(context, car),
                                style: FilledButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isDesktop ? 24 : 20,
                                    vertical: isDesktop ? 14 : 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(isDesktop ? 16 : 12),
                                  ),
                                  elevation: isDesktop ? 4 : 2,
                                ),
                                icon: Icon(
                                  Icons.drive_eta_rounded,
                                  size: isDesktop ? 18 : 16,
                                ),
                                label: Text(
                                  isDesktop ? 'Book Now' : 'Rent',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: isDesktop ? 14 : 13,
                                  ),
                                ),
                              )
                            : OutlinedButton(
                                onPressed: null,
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isDesktop ? 24 : 20,
                                    vertical: isDesktop ? 14 : 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(isDesktop ? 16 : 12),
                                  ),
                                ),
                                child: Text(
                                  'Unavailable',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: isDesktop ? 14 : 13,
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
    );
  }

  Widget _buildImagePlaceholder(BuildContext context, bool isDesktop) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: isDesktop ? 220 : 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isDesktop ? 24 : 20),
          topRight: Radius.circular(isDesktop ? 24 : 20),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.08),
            colorScheme.secondary.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isDesktop ? 20 : 16),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_car_rounded,
                size: isDesktop ? 48 : 40,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: isDesktop ? 16 : 12),
            Text(
              'Image not available',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: isDesktop ? 14 : 12,
                fontWeight: FontWeight.w500,
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}