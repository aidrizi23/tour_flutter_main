import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/house_models.dart';
import '../../services/house_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/modern_widgets.dart';
import 'house_detail_screen.dart';

class HouseListScreen extends StatefulWidget {
  const HouseListScreen({super.key});

  @override
  State<HouseListScreen> createState() => _HouseListScreenState();
}

class _HouseListScreenState extends State<HouseListScreen>
    with SingleTickerProviderStateMixin {
  final HouseService _houseService = HouseService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<House> _houses = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  final int _pageSize = 10;

  // Filter variables
  String? _selectedPropertyType;
  RangeValues _priceRange = const RangeValues(0, 1000);
  RangeValues _bedroomRange = const RangeValues(1, 5);
  String? _selectedLocation;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guestCount = 2;

  bool _hasActiveFilters = false;
  List<String> _propertyTypes = [];
  List<String> _popularDestinations = [];
  final bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _fetchHouses();
    _loadFilterOptions();

    _scrollController.addListener(_scrollListener);
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadFilterOptions() async {
    try {
      final propertyTypes = await _houseService.getPropertyTypes();
      final destinations = await _houseService.getPopularDestinations();

      if (mounted) {
        setState(() {
          _propertyTypes = propertyTypes;
          _popularDestinations = destinations;
        });
      }
    } catch (e) {
      debugPrint('Error loading filter options: $e');
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasMoreData && !_isLoadingMore) {
        _loadMoreHouses();
      }
    }
  }

  Future<void> _fetchHouses({bool refresh = false}) async {
    try {
      if (refresh) {
        setState(() {
          _isLoading = true;
          _currentPage = 1;
          _houses = [];
        });
      }

      // Create filter
      final filter = HouseFilterRequest(
        searchTerm:
            _searchController.text.isEmpty ? null : _searchController.text,
        propertyType: _selectedPropertyType,
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
        minBedrooms: _bedroomRange.start.round(),
        maxBedrooms: _bedroomRange.end.round(),
        city: _selectedLocation?.split(',').first.trim(),
        country:
            _selectedLocation?.contains(',') == true
                ? _selectedLocation?.split(',').last.trim()
                : null,
        minGuests: _guestCount,
        availableFrom: _checkInDate,
        availableTo: _checkOutDate,
        pageIndex: _currentPage,
        pageSize: _pageSize,
        sortBy: 'nightlyRate', // Default sort
        ascending: true,
      );

      // Update filter status
      _hasActiveFilters =
          _selectedPropertyType != null ||
          _priceRange.start > 0 ||
          _priceRange.end < 1000 ||
          _bedroomRange.start > 1 ||
          _bedroomRange.end < 5 ||
          _selectedLocation != null ||
          _checkInDate != null ||
          _checkOutDate != null ||
          _guestCount > 2;

      final result = await _houseService.getHouses(filter: filter);

      if (mounted) {
        setState(() {
          if (refresh || _currentPage == 1) {
            _houses = result.items;
          } else {
            _houses.addAll(result.items);
          }
          _hasMoreData = result.hasNextPage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading houses: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _loadMoreHouses() async {
    if (!_hasMoreData || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    await _fetchHouses();

    setState(() {
      _isLoadingMore = false;
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedPropertyType = null;
      _priceRange = const RangeValues(0, 1000);
      _bedroomRange = const RangeValues(1, 5);
      _selectedLocation = null;
      _checkInDate = null;
      _checkOutDate = null;
      _guestCount = 2;
      _searchController.clear();
    });
    _fetchHouses(refresh: true);
    Navigator.pop(context);
  }

  void _applyFilters() {
    _fetchHouses(refresh: true);
    Navigator.pop(context);
  }

  void _toggleFilters() {
    _showFilterBottomSheet();
  }

  void _toggleDateFilter() {
    _showDatePickerBottomSheet();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                          Text(
                            'Filters',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () => _resetFilters(),
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    ),

                    // Filter options
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        children: [
                          // Property Type
                          Text(
                            'Property Type',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                _propertyTypes.map((type) {
                                  return ModernChip(
                                    label: type,
                                    selected: _selectedPropertyType == type,
                                    onTap: () {
                                      setModalState(() {
                                        if (_selectedPropertyType == type) {
                                          _selectedPropertyType = null;
                                        } else {
                                          _selectedPropertyType = type;
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                          ),

                          const SizedBox(height: 24),

                          // Price Range
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Price Range',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '\$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          RangeSlider(
                            values: _priceRange,
                            min: 0,
                            max: 1000,
                            divisions: 20,
                            labels: RangeLabels(
                              '\$${_priceRange.start.round()}',
                              '\$${_priceRange.end.round()}',
                            ),
                            onChanged: (values) {
                              setModalState(() {
                                _priceRange = values;
                              });
                            },
                          ),

                          const SizedBox(height: 24),

                          // Bedrooms
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Bedrooms',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${_bedroomRange.start.round()} - ${_bedroomRange.end.round()}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          RangeSlider(
                            values: _bedroomRange,
                            min: 1,
                            max: 5,
                            divisions: 4,
                            labels: RangeLabels(
                              '${_bedroomRange.start.round()}',
                              '${_bedroomRange.end.round()}',
                            ),
                            onChanged: (values) {
                              setModalState(() {
                                _bedroomRange = values;
                              });
                            },
                          ),

                          const SizedBox(height: 24),

                          // Guest Count
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Guests',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed:
                                        _guestCount > 1
                                            ? () => setModalState(
                                              () => _guestCount--,
                                            )
                                            : null,
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    color:
                                        _guestCount > 1
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.3),
                                  ),
                                  Text(
                                    '$_guestCount',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed:
                                        _guestCount < 10
                                            ? () => setModalState(
                                              () => _guestCount++,
                                            )
                                            : null,
                                    icon: const Icon(Icons.add_circle_outline),
                                    color:
                                        _guestCount < 10
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.3),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Destination
                          Text(
                            'Popular Destinations',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                _popularDestinations.map((destination) {
                                  return ModernChip(
                                    label: destination,
                                    selected: _selectedLocation == destination,
                                    onTap: () {
                                      setModalState(() {
                                        if (_selectedLocation == destination) {
                                          _selectedLocation = null;
                                        } else {
                                          _selectedLocation = destination;
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),

                    // Apply button
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, -1),
                          ),
                        ],
                      ),
                      child: CustomButton(
                        text: 'Apply Filters',
                        onPressed: _applyFilters,
                        icon: Icons.check,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  void _showDatePickerBottomSheet() {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: colorScheme.secondary),
                            ),
                          ),
                          Text(
                            'Select Dates',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                _checkInDate = null;
                                _checkOutDate = null;
                              });
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ),

                    // Date selection
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check-in & Check-out Dates',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDateSelector(
                                    'Check-in',
                                    _checkInDate,
                                    (date) => setModalState(() {
                                      _checkInDate = date;
                                      // If check-out date is before check-in, update it
                                      if (_checkOutDate != null &&
                                          _checkOutDate!.isBefore(
                                            _checkInDate!,
                                          )) {
                                        _checkOutDate = _checkInDate!.add(
                                          const Duration(days: 1),
                                        );
                                      }
                                    }),
                                    icon: Icons.login,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDateSelector(
                                    'Check-out',
                                    _checkOutDate,
                                    (date) => setModalState(
                                      () => _checkOutDate = date,
                                    ),
                                    icon: Icons.logout,
                                    minDate: _checkInDate,
                                  ),
                                ),
                              ],
                            ),

                            if (_checkInDate != null &&
                                _checkOutDate != null) ...[
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer
                                      .withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colorScheme.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Your stay: ${_checkOutDate!.difference(_checkInDate!).inDays} ${_checkOutDate!.difference(_checkInDate!).inDays == 1 ? 'night' : 'nights'}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const Spacer(),

                            CustomButton(
                              text: 'Apply Dates',
                              onPressed: () {
                                _fetchHouses(refresh: true);
                                Navigator.pop(context);
                              },
                              icon: Icons.check,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildDateSelector(
    String label,
    DateTime? selectedDate,
    Function(DateTime) onDateSelected, {
    IconData? icon,
    DateTime? minDate,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final firstDate =
        minDate != null && minDate.isAfter(now)
            ? minDate.add(const Duration(days: 1))
            : now;

    return GestureDetector(
      onTap: () async {
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
            color:
                selectedDate != null
                    ? colorScheme.primary
                    : colorScheme.outline.withOpacity(0.3),
            width: selectedDate != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color:
              selectedDate != null
                  ? colorScheme.primary.withOpacity(0.1)
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
                  icon ?? Icons.calendar_today,
                  size: 18,
                  color:
                      selectedDate != null
                          ? colorScheme.primary
                          : colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? DateFormat('MMM d, yyyy').format(selectedDate)
                        : 'Select date',
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;
    final isMobile = screenWidth <= 600;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: Column(
        children: [
          // Header Section
          Container(
            color: colorScheme.surface,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 20 : 32),
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
                                'Find Your Perfect Stay',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_houses.length} amazing accommodations available',
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
                            Icons.home_rounded,
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

          // Search and filter bar
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search field
                ModernSearchField(
                  controller: _searchController,
                  hintText: 'Search destinations, properties...',
                  onSubmitted: (value) => _fetchHouses(refresh: true),
                ),
                const SizedBox(height: 16),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Dates filter
                      GestureDetector(
                        onTap: _toggleDateFilter,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _checkInDate != null || _checkOutDate != null
                                    ? colorScheme.primary
                                    : colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  _checkInDate != null || _checkOutDate != null
                                      ? colorScheme.primary
                                      : colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color:
                                    _checkInDate != null ||
                                            _checkOutDate != null
                                        ? colorScheme.onPrimary
                                        : colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _checkInDate != null && _checkOutDate != null
                                    ? "${DateFormat('MMM d').format(_checkInDate!)} - ${DateFormat('MMM d').format(_checkOutDate!)}"
                                    : _checkInDate != null
                                    ? "From ${DateFormat('MMM d').format(_checkInDate!)}"
                                    : "Dates",
                                style: TextStyle(
                                  color:
                                      _checkInDate != null ||
                                              _checkOutDate != null
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Guests filter
                      GestureDetector(
                        onTap: _toggleFilters,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _guestCount > 2
                                    ? colorScheme.primary
                                    : colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  _guestCount > 2
                                      ? colorScheme.primary
                                      : colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.people,
                                size: 16,
                                color:
                                    _guestCount > 2
                                        ? colorScheme.onPrimary
                                        : colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "$_guestCount ${_guestCount == 1 ? 'Guest' : 'Guests'}",
                                style: TextStyle(
                                  color:
                                      _guestCount > 2
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Price filter
                      GestureDetector(
                        onTap: _toggleFilters,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _priceRange.start > 0 || _priceRange.end < 1000
                                    ? colorScheme.primary
                                    : colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  _priceRange.start > 0 ||
                                          _priceRange.end < 1000
                                      ? colorScheme.primary
                                      : colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                size: 16,
                                color:
                                    _priceRange.start > 0 ||
                                            _priceRange.end < 1000
                                        ? colorScheme.onPrimary
                                        : colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _priceRange.start > 0 || _priceRange.end < 1000
                                    ? "\$${_priceRange.start.round()}-\$${_priceRange.end.round()}"
                                    : "Price",
                                style: TextStyle(
                                  color:
                                      _priceRange.start > 0 ||
                                              _priceRange.end < 1000
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Property type filter
                      if (_selectedPropertyType != null)
                        GestureDetector(
                          onTap: _toggleFilters,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: colorScheme.primary),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getPropertyTypeIcon(_selectedPropertyType!),
                                  size: 16,
                                  color: colorScheme.onPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedPropertyType!,
                                  style: TextStyle(
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),

                      // More filters button
                      GestureDetector(
                        onTap: _toggleFilters,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _hasActiveFilters
                                    ? colorScheme.primary.withOpacity(0.1)
                                    : colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  _hasActiveFilters
                                      ? colorScheme.primary
                                      : colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.tune,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Filters",
                                style: TextStyle(color: colorScheme.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isLoading
                      ? 'Loading properties...'
                      : '${_houses.length} ${_houses.length == 1 ? 'property' : 'properties'} found',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_hasActiveFilters)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedPropertyType = null;
                        _priceRange = const RangeValues(0, 1000);
                        _bedroomRange = const RangeValues(1, 5);
                        _selectedLocation = null;
                        _checkInDate = null;
                        _checkOutDate = null;
                        _guestCount = 2;
                        _searchController.clear();
                      });
                      _fetchHouses(refresh: true);
                    },
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Filters'),
                  ),
              ],
            ),
          ),

          // House listings
          Expanded(
            child:
                _isLoading && _houses.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _houses.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.house_outlined,
                            size: 64,
                            color: colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No accommodations found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedPropertyType = null;
                                _priceRange = const RangeValues(0, 1000);
                                _bedroomRange = const RangeValues(1, 5);
                                _selectedLocation = null;
                                _checkInDate = null;
                                _checkOutDate = null;
                                _guestCount = 2;
                                _searchController.clear();
                              });
                              _fetchHouses(refresh: true);
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset Filters'),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: () => _fetchHouses(refresh: true),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: _houses.length + (_hasMoreData ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _houses.length) {
                              return _isLoadingMore
                                  ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                  : const SizedBox.shrink();
                            }

                            return _buildHouseCard(_houses[index]);
                          },
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildHouseCard(House house) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HouseDetailScreen(houseId: house.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
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
                                      .withOpacity(0.5),
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
                              color: colorScheme.onSurfaceVariant.withOpacity(
                                0.5,
                              ),
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
                          color: house.propertyTypeColor.withOpacity(0.9),
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
                            color: Colors.black.withOpacity(0.7),
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
                            color: colorScheme.onSurface.withOpacity(0.7),
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
                        Icons.king_bed,
                        '${house.bedrooms} ${house.bedrooms > 1 ? 'beds' : 'bed'}',
                      ),
                      const SizedBox(width: 8),
                      _buildFeaturePill(
                        Icons.bathtub,
                        '${house.bathrooms} ${house.bathrooms > 1 ? 'baths' : 'bath'}',
                      ),
                      const SizedBox(width: 8),
                      _buildFeaturePill(
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
      ),
    );
  }

  Widget _buildFeaturePill(IconData icon, String text) {
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

  IconData _getPropertyTypeIcon(String propertyType) {
    switch (propertyType.toLowerCase()) {
      case 'house':
        return Icons.house;
      case 'apartment':
        return Icons.apartment;
      case 'villa':
        return Icons.villa;
      case 'cottage':
        return Icons.cottage;
      default:
        return Icons.home;
    }
  }
}
