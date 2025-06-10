// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import '../../models/house_models.dart';
// import '../../services/house_service.dart';
// import 'house_detail_screen.dart';

// class HouseListScreenNew extends StatefulWidget {
//   const HouseListScreenNew({super.key});

//   @override
//   State<HouseListScreenNew> createState() => _HouseListScreenNewState();
// }

// class _HouseListScreenNewState extends State<HouseListScreenNew>
//     with TickerProviderStateMixin {
//   final HouseService _houseService = HouseService();
//   final TextEditingController _searchController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   late AnimationController _animationController;
//   late AnimationController _filterController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _filterAnimation;

//   List<House> _houses = [];
//   bool _isLoading = true;
//   bool _isLoadingMore = false;
//   bool _hasMoreData = true;
//   int _currentPage = 1;
//   final int _pageSize = 12;
//   String? _errorMessage;

//   // Filter variables
//   String? _selectedPropertyType;
//   RangeValues _priceRange = const RangeValues(0, 1000);
//   RangeValues _bedroomRange = const RangeValues(1, 5);
//   String? _selectedLocation;
//   DateTime? _checkInDate;
//   DateTime? _checkOutDate;
//   int _guestCount = 2;

//   bool _hasActiveFilters = false;
//   List<String> _propertyTypes = [];
//   List<String> _popularDestinations = [];
//   bool _showFilters = false;
//   bool _isSearchFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _filterController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );
    
//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     );
//     _filterAnimation = CurvedAnimation(
//       parent: _filterController,
//       curve: Curves.easeInOut,
//     );

//     _fetchHouses();
//     _loadFilterOptions();

//     _scrollController.addListener(_scrollListener);
//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _scrollController.dispose();
//     _animationController.dispose();
//     _filterController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadFilterOptions() async {
//     try {
//       final propertyTypes = await _houseService.getPropertyTypes();
//       final destinations = await _houseService.getPopularDestinations();

//       if (mounted) {
//         setState(() {
//           _propertyTypes = propertyTypes;
//           _popularDestinations = destinations;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error loading filter options: $e');
//       // Set default values if API fails
//       setState(() {
//         _propertyTypes = ['House', 'Apartment', 'Villa', 'Cottage'];
//         _popularDestinations = ['Santorini, Greece', 'Paris, France', 'Bali, Indonesia'];
//       });
//     }
//   }

//   void _scrollListener() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent * 0.8) {
//       if (_hasMoreData && !_isLoadingMore) {
//         _loadMoreHouses();
//       }
//     }
//   }

//   Future<void> _fetchHouses({bool refresh = false}) async {
//     try {
//       if (refresh) {
//         setState(() {
//           _isLoading = true;
//           _currentPage = 1;
//           _houses = [];
//           _errorMessage = null;
//         });
//       }

//       // Create filter with error handling
//       final filter = HouseFilterRequest(
//         searchTerm:
//             _searchController.text.isEmpty ? null : _searchController.text,
//         propertyType: _selectedPropertyType,
//         minPrice: _priceRange.start,
//         maxPrice: _priceRange.end >= 1000 ? null : _priceRange.end,
//         minBedrooms: _bedroomRange.start.round(),
//         maxBedrooms: _bedroomRange.end >= 5 ? null : _bedroomRange.end.round(),
//         city: _selectedLocation?.split(',').first.trim(),
//         country:
//             _selectedLocation?.contains(',') == true
//                 ? _selectedLocation?.split(',').last.trim()
//                 : null,
//         minGuests: _guestCount,
//         availableFrom: _checkInDate,
//         availableTo: _checkOutDate,
//         pageIndex: _currentPage,
//         pageSize: _pageSize,
//         sortBy: 'nightlyRate',
//         ascending: true,
//       );

//       // Update filter status
//       _hasActiveFilters =
//           _selectedPropertyType != null ||
//           _priceRange.start > 0 ||
//           _priceRange.end < 1000 ||
//           _bedroomRange.start > 1 ||
//           _bedroomRange.end < 5 ||
//           _selectedLocation != null ||
//           _checkInDate != null ||
//           _checkOutDate != null ||
//           _guestCount > 2 ||
//           _searchController.text.isNotEmpty;

//       final result = await _houseService.getHouses(filter: filter);

//       if (mounted) {
//         setState(() {
//           if (refresh || _currentPage == 1) {
//             _houses = result.items;
//           } else {
//             _houses.addAll(result.items);
//           }
//           _hasMoreData = result.hasNextPage;
//           _isLoading = false;
//           _errorMessage = null;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error fetching houses: $e');
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = _getErrorMessage(e);
//           // If this is the first load and it fails, show some dummy data for demo
//           if (_houses.isEmpty && _currentPage == 1) {
//             _houses = _createDummyHouses();
//           }
//         });
//       }
//     }
//   }

//   String _getErrorMessage(dynamic error) {
//     final errorString = error.toString().toLowerCase();
//     if (errorString.contains('network') || errorString.contains('connection')) {
//       return 'Please check your internet connection and try again';
//     } else if (errorString.contains('timeout')) {
//       return 'Request timed out. Please try again';
//     } else if (errorString.contains('server')) {
//       return 'Server error. Please try again later';
//     } else {
//       return 'Unable to load properties. Showing sample data.';
//     }
//   }

//   List<House> _createDummyHouses() {
//     return [
//       House(
//         id: 1,
//         name: 'Beautiful Villa in Santorini',
//         description: 'Stunning villa with ocean views and private pool. Perfect for families and couples looking for a luxurious getaway.',
//         city: 'Santorini',
//         country: 'Greece',
//         address: 'Oia, Santorini, Greece',
//         latitude: 36.4618,
//         longitude: 25.3753,
//         nightlyRate: 350.0,
//         cleaningFee: 50.0,
//         serviceFee: 25.0,
//         propertyType: 'Villa',
//         bedrooms: 3,
//         bathrooms: 2,
//         maxGuests: 6,
//         hasWifi: true,
//         hasKitchen: true,
//         hasParking: true,
//         hasPets: false,
//         hasPool: true,
//         hasAirConditioning: true,
//         mainImageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
//         isActive: true,
//         createdAt: DateTime.now().subtract(const Duration(days: 30)),
//         images: [],
//         features: [],
//         averageRating: 4.8,
//         reviewCount: 124,
//       ),
//       House(
//         id: 2,
//         name: 'Modern Apartment in Paris',
//         description: 'Stylish apartment in the heart of Paris, walking distance to major attractions.',
//         city: 'Paris',
//         country: 'France',
//         address: 'Marais District, Paris, France',
//         latitude: 48.8566,
//         longitude: 2.3522,
//         nightlyRate: 180.0,
//         cleaningFee: 30.0,
//         serviceFee: 15.0,
//         propertyType: 'Apartment',
//         bedrooms: 2,
//         bathrooms: 1,
//         maxGuests: 4,
//         hasWifi: true,
//         hasKitchen: true,
//         hasParking: false,
//         hasPets: false,
//         hasPool: false,
//         hasAirConditioning: true,
//         mainImageUrl: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
//         isActive: true,
//         createdAt: DateTime.now().subtract(const Duration(days: 20)),
//         images: [],
//         features: [],
//         averageRating: 4.6,
//         reviewCount: 89,
//       ),
//       House(
//         id: 3,
//         name: 'Cozy Cottage in Bali',
//         description: 'Traditional cottage surrounded by rice fields and tropical gardens.',
//         city: 'Ubud',
//         country: 'Indonesia',
//         address: 'Ubud, Bali, Indonesia',
//         latitude: -8.5069,
//         longitude: 115.2625,
//         nightlyRate: 95.0,
//         cleaningFee: 20.0,
//         serviceFee: 10.0,
//         propertyType: 'Cottage',
//         bedrooms: 1,
//         bathrooms: 1,
//         maxGuests: 2,
//         hasWifi: true,
//         hasKitchen: true,
//         hasParking: true,
//         hasPets: true,
//         hasPool: false,
//         hasAirConditioning: false,
//         mainImageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
//         isActive: true,
//         createdAt: DateTime.now().subtract(const Duration(days: 15)),
//         images: [],
//         features: [],
//         averageRating: 4.9,
//         reviewCount: 67,
//       ),
//     ];
//   }

//   Future<void> _loadMoreHouses() async {
//     if (_isLoadingMore || !_hasMoreData) return;

//     setState(() {
//       _isLoadingMore = true;
//       _currentPage++;
//     });

//     try {
//       final filter = HouseFilterRequest(
//         searchTerm:
//             _searchController.text.isEmpty ? null : _searchController.text,
//         propertyType: _selectedPropertyType,
//         minPrice: _priceRange.start,
//         maxPrice: _priceRange.end >= 1000 ? null : _priceRange.end,
//         minBedrooms: _bedroomRange.start.round(),
//         maxBedrooms: _bedroomRange.end >= 5 ? null : _bedroomRange.end.round(),
//         city: _selectedLocation?.split(',').first.trim(),
//         country:
//             _selectedLocation?.contains(',') == true
//                 ? _selectedLocation?.split(',').last.trim()
//                 : null,
//         minGuests: _guestCount,
//         availableFrom: _checkInDate,
//         availableTo: _checkOutDate,
//         pageIndex: _currentPage,
//         pageSize: _pageSize,
//         sortBy: 'nightlyRate',
//         ascending: true,
//       );

//       final result = await _houseService.getHouses(filter: filter);

//       if (mounted) {
//         setState(() {
//           _houses.addAll(result.items);
//           _hasMoreData = result.hasNextPage;
//           _isLoadingMore = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoadingMore = false;
//           _currentPage--;
//         });
//       }
//     }
//   }

//   void _toggleFilters() {
//     setState(() {
//       _showFilters = !_showFilters;
//     });
    
//     if (_showFilters) {
//       _filterController.forward();
//     } else {
//       _filterController.reverse();
//     }
//   }

//   void _clearFilters() {
//     setState(() {
//       _selectedPropertyType = null;
//       _priceRange = const RangeValues(0, 1000);
//       _bedroomRange = const RangeValues(1, 5);
//       _selectedLocation = null;
//       _checkInDate = null;
//       _checkOutDate = null;
//       _guestCount = 2;
//       _searchController.clear();
//       _hasActiveFilters = false;
//     });
//     _fetchHouses(refresh: true);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isDesktop = screenWidth > 1200;
//     final isTablet = screenWidth > 600 && screenWidth <= 1200;

//     return Scaffold(
//       backgroundColor: colorScheme.surfaceContainerLowest,
//       body: RefreshIndicator(
//         onRefresh: () => _fetchHouses(refresh: true),
//         child: CustomScrollView(
//           controller: _scrollController,
//           slivers: [
//             // Modern App Bar
//             SliverAppBar(
//               floating: true,
//               snap: true,
//               elevation: 0,
//               backgroundColor: colorScheme.primary,
//               foregroundColor: colorScheme.onPrimary,
//               expandedHeight: 200,
//               flexibleSpace: FlexibleSpaceBar(
//                 background: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         colorScheme.primary,
//                         colorScheme.primary.withValues(alpha: 0.8),
//                       ],
//                     ),
//                   ),
//                   child: SafeArea(
//                     child: Padding(
//                       padding: const EdgeInsets.all(24),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Find Your Perfect Stay',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .headlineLarge
//                                           ?.copyWith(
//                                             color: colorScheme.onPrimary,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       _houses.isNotEmpty
//                                           ? '${_houses.length}+ amazing properties'
//                                           : 'Discover unique accommodations',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodyLarge
//                                           ?.copyWith(
//                                             color: colorScheme.onPrimary
//                                                 .withValues(alpha: 0.9),
//                                           ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Container(
//                                 padding: const EdgeInsets.all(16),
//                                 decoration: BoxDecoration(
//                                   color: colorScheme.onPrimary.withValues(alpha: 0.2),
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Icon(
//                                   Icons.home_rounded,
//                                   color: colorScheme.onPrimary,
//                                   size: 32,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             // Search Section
//             SliverToBoxAdapter(
//               child: FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: Container(
//                   margin: const EdgeInsets.all(16),
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: colorScheme.surface,
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: colorScheme.shadow.withValues(alpha: 0.1),
//                         blurRadius: 20,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: _buildSearchSection(colorScheme),
//                 ),
//               ),
//             ),

//             // Error message
//             if (_errorMessage != null)
//               SliverToBoxAdapter(
//                 child: Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 16),
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: colorScheme.errorContainer.withValues(alpha: 0.1),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: colorScheme.error.withValues(alpha: 0.3),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.info_outline_rounded,
//                         color: colorScheme.error,
//                         size: 20,
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           _errorMessage!,
//                           style: TextStyle(
//                             color: colorScheme.error,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//             // Filters Panel
//             if (_showFilters)
//               SliverToBoxAdapter(
//                 child: FadeTransition(
//                   opacity: _filterAnimation,
//                   child: _buildFiltersPanel(colorScheme),
//                 ),
//               ),

//             // Content
//             if (_isLoading && _houses.isEmpty)
//               SliverFillRemaining(child: _buildLoadingState(colorScheme))
//             else if (_houses.isEmpty)
//               SliverFillRemaining(child: _buildEmptyState(colorScheme))
//             else
//               _buildHousesGrid(isDesktop, isTablet, colorScheme),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchSection(ColorScheme colorScheme) {
//     return Column(
//       children: [
//         // Search bar
//         Focus(
//           onFocusChange: (hasFocus) {
//             setState(() {
//               _isSearchFocused = hasFocus;
//             });
//           },
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             decoration: BoxDecoration(
//               color: colorScheme.surfaceContainerLow,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: _isSearchFocused
//                     ? colorScheme.primary
//                     : colorScheme.outline.withValues(alpha: 0.2),
//                 width: _isSearchFocused ? 2 : 1,
//               ),
//             ),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search for cities, countries, or properties...',
//                 hintStyle: TextStyle(
//                   color: colorScheme.onSurface.withValues(alpha: 0.6),
//                 ),
//                 prefixIcon: Icon(
//                   Icons.search_rounded,
//                   color: _isSearchFocused
//                       ? colorScheme.primary
//                       : colorScheme.outline,
//                 ),
//                 suffixIcon: _searchController.text.isNotEmpty
//                     ? IconButton(
//                         onPressed: () {
//                           _searchController.clear();
//                           _fetchHouses(refresh: true);
//                         },
//                         icon: Icon(
//                           Icons.clear_rounded,
//                           color: colorScheme.outline,
//                         ),
//                       )
//                     : null,
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 16,
//                 ),
//               ),
//               onSubmitted: (_) => _fetchHouses(refresh: true),
//             ),
//           ),
//         ),

//         const SizedBox(height: 20),

//         // Quick actions row
//         Row(
//           children: [
//             Expanded(
//               child: _buildQuickAction(
//                 'Filters',
//                 Icons.tune_rounded,
//                 _toggleFilters,
//                 colorScheme,
//                 isActive: _showFilters,
//               ),
//             ),
//             const SizedBox(width: 12),
//             if (_hasActiveFilters)
//               Expanded(
//                 child: _buildQuickAction(
//                   'Clear',
//                   Icons.clear_all_rounded,
//                   _clearFilters,
//                   colorScheme,
//                 ),
//               ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildQuickAction(
//     String label,
//     IconData icon,
//     VoidCallback onTap,
//     ColorScheme colorScheme, {
//     bool isActive = false,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () {
//           HapticFeedback.lightImpact();
//           onTap();
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           decoration: BoxDecoration(
//             color: isActive
//                 ? colorScheme.primary.withValues(alpha: 0.1)
//                 : colorScheme.surfaceContainer,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: isActive
//                   ? colorScheme.primary
//                   : colorScheme.outline.withValues(alpha: 0.2),
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 size: 18,
//                 color: isActive ? colorScheme.primary : colorScheme.onSurface,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: isActive ? colorScheme.primary : colorScheme.onSurface,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFiltersPanel(ColorScheme colorScheme) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: colorScheme.shadow.withValues(alpha: 0.15),
//             blurRadius: 20,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Filter Properties',
//             style: Theme.of(context)
//                 .textTheme
//                 .titleLarge
//                 ?.copyWith(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 20),
//           Wrap(
//             spacing: 16,
//             runSpacing: 16,
//             children: [
//               _buildPropertyTypeFilter(),
//               _buildLocationFilter(),
//               _buildPriceRangeFilter(),
//               _buildBedroomFilter(),
//               _buildGuestCountFilter(),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPropertyTypeFilter() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Property Type', style: TextStyle(fontWeight: FontWeight.w600)),
//         const SizedBox(height: 8),
//         Wrap(
//           spacing: 8,
//           children: _propertyTypes.map((type) {
//             final isSelected = _selectedPropertyType == type;
//             return FilterChip(
//               label: Text(type),
//               selected: isSelected,
//               onSelected: (selected) {
//                 setState(() {
//                   _selectedPropertyType = selected ? type : null;
//                 });
//               },
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildLocationFilter() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Popular Destinations', style: TextStyle(fontWeight: FontWeight.w600)),
//         const SizedBox(height: 8),
//         Wrap(
//           spacing: 8,
//           children: _popularDestinations.map((destination) {
//             final isSelected = _selectedLocation == destination;
//             return FilterChip(
//               label: Text(destination),
//               selected: isSelected,
//               onSelected: (selected) {
//                 setState(() {
//                   _selectedLocation = selected ? destination : null;
//                 });
//               },
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildPriceRangeFilter() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Price Range: \$${_priceRange.start.round()} - \$${_priceRange.end.round() >= 1000 ? '1000+' : _priceRange.end.round()}',
//           style: const TextStyle(fontWeight: FontWeight.w600),
//         ),
//         RangeSlider(
//           values: _priceRange,
//           min: 0,
//           max: 1000,
//           divisions: 20,
//           onChanged: (values) {
//             setState(() {
//               _priceRange = values;
//             });
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildBedroomFilter() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Bedrooms: ${_bedroomRange.start.round()} - ${_bedroomRange.end.round() >= 5 ? '5+' : _bedroomRange.end.round()}',
//           style: const TextStyle(fontWeight: FontWeight.w600),
//         ),
//         RangeSlider(
//           values: _bedroomRange,
//           min: 1,
//           max: 5,
//           divisions: 4,
//           onChanged: (values) {
//             setState(() {
//               _bedroomRange = values;
//             });
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildGuestCountFilter() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Guests: $_guestCount',
//           style: const TextStyle(fontWeight: FontWeight.w600),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             IconButton(
//               onPressed: _guestCount > 1
//                   ? () => setState(() => _guestCount--)
//                   : null,
//               icon: const Icon(Icons.remove),
//             ),
//             Text('$_guestCount'),
//             IconButton(
//               onPressed: _guestCount < 10
//                   ? () => setState(() => _guestCount++)
//                   : null,
//               icon: const Icon(Icons.add),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildHousesGrid(bool isDesktop, bool isTablet, ColorScheme colorScheme) {
//     final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);
//     final childAspectRatio = isDesktop ? 0.75 : (isTablet ? 0.8 : 1.2);

//     return SliverPadding(
//       padding: const EdgeInsets.all(16),
//       sliver: SliverGrid(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: crossAxisCount,
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//           childAspectRatio: childAspectRatio,
//         ),
//         delegate: SliverChildBuilderDelegate(
//           (context, index) {
//             if (index < _houses.length) {
//               return _buildHouseCard(_houses[index], colorScheme);
//             } else if (_isLoadingMore) {
//               return _buildLoadingMoreCard(colorScheme);
//             }
//             return null;
//           },
//           childCount: _houses.length + (_isLoadingMore ? 1 : 0),
//         ),
//       ),
//     );
//   }

//   Widget _buildHouseCard(House house, ColorScheme colorScheme) {
//     return Hero(
//       tag: 'house_${house.id}',
//       child: Card(
//         clipBehavior: Clip.antiAlias,
//         elevation: 4,
//         shadowColor: colorScheme.shadow.withValues(alpha: 0.15),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: () {
//               HapticFeedback.mediumImpact();
//               Navigator.of(context).push(
//                 PageRouteBuilder(
//                   pageBuilder: (context, animation, secondaryAnimation) =>
//                       HouseDetailScreen(houseId: house.id),
//                   transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                     return SlideTransition(
//                       position: Tween<Offset>(
//                         begin: const Offset(1.0, 0.0),
//                         end: Offset.zero,
//                       ).animate(
//                         CurvedAnimation(
//                           parent: animation,
//                           curve: Curves.easeOutCubic,
//                         ),
//                       ),
//                       child: FadeTransition(
//                         opacity: animation,
//                         child: child,
//                       ),
//                     );
//                   },
//                   transitionDuration: const Duration(milliseconds: 400),
//                 ),
//               );
//             },
//             borderRadius: BorderRadius.circular(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Image section
//                 Stack(
//                   children: [
//                     Container(
//                       height: 200,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: colorScheme.surfaceContainer,
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(20),
//                           topRight: Radius.circular(20),
//                         ),
//                       ),
//                       child: house.mainImageUrl != null && house.mainImageUrl!.isNotEmpty
//                           ? ClipRRect(
//                               borderRadius: const BorderRadius.only(
//                                 topLeft: Radius.circular(20),
//                                 topRight: Radius.circular(20),
//                               ),
//                               child: Image.network(
//                                 house.mainImageUrl!,
//                                 fit: BoxFit.cover,
//                                 width: double.infinity,
//                                 height: double.infinity,
//                                 errorBuilder: (context, error, stackTrace) =>
//                                     _buildImagePlaceholder(colorScheme),
//                                 loadingBuilder: (context, child, loadingProgress) {
//                                   if (loadingProgress == null) return child;
//                                   return Center(
//                                     child: CircularProgressIndicator(
//                                       value: loadingProgress.expectedTotalBytes != null
//                                           ? loadingProgress.cumulativeBytesLoaded /
//                                               loadingProgress.expectedTotalBytes!
//                                           : null,
//                                       strokeWidth: 2,
//                                       color: colorScheme.primary,
//                                     ),
//                                   );
//                                 },
//                               ),
//                             )
//                           : _buildImagePlaceholder(colorScheme),
//                     ),

//                     // Rating badge
//                     if (house.averageRating != null)
//                       Positioned(
//                         top: 12,
//                         left: 12,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.black54,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               const Icon(
//                                 Icons.star_rounded,
//                                 color: Colors.amber,
//                                 size: 14,
//                               ),
//                               const SizedBox(width: 4),
//                               Text(
//                                 house.averageRating!.toStringAsFixed(1),
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),

//                     // Property type badge
//                     Positioned(
//                       bottom: 12,
//                       left: 12,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: colorScheme.primary,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           house.propertyType,
//                           style: TextStyle(
//                             color: colorScheme.onPrimary,
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 // Content section
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // House name
//                         Text(
//                           house.name,
//                           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             height: 1.2,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),

//                         const SizedBox(height: 8),

//                         // Location
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.location_on_rounded,
//                               color: colorScheme.primary,
//                               size: 16,
//                             ),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 '${house.city}, ${house.country}',
//                                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                                   color: colorScheme.onSurface.withValues(alpha: 0.7),
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 12),

//                         // Details row
//                         Row(
//                           children: [
//                             _buildDetailChip(
//                               Icons.bed_rounded,
//                               '${house.bedrooms} bed',
//                               colorScheme,
//                             ),
//                             const SizedBox(width: 8),
//                             _buildDetailChip(
//                               Icons.people_rounded,
//                               '${house.maxGuests} guests',
//                               colorScheme,
//                             ),
//                           ],
//                         ),

//                         const Spacer(),

//                         // Price and book button
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   '\$${house.nightlyRate.toStringAsFixed(0)}',
//                                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                                     color: colorScheme.primary,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 Text(
//                                   'per night',
//                                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                                     color: colorScheme.onSurface.withValues(alpha: 0.6),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             FilledButton(
//                               onPressed: () {
//                                 HapticFeedback.lightImpact();
//                                 Navigator.of(context).push(
//                                   PageRouteBuilder(
//                                     pageBuilder: (context, animation, secondaryAnimation) =>
//                                         HouseDetailScreen(houseId: house.id),
//                                     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                                       return SlideTransition(
//                                         position: Tween<Offset>(
//                                           begin: const Offset(1.0, 0.0),
//                                           end: Offset.zero,
//                                         ).animate(
//                                           CurvedAnimation(
//                                             parent: animation,
//                                             curve: Curves.easeOutCubic,
//                                           ),
//                                         ),
//                                         child: FadeTransition(
//                                           opacity: animation,
//                                           child: child,
//                                         ),
//                                       );
//                                     },
//                                     transitionDuration: const Duration(milliseconds: 400),
//                                   ),
//                                 );
//                               },
//                               style: FilledButton.styleFrom(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 12,
//                                   vertical: 8,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               child: const Text(
//                                 'View',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailChip(IconData icon, String label, ColorScheme colorScheme) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: colorScheme.surfaceContainer,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 12, color: colorScheme.onSurface.withValues(alpha: 0.7)),
//           const SizedBox(width: 4),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w500,
//               color: colorScheme.onSurface.withValues(alpha: 0.7),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildImagePlaceholder(ColorScheme colorScheme) {
//     return Container(
//       decoration: BoxDecoration(
//         color: colorScheme.surfaceContainer,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.home_rounded,
//               size: 48,
//               color: colorScheme.outline,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'No image',
//               style: TextStyle(
//                 color: colorScheme.onSurface.withValues(alpha: 0.6),
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLoadingMoreCard(ColorScheme colorScheme) {
//     return Card(
//       child: Container(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(
//               color: colorScheme.primary,
//               strokeWidth: 2,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Loading more...',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: colorScheme.onSurface.withValues(alpha: 0.7),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLoadingState(ColorScheme colorScheme) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(32),
//             decoration: BoxDecoration(
//               color: colorScheme.surface,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Column(
//               children: [
//                 CircularProgressIndicator(
//                   color: colorScheme.primary,
//                   strokeWidth: 3,
//                 ),
//                 const SizedBox(height: 24),
//                 Text(
//                   'Finding amazing properties...',
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     color: colorScheme.onSurface.withValues(alpha: 0.7),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState(ColorScheme colorScheme) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Container(
//           padding: const EdgeInsets.all(32),
//           decoration: BoxDecoration(
//             color: colorScheme.surface,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   color: colorScheme.surfaceContainerLow,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Icon(
//                   Icons.home_off_rounded,
//                   size: 48,
//                   color: colorScheme.outline,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 'No properties found',
//                 style: Theme.of(context)
//                     .textTheme
//                     .headlineSmall
//                     ?.copyWith(fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Try adjusting your search criteria or filters',
//                 style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                   color: colorScheme.onSurface.withValues(alpha: 0.7),
//                   height: 1.5,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 32),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   OutlinedButton.icon(
//                     onPressed: _clearFilters,
//                     icon: const Icon(Icons.clear_all_rounded),
//                     label: const Text('Clear Filters'),
//                   ),
//                   const SizedBox(width: 16),
//                   FilledButton.icon(
//                     onPressed: () => _fetchHouses(refresh: true),
//                     icon: const Icon(Icons.refresh_rounded),
//                     label: const Text('Refresh'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }