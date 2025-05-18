import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tour_flutter_main/models/house_models.dart';
import 'package:tour_flutter_main/services/house_service.dart';
import 'package:tour_flutter_main/widgets/custom_button.dart';
import 'package:tour_flutter_main/widgets/modern_widgets.dart';
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
  RangeValues _bedroomsRange = const RangeValues(1, 5);
  String? _selectedDestination;

  bool _hasActiveFilters = false;
  List<String> _propertyTypes = [];
  List<String> _popularDestinations = [];

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
        minBedrooms: _bedroomsRange.start.round(),
        maxBedrooms: _bedroomsRange.end.round(),
        city: _selectedDestination?.split(',').first.trim(),
        country:
            _selectedDestination?.contains(',') == true
                ? _selectedDestination?.split(',').last.trim()
                : null,
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
          _bedroomsRange.start > 1 ||
          _bedroomsRange.end < 5 ||
          _selectedDestination != null;

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
      _bedroomsRange = const RangeValues(1, 5);
      _selectedDestination = null;
      _searchController.clear();
    });
    _fetchHouses(refresh: true);
    Navigator.pop(context);
  }

  void _applyFilters() {
    _fetchHouses(refresh: true);
    Navigator.pop(context);
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
                                '${_bedroomsRange.start.round()} - ${_bedroomsRange.end.round()}',
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
                            values: _bedroomsRange,
                            min: 1,
                            max: 5,
                            divisions: 4,
                            labels: RangeLabels(
                              '${_bedroomsRange.start.round()}',
                              '${_bedroomsRange.end.round()}',
                            ),
                            onChanged: (values) {
                              setModalState(() {
                                _bedroomsRange = values;
                              });
                            },
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
                                    selected:
                                        _selectedDestination == destination,
                                    onTap: () {
                                      setModalState(() {
                                        if (_selectedDestination ==
                                            destination) {
                                          _selectedDestination = null;
                                        } else {
                                          _selectedDestination = destination;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accommodations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: Implement favorites
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Favorites coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: ModernSearchField(
                    controller: _searchController,
                    hintText: 'Search accommodations...',
                    onSubmitted: (value) => _fetchHouses(refresh: true),
                  ),
                ),
                const SizedBox(width: 12),
                ModernFilterButton(
                  onPressed: _showFilterBottomSheet,
                  hasActiveFilters: _hasActiveFilters,
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
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.5),
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
                            onPressed: () => _resetFilters(),
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
          color: Theme.of(context).colorScheme.surface,
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
            // House image
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
                              color: Colors.grey[300],
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey[500],
                                ),
                              ),
                            );
                          },
                        )
                        : Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(
                              Icons.home_outlined,
                              size: 64,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                    // Property type badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: house.propertyTypeColor.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              house.propertyTypeIconData,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
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
                    // Rating badge
                    if (house.averageRating != null)
                      Positioned(
                        top: 12,
                        right: 12,
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
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
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

            // House info
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
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          house.displayLocation,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 13,
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
                      Icon(
                        Icons.king_bed_outlined,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        house.displayRooms,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${house.maxGuests} guests',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${house.nightlyRate.toStringAsFixed(0)}',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Text(
                            '/night',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      HouseDetailScreen(houseId: house.id),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('View'),
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
}
