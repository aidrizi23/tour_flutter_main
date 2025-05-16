import 'package:flutter/material.dart';
import '../../models/car_models.dart';
import '../../services/car_service.dart';
import '../../widgets/custom_text_field.dart';
import 'car_details_screen.dart';

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

  late AnimationController _fabAnimationController;
  late AnimationController _filterAnimationController;
  late Animation<double> _fabAnimation;
  late Animation<double> _filterAnimation;

  bool _showFilters = false;
  DateTime? _startDate;
  DateTime? _endDate;

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
    _loadCars();
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
        searchTerm:
            _searchController.text.isNotEmpty ? _searchController.text : null,
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
        pageSize: 10,
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
        searchTerm:
            _searchController.text.isNotEmpty ? _searchController.text : null,
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
        pageSize: 10,
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
    });
    _loadCars(isRefresh: true);
  }

  void _applyFilters() {
    _toggleFilters();
    _loadCars(isRefresh: true);
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
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Discover Cars',
                style: TextStyle(fontWeight: FontWeight.bold),
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
                icon: const Icon(Icons.tune_rounded),
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
                hint: 'Search cars, makes, models...',
                onSubmitted: (_) => _loadCars(isRefresh: true),
                onChanged: (value) {
                  // Debounce search
                  if (value.isEmpty) {
                    _loadCars(isRefresh: true);
                  }
                },
                showFilter: false,
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
                  ).animate(_filterAnimation),
                  child: _buildFiltersPanel(),
                ),
              ),
            ),

          // Results Count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '$_totalCount cars found',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ),

          // Cars Grid/List
          if (_isLoading && _cars.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Loading cars...',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _loadCars(isRefresh: true),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_cars.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 80,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No cars found',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your search or filters',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isDesktop || isTablet ? 0.85 : 1.1,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index < _cars.length) {
                    return _buildCarCard(_cars[index]);
                  } else if (_isLoadingMore) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }, childCount: _cars.length + (_isLoadingMore ? 1 : 0)),
              ),
            ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: () => _loadCars(isRefresh: true),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Refresh'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildFiltersPanel() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Rental Dates
          Text(
            'Rental Dates',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate:
                          _startDate ??
                          DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _startDate = date;
                        if (_endDate != null && _endDate!.isBefore(date)) {
                          _endDate = null;
                        }
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _startDate != null
                              ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                              : 'Start Date',
                          style: TextStyle(
                            color:
                                _startDate != null
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate:
                          _endDate ??
                          (_startDate?.add(const Duration(days: 1)) ??
                              DateTime.now().add(const Duration(days: 2))),
                      firstDate:
                          _startDate?.add(const Duration(days: 1)) ??
                          DateTime.now().add(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _endDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _endDate != null
                              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : 'End Date',
                          style: TextStyle(
                            color:
                                _endDate != null
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Make and Model
          Row(
            children: [
              Expanded(
                child: _buildDropdownFilter(
                  'Make',
                  _selectedMake,
                  _makes,
                  (value) => setState(() => _selectedMake = value),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller: TextEditingController(text: _selectedModel ?? ''),
                  label: 'Model',
                  onChanged:
                      (value) =>
                          _selectedModel = value.isNotEmpty ? value : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category and Transmission
          Row(
            children: [
              Expanded(
                child: _buildDropdownFilter(
                  'Category',
                  _selectedCategory,
                  CarService.categories,
                  (value) => setState(() => _selectedCategory = value),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownFilter(
                  'Transmission',
                  _selectedTransmission,
                  CarService.transmissionTypes,
                  (value) => setState(() => _selectedTransmission = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Fuel Type and Location
          Row(
            children: [
              Expanded(
                child: _buildDropdownFilter(
                  'Fuel Type',
                  _selectedFuelType,
                  CarService.fuelTypes,
                  (value) => setState(() => _selectedFuelType = value),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownFilter(
                  'Location',
                  _selectedLocation,
                  _locations,
                  (value) => setState(() => _selectedLocation = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Year Range
          Text(
            'Year Range',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: TextEditingController(
                    text: _minYear?.toString() ?? '',
                  ),
                  label: 'Min Year',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _minYear = int.tryParse(value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller: TextEditingController(
                    text: _maxYear?.toString() ?? '',
                  ),
                  label: 'Max Year',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _maxYear = int.tryParse(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Seats
          Text(
            'Number of Seats',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: TextEditingController(
                    text: _minSeats?.toString() ?? '',
                  ),
                  label: 'Min Seats',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _minSeats = int.tryParse(value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller: TextEditingController(
                    text: _maxSeats?.toString() ?? '',
                  ),
                  label: 'Max Seats',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _maxSeats = int.tryParse(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Price Range
          Text(
            'Daily Rate Range',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: TextEditingController(
                    text: _minPrice?.toString() ?? '',
                  ),
                  label: 'Min Price',
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
                    text: _maxPrice?.toString() ?? '',
                  ),
                  label: 'Max Price',
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
            CarService.sortOptions,
            (value) => setState(() => _sortBy = value!),
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
              ),
              const Text('Ascending order'),
            ],
          ),
          const SizedBox(height: 24),

          // Apply Filters Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
    Function(String?) onChanged, {
    bool showClearOption = true,
  }) {
    final allOptions = showClearOption ? ['', ...options] : options;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value ?? '',
              isExpanded: true,
              items:
                  allOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option.isEmpty ? 'All' : option),
                    );
                  }).toList(),
              onChanged: (newValue) {
                if (newValue == '') {
                  onChanged(null);
                } else {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarCard(Car car) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CarDetailsScreen(carId: car.id),
          ),
        );
      },
      child: Card(
        elevation: 6,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child:
                      car.mainImageUrl != null
                          ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            child: Image.network(
                              car.mainImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildImagePlaceholder();
                              },
                            ),
                          )
                          : _buildImagePlaceholder(),
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
                        color: Colors.black.withOpacity(0.8),
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
                          const SizedBox(width: 2),
                          Text(
                            car.averageRating!.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
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

            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Car name
                    Text(
                      car.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: colorScheme.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            car.location,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Car details chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildDetailChip(
                          icon: car.categoryIcon,
                          label: car.category,
                          backgroundColor: car.categoryColor.withOpacity(0.1),
                          textColor: car.categoryColor,
                        ),
                        _buildDetailChip(
                          icon: Icons.people_rounded,
                          label: '${car.seats} seats',
                          backgroundColor: colorScheme.secondaryContainer,
                          textColor: colorScheme.onSecondaryContainer,
                        ),
                        _buildDetailChip(
                          icon: car.transmissionIcon,
                          label: car.transmission,
                          backgroundColor: colorScheme.tertiaryContainer,
                          textColor: colorScheme.onTertiaryContainer,
                        ),
                        _buildDetailChip(
                          icon: car.fuelIcon,
                          label: car.fuelType,
                          backgroundColor: colorScheme.primaryContainer,
                          textColor: colorScheme.onPrimaryContainer,
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Price Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Rate',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            Text(
                              car.displayPrice,
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        // Book Now Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        CarDetailsScreen(carId: car.id),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
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

  Widget _buildImagePlaceholder() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      height: double.infinity,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car, size: 60, color: colorScheme.outline),
          const SizedBox(height: 8),
          Text('No Image', style: TextStyle(color: colorScheme.outline)),
        ],
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
        borderRadius: BorderRadius.circular(10),
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
