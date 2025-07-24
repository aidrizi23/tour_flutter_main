import 'package:flutter/material.dart';
import '../../models/tour_models.dart';
import '../../services/tour_service.dart';
import '../../widgets/responsive_tour_card.dart';
import '../../widgets/unified_list_screen.dart';
import '../../widgets/unified_filter_system.dart';

class TourListScreen extends StatelessWidget {
  const TourListScreen({super.key});

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

  @override
  String get screenTitle => 'Discover Tours';

  @override
  String get screenSubtitle => 'Find your perfect adventure';

  @override
  IconData get screenIcon => Icons.explore_rounded;

  @override
  String get itemTypeSingular => 'tour';

  @override
  String get itemTypePlural => 'experiences';

  @override
  String get searchHint => 'Where would you like to go?';

  @override
  String get emptyStateTitle => 'No tours found';

  @override
  String get emptyStateSubtitle => 'Try adjusting your search criteria or filters to find more options';

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
      category: filters?['category'],
      location: filters?['location'],
      difficultyLevel: filters?['difficulty'],
      activityType: filters?['activityType'],
      minPrice: filters?['minPrice'],
      maxPrice: filters?['maxPrice'],
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
    const QuickFilterOption(label: 'City Tours', value: 'City Tours'),
    const QuickFilterOption(label: 'Food & Drink', value: 'Food & Drink'),
  ];

  @override
  List<Widget> buildFilterSections(
    BuildContext context,
    Map<String, dynamic> currentFilters,
    Function(String, dynamic) onFilterChanged,
  ) {
    return [
      UnifiedDropdownFilter(
        title: 'Location',
        currentValue: currentFilters['location'],
        options: ['Any Location', ..._locations],
        defaultOption: 'Any Location',
        onChanged: (value) => onFilterChanged('location', value),
      ),
      UnifiedDropdownFilter(
        title: 'Activity Type',
        currentValue: currentFilters['activityType'],
        options: ['Any Activity', 'Indoor', 'Outdoor', 'Mixed'],
        defaultOption: 'Any Activity',
        onChanged: (value) => onFilterChanged('activityType', value),
      ),
      UnifiedDropdownFilter(
        title: 'Difficulty',
        currentValue: currentFilters['difficulty'],
        options: ['Any Difficulty', 'Easy', 'Moderate', 'Challenging'],
        defaultOption: 'Any Difficulty',
        onChanged: (value) => onFilterChanged('difficulty', value),
      ),
      UnifiedDropdownFilter(
        title: 'Sort By',
        currentValue: currentFilters['sortBy'] ?? 'created',
        options: ['created', 'name', 'price', 'rating', 'duration'],
        defaultOption: 'created',
        onChanged: (value) => onFilterChanged('sortBy', value),
      ),
    ];
  }

  @override
  Widget buildItemCard(BuildContext context, Tour tour, int index, bool isMobile, bool isTablet, bool isDesktop) {
    return ResponsiveTourCard(
      tour: tour,
      isDesktop: isDesktop,
      isTablet: isTablet,
      onFavoriteToggle: () => _toggleFavorite(tour),
      isFavorite: _isFavorite(tour),
    );
  }

  @override
  void onItemTapped(BuildContext context, Tour tour) {
    Navigator.pushNamed(
      context,
      '/tour-details',
      arguments: tour.id,
    );
  }

  // Local state for favorites (you might want to move this to a proper state management solution)
  static final List<Tour> _favoriteToursLocal = [];

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

}
