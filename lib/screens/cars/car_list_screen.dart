import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/car_models.dart';
import '../../services/car_service.dart';
import 'car_details_screen.dart';

import "../../widgets/seamless_page_route.dart";

class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen>
    with TickerProviderStateMixin {
  final CarService _carService = CarService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  List<Car> _cars = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMorePages = true;
  int _totalCount = 0;

  // Filter states
  String? _selectedMake;
  String? _selectedModel;
  String? _selectedCategory;
  String? _selectedTransmission;
  String? _selectedFuelType;
  String? _selectedLocation;
  int? _minYear;
  int? _maxYear;
  int? _minSeats;
  int? _maxSeats;
  double? _minPrice;
  double? _maxPrice;
  String _sortBy = 'created';
  bool _sortAscending = false;

  List<String> _makes = [];
  List<String> _locations = [];

  late AnimationController _filterController;
  late AnimationController _listController;
  late Animation<double> _filterFadeAnimation;
  late Animation<double> _listAnimation;

  bool _showFilters = false;
  bool _isSearchFocused = false;
  DateTime? _startDate;
  DateTime? _endDate;

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

    _loadCars();
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
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        _hasMorePages) {
      _loadMoreCars();
    }
  }

  Future<void> _loadCars({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _cars.clear();
        _hasMorePages = true;
      });
    }

    setState(() {
      _isLoading = isRefresh || _cars.isEmpty;
      _errorMessage = null;
    });

    try {
      final filter = CarFilterRequest(
        searchTerm: _searchController.text.isNotEmpty
            ? _searchController.text
            : null,
        make: _selectedMake,
        model: _selectedModel,
        category: _selectedCategory,
        transmission: _selectedTransmission,
        fuelType: _selectedFuelType,
        location: _selectedLocation,
        minYear: _minYear,
        maxYear: _maxYear,
        minSeats: _minSeats,
        maxSeats: _maxSeats,
        minDailyRate: _minPrice,
        maxDailyRate: _maxPrice,
        startDate: _startDate,
        endDate: _endDate,
        sortBy: _sortBy,
        ascending: _sortAscending,
        pageIndex: _currentPage,
        pageSize: 15,
      );

      final result = await _carService.getCars(filter: filter);

      setState(() {
        if (isRefresh || _currentPage == 1) {
          _cars = result.items;
        } else {
          _cars.addAll(result.items);
        }
        _hasMorePages = result.hasNextPage;
        _totalCount = result.totalCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load cars: ${e.toString()}';
      });
    }
  }

  Future<void> _loadMoreCars() async {
    if (_isLoadingMore || !_hasMorePages) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      final filter = CarFilterRequest(
        searchTerm: _searchController.text.isNotEmpty
            ? _searchController.text
            : null,
        make: _selectedMake,
        model: _selectedModel,
        category: _selectedCategory,
        transmission: _selectedTransmission,
        fuelType: _selectedFuelType,
        location: _selectedLocation,
        minYear: _minYear,
        maxYear: _maxYear,
        minSeats: _minSeats,
        maxSeats: _maxSeats,
        minDailyRate: _minPrice,
        maxDailyRate: _maxPrice,
        startDate: _startDate,
        endDate: _endDate,
        sortBy: _sortBy,
        ascending: _sortAscending,
        pageIndex: _currentPage,
        pageSize: 15,
      );

      final result = await _carService.getCars(filter: filter);

      setState(() {
        _cars.addAll(result.items);
        _hasMorePages = result.hasNextPage;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _currentPage--; // Revert page increment on error
      });
    }
  }

  Future<void> _loadFilterOptions() async {
    try {
      final makes = await _carService.getMakes();
      final locations = await _carService.getLocations();

      setState(() {
        _makes = makes;
        _locations = locations;
      });
    } catch (e) {
      // Handle error silently for filter options
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

  void _clearFilters() {
    setState(() {
      _selectedMake = null;
      _selectedModel = null;
      _selectedCategory = null;
      _selectedTransmission = null;
      _selectedFuelType = null;
      _selectedLocation = null;
      _minYear = null;
      _maxYear = null;
      _minSeats = null;
      _maxSeats = null;
      _minPrice = null;
      _maxPrice = null;
      _startDate = null;
      _endDate = null;
      _sortBy = 'created';
      _sortAscending = false;
      _searchController.clear();
    });
    _loadCars(isRefresh: true);
  }

  void _applyFilters() {
    _toggleFilters();
    _loadCars(isRefresh: true);
  }

  int _getGridCrossAxisCount(double screenWidth) {
    if (screenWidth > 1400) return 4;
    if (screenWidth > 1000) return 3;
    if (screenWidth > 700) return 2;
    return 1;
  }

  double _getChildAspectRatio(double screenWidth) {
    if (screenWidth > 1000)
      return 0.75; // Taller cards for more content on desktop
    if (screenWidth > 700) return 0.8;
    return 1.0; // More square on mobile
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () => _loadCars(isRefresh: true),
        color: colorScheme.primary,
        backgroundColor: colorScheme.surface,
        strokeWidth: 3,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Search section
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _listAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -50 * (1 - _listAnimation.value)),
                    child: Opacity(
                      opacity: _listAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _buildSearchAndFilters(context),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Filters panel
            if (_showFilters)
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _filterFadeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -20 * (1 - _filterFadeAnimation.value)),
                      child: Opacity(
                        opacity: _filterFadeAnimation.value,
                        child: _buildFiltersPanel(),
                      ),
                    );
                  },
                ),
              ),

            // Results header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isLoading
                          ? 'Loading cars...'
                          : '$_totalCount cars available',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    if (_cars.isNotEmpty && !_isLoading)
                      IconButton(
                        onPressed: _toggleFilters,
                        icon: AnimatedRotation(
                          turns: _showFilters ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: const Icon(Icons.tune_rounded),
                        ),
                        iconSize: 20,
                        color: colorScheme.primary,
                        tooltip: 'Filter & Sort',
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.primary.withOpacity(0.1),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Cars grid/list
            if (_isLoading && _cars.isEmpty)
              SliverFillRemaining(child: _buildLoadingState())
            else if (_errorMessage != null)
              SliverFillRemaining(child: _buildErrorState())
            else if (_cars.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getGridCrossAxisCount(screenWidth),
                    crossAxisSpacing: screenWidth > 1000 ? 24 : 16,
                    mainAxisSpacing: screenWidth > 1000 ? 24 : 16,
                    childAspectRatio: _getChildAspectRatio(screenWidth),
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index < _cars.length) {
                      return _buildCarCard(_cars[index], index);
                    } else if (_isLoadingMore) {
                      return _buildLoadingMoreCard();
                    }
                    return null;
                  }, childCount: _cars.length + (_isLoadingMore ? 1 : 0)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      elevation: 0,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Car Rentals',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Find the perfect ride for your journey',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Add favorites/saved cars feature
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Saved cars feature coming soon!'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          icon: const Icon(Icons.bookmark_border_rounded),
          color: colorScheme.onPrimary,
          tooltip: 'Saved Cars',
        ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.9)],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Search bar
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isSearchFocused
                  ? colorScheme.primary
                  : colorScheme.outline.withOpacity(0.2),
              width: _isSearchFocused ? 2 : 1,
            ),
            boxShadow: _isSearchFocused
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
                hintText: 'Search cars, makes, models...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: _isSearchFocused
                      ? colorScheme.primary
                      : colorScheme.outline,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _loadCars(isRefresh: true);
                        },
                        icon: const Icon(Icons.clear_rounded),
                        color: colorScheme.outline,
                      )
                    : null,
              ),
              onSubmitted: (_) => _loadCars(isRefresh: true),
              onChanged: (value) {
                setState(() {});
                if (value.isEmpty) {
                  _loadCars(isRefresh: true);
                }
              },
            ),
          ),
        ),

        // Rental dates
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDateSelector(
                'Pick-up',
                _startDate,
                (date) => setState(() => _startDate = date),
                Icons.calendar_today_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateSelector(
                'Drop-off',
                _endDate,
                (date) => setState(() => _endDate = date),
                Icons.event_rounded,
              ),
            ),
          ],
        ),

        // Quick filters
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildQuickFilter('All', _selectedCategory == null, () {
                setState(() => _selectedCategory = null);
                _loadCars(isRefresh: true);
              }),
              const SizedBox(width: 8),
              ...CarService.categories
                  .take(4)
                  .map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildQuickFilter(
                        category,
                        _selectedCategory == category,
                        () {
                          setState(() => _selectedCategory = category);
                          _loadCars(isRefresh: true);
                        },
                      ),
                    ),
                  ),
              _buildMoreFiltersButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector(
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
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(colorScheme: colorScheme),
                child: child!,
              );
            },
          );
          if (date != null) {
            onDateSelected(date);
            _loadCars(isRefresh: true);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: selectedDate != null
                ? colorScheme.primary.withOpacity(0.1)
                : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selectedDate != null
                  ? colorScheme.primary.withOpacity(0.3)
                  : colorScheme.outline.withOpacity(0.2),
            ),
            boxShadow: selectedDate != null
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
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
                        color: colorScheme.onSurface.withOpacity(0.6),
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
                            : colorScheme.onSurface.withOpacity(0.6),
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

  Widget _buildQuickFilter(String label, bool isSelected, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
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

  Widget _buildMoreFiltersButton() {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          _toggleFilters();
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _showFilters
                ? colorScheme.primary.withOpacity(0.1)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _showFilters
                  ? colorScheme.primary
                  : colorScheme.outline.withOpacity(0.3),
              width: _showFilters ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
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
                _showFilters ? 'Hide' : 'More',
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

  Widget _buildFiltersPanel() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                'Filters & Sort',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear_all_rounded, size: 18),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.outline,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _applyFilters,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Apply'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Make and Model
          Row(
            children: [
              Expanded(
                child: _buildFilterSection(
                  'Make',
                  DropdownButton<String>(
                    value: _selectedMake,
                    hint: const Text('Any make'),
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Any make'),
                      ),
                      ..._makes.map(
                        (make) => DropdownMenuItem<String>(
                          value: make,
                          child: Text(make),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _selectedMake = value),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterSection(
                  'Model',
                  TextField(
                    controller: TextEditingController(
                      text: _selectedModel ?? '',
                    ),
                    decoration: InputDecoration(
                      hintText: 'Any model',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onChanged: (value) =>
                        _selectedModel = value.isNotEmpty ? value : null,
                  ),
                ),
              ),
            ],
          ),

          // Transmission and Fuel Type
          Row(
            children: [
              Expanded(
                child: _buildFilterSection(
                  'Transmission',
                  DropdownButton<String>(
                    value: _selectedTransmission,
                    hint: const Text('Any transmission'),
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Any transmission'),
                      ),
                      ...CarService.transmissionTypes.map(
                        (type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedTransmission = value),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterSection(
                  'Fuel Type',
                  DropdownButton<String>(
                    value: _selectedFuelType,
                    hint: const Text('Any fuel type'),
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Any fuel type'),
                      ),
                      ...CarService.fuelTypes.map(
                        (type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedFuelType = value),
                  ),
                ),
              ),
            ],
          ),

          // Location
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
          ),

          // Year Range
          _buildFilterSection(
            'Year Range',
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    'Min Year',
                    _minYear?.toString() ?? '',
                    (value) => _minYear = int.tryParse(value),
                    isInt: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField(
                    'Max Year',
                    _maxYear?.toString() ?? '',
                    (value) => _maxYear = int.tryParse(value),
                    isInt: true,
                  ),
                ),
              ],
            ),
          ),

          // Seats Range
          _buildFilterSection(
            'Number of Seats',
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    'Min Seats',
                    _minSeats?.toString() ?? '',
                    (value) => _minSeats = int.tryParse(value),
                    isInt: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField(
                    'Max Seats',
                    _maxSeats?.toString() ?? '',
                    (value) => _maxSeats = int.tryParse(value),
                    isInt: true,
                  ),
                ),
              ],
            ),
          ),

          // Price Range
          _buildFilterSection(
            'Daily Rate Range',
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    'Min Price',
                    _minPrice?.toString() ?? '',
                    (value) => _minPrice = double.tryParse(value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField(
                    'Max Price',
                    _maxPrice?.toString() ?? '',
                    (value) => _maxPrice = double.tryParse(value),
                  ),
                ),
              ],
            ),
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
                  items: CarService.sortOptions
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option,
                          child: Text(
                            option.replaceAll('_', ' ').toUpperCase(),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _sortBy = value!),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _sortAscending,
                      onChanged: (value) =>
                          setState(() => _sortAscending = value!),
                    ),
                    Text(
                      'Ascending order',
                      style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _buildFilterSection(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(
    String hint,
    String value,
    Function(String) onChanged, {
    bool isInt = false,
  }) {
    return TextField(
      controller: TextEditingController(text: value),
      keyboardType: isInt
          ? TextInputType.number
          : const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildLoadingState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary, strokeWidth: 3),
          const SizedBox(height: 24),
          Text(
            'Finding available cars...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Failed to load cars',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _loadCars(isRefresh: true),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.directions_car_outlined,
                size: 64,
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No cars found',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your search criteria or rental dates',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_all_rounded),
              label: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMoreCard() {
    final colorScheme = Theme.of(context).colorScheme;

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
              'Loading more...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarCard(Car car, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1000;

    return Hero(
      tag: 'car_${car.id}',
      child: MouseRegion(
        onEnter: (_) => HapticFeedback.selectionClick(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity(),
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: isDesktop ? 8 : 4,
            shadowColor: colorScheme.shadow.withOpacity(0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isDesktop ? 24 : 20),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  showSeamlessPage(
                    context,
                    (context) => CarDetailsScreen(carId: car.id),
                  );
                },
                borderRadius: BorderRadius.circular(isDesktop ? 24 : 20),
                hoverColor: colorScheme.primary.withOpacity(0.04),
                splashColor: colorScheme.primary.withOpacity(0.1),
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
                                colorScheme.surfaceContainer.withOpacity(0.8),
                              ],
                            ),
                          ),
                          child:
                              car.mainImageUrl != null &&
                                  car.mainImageUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(
                                      isDesktop ? 24 : 20,
                                    ),
                                    topRight: Radius.circular(
                                      isDesktop ? 24 : 20,
                                    ),
                                  ),
                                  child: Image.network(
                                    car.mainImageUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: isDesktop ? 220 : 180,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _buildImagePlaceholder(),
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: isDesktop ? 220 : 180,
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
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CircularProgressIndicator(
                                                value:
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                    : null,
                                                strokeWidth: 2,
                                                color: colorScheme.primary,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Loading...',
                                                style: TextStyle(
                                                  color: colorScheme.onSurface
                                                      .withOpacity(0.6),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : _buildImagePlaceholder(),
                        ),

                        // Gradient overlay for better text readability
                        Container(
                          height: isDesktop ? 220 : 180,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.1),
                              ],
                            ),
                          ),
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
                                color: Colors.black.withOpacity(0.7),
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
                              color: car.isAvailable
                                  ? Colors.green
                                  : Colors.red,
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
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

                            // Location and rating
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
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: colorScheme.onSurface
                                              .withOpacity(0.7),
                                          fontSize: isDesktop ? 14 : 12,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (car.averageRating != null && isDesktop) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    car.averageRating!.toStringAsFixed(1),
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withOpacity(
                                        0.8,
                                      ),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Car details chips
                            if (isDesktop) ...[
                              // Desktop: Show more details in rows
                              Row(
                                children: [
                                  _buildDetailChip(
                                    icon: car.categoryIcon,
                                    label: car.category,
                                    backgroundColor: car.categoryColor
                                        .withOpacity(0.1),
                                    textColor: car.categoryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildDetailChip(
                                    icon: Icons.people_rounded,
                                    label: '${car.seats} seats',
                                    backgroundColor:
                                        colorScheme.secondaryContainer,
                                    textColor: colorScheme.onSecondaryContainer,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildDetailChip(
                                    icon: car.transmissionIcon,
                                    label: car.transmission,
                                    backgroundColor:
                                        colorScheme.tertiaryContainer,
                                    textColor: colorScheme.onTertiaryContainer,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildDetailChip(
                                    icon: car.fuelIcon,
                                    label: car.fuelType,
                                    backgroundColor:
                                        colorScheme.primaryContainer,
                                    textColor: colorScheme.onPrimaryContainer,
                                  ),
                                ],
                              ),
                              if (car.features.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Features:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: colorScheme.onSurface.withOpacity(
                                      0.7,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  car.features
                                      .take(3)
                                      .map((f) => f.name)
                                      .join(' • '),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurface.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ] else ...[
                              // Mobile: Compact chip layout
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  _buildDetailChip(
                                    icon: car.categoryIcon,
                                    label: car.category,
                                    backgroundColor: car.categoryColor
                                        .withOpacity(0.1),
                                    textColor: car.categoryColor,
                                  ),
                                  _buildDetailChip(
                                    icon: Icons.people_rounded,
                                    label: '${car.seats}',
                                    backgroundColor:
                                        colorScheme.secondaryContainer,
                                    textColor: colorScheme.onSecondaryContainer,
                                  ),
                                  _buildDetailChip(
                                    icon: car.transmissionIcon,
                                    label: car.transmission.substring(0, 1),
                                    backgroundColor:
                                        colorScheme.tertiaryContainer,
                                    textColor: colorScheme.onTertiaryContainer,
                                  ),
                                  _buildDetailChip(
                                    icon: car.fuelIcon,
                                    label: car.fuelType.substring(0, 1),
                                    backgroundColor:
                                        colorScheme.primaryContainer,
                                    textColor: colorScheme.onPrimaryContainer,
                                  ),
                                ],
                              ),
                            ],

                            const Spacer(),

                            // Price section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Daily Rate',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: colorScheme.onSurface
                                                  .withOpacity(0.6),
                                              fontSize: isDesktop ? 12 : 11,
                                            ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            car.displayPrice,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  color: colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: isDesktop ? 22 : 18,
                                                ),
                                          ),
                                          if (isDesktop) ...[
                                            const SizedBox(width: 4),
                                            Text(
                                              '/day',
                                              style: TextStyle(
                                                color: colorScheme.onSurface
                                                    .withOpacity(0.5),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (isDesktop &&
                                          car.reviewCount != null &&
                                          car.reviewCount! > 0)
                                        Text(
                                          '${car.reviewCount} reviews',
                                          style: TextStyle(
                                            color: colorScheme.onSurface
                                                .withOpacity(0.5),
                                            fontSize: 11,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Book Now Button
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  child: car.isAvailable
                                      ? FilledButton.icon(
                                          onPressed: () {
                                            HapticFeedback.lightImpact();
                                            showSeamlessPage(
                                              context,
                                              (context) => CarDetailsScreen(
                                                carId: car.id,
                                              ),
                                            );
                                          },
                                          style: FilledButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: isDesktop ? 24 : 20,
                                              vertical: isDesktop ? 14 : 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    isDesktop ? 16 : 12,
                                                  ),
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
                                                  BorderRadius.circular(
                                                    isDesktop ? 16 : 12,
                                                  ),
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
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1000;

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
            colorScheme.primary.withOpacity(0.08),
            colorScheme.secondary.withOpacity(0.08),
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
                color: colorScheme.surface.withOpacity(0.8),
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
                color: colorScheme.onSurface.withOpacity(0.6),
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
