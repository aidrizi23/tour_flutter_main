import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tour_flutter_main/models/recommendation_models.dart';
import 'package:tour_flutter_main/models/tour_models.dart';
import 'package:tour_flutter_main/screens/tours/tour_details_screen.dart';
import 'package:tour_flutter_main/services/recommendation_service.dart';
import 'package:tour_flutter_main/widgets/recommendation_widgets.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final RecommendationService _recommendationService = RecommendationService();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  List<RecommendedTour> _personalizedTours = [];
  List<TravelPackage> _trendingPackages = [];
  List<String> _popularDestinations = [];
  List<FlashDeal> _flashDeals = [];
  List<SeasonalOffer> _seasonalOffers = [];
  UserInsights? _userInsights;

  bool _isTourLoading = true;
  bool _isPackageLoading = true;
  bool _isDestinationLoading = true;
  bool _isDealLoading = true;
  bool _isOfferLoading = true;
  bool _isInsightLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
      _isTourLoading = true;
      _isPackageLoading = true;
      _isDestinationLoading = true;
      _isDealLoading = true;
      _isOfferLoading = true;
      _isInsightLoading = true;
    });

    // Load all recommendations in parallel
    await Future.wait([
      _loadPersonalizedTours(),
      _loadTrendingPackages(),
      _loadPopularDestinations(),
      _loadFlashDeals(),
      _loadSeasonalOffers(),
      _loadUserInsights(),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadPersonalizedTours() async {
    try {
      final recommendations =
          await _recommendationService.getPersonalizedTourRecommendations();
      if (mounted) {
        setState(() {
          _personalizedTours = recommendations;
          _isTourLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _personalizedTours = [];
          _isTourLoading = false;
        });
      }
    }
  }

  Future<void> _loadTrendingPackages() async {
    try {
      final packages = await _recommendationService.getTrendingPackages();
      if (mounted) {
        setState(() {
          _trendingPackages = packages;
          _isPackageLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _trendingPackages = [];
          _isPackageLoading = false;
        });
      }
    }
  }

  Future<void> _loadPopularDestinations() async {
    try {
      final destinations =
          await _recommendationService.getPopularDestinations();
      if (mounted) {
        setState(() {
          _popularDestinations = destinations;
          _isDestinationLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _popularDestinations = [];
          _isDestinationLoading = false;
        });
      }
    }
  }

  Future<void> _loadFlashDeals() async {
    try {
      final deals = await _recommendationService.getFlashDeals();
      if (mounted) {
        setState(() {
          _flashDeals = deals;
          _isDealLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _flashDeals = [];
          _isDealLoading = false;
        });
      }
    }
  }

  Future<void> _loadSeasonalOffers() async {
    try {
      final offers = await _recommendationService.getSeasonalOffers();
      if (mounted) {
        setState(() {
          _seasonalOffers = offers;
          _isOfferLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _seasonalOffers = [];
          _isOfferLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserInsights() async {
    try {
      final insights = await _recommendationService.getUserInsights();
      if (mounted) {
        setState(() {
          _userInsights = insights;
          _isInsightLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userInsights = null;
          _isInsightLoading = false;
        });
      }
    }
  }

  void _navigateToTourDetails(Tour tour) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TourDetailsScreen(tourId: tour.id),
      ),
    );
  }

  void _navigateToTravelPackageDetails(TravelPackage package) {
    // TODO: Navigate to package details screen once implemented
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Package details coming soon: ${package.name}'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _filterToursByDestination(String destination) {
    // TODO: Navigate to filtered tour list
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Showing tours in $destination'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleFlashDealTap(FlashDeal deal) {
    // TODO: Navigate to deal details or booking screen
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Flash deal selected: ${deal.name}'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleSeasonalOfferTap(SeasonalOffer offer) {
    // TODO: Navigate to offer details or booking screen
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Seasonal offer selected: ${offer.name}'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleViewMoreInsights() {
    // TODO: Navigate to detailed insights screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Detailed insights coming soon'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'For You',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh recommendations',
            onPressed: _loadRecommendations,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRecommendations,
        child:
            _isLoading &&
                    _personalizedTours.isEmpty &&
                    _trendingPackages.isEmpty &&
                    _flashDeals.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Finding perfect recommendations for you...',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
                : ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 40),
                  children: [
                    // User insights section - if available
                    if (_userInsights != null && !_isInsightLoading)
                      UserInsightsWidget(
                        insights: _userInsights!,
                        onViewMorePressed: _handleViewMoreInsights,
                      ),

                    // Flash deals section
                    SectionTitle(
                      title: 'Limited-Time Deals',
                      isLoading: _isDealLoading,
                      onSeeAllPressed:
                          _flashDeals.isNotEmpty
                              ? () {
                                // TODO: Navigate to all deals screen
                              }
                              : null,
                    ),
                    FlashDealsList(
                      deals: _flashDeals,
                      onDealTap: _handleFlashDealTap,
                      isLoading: _isDealLoading,
                      cardWidth: isMobile ? 280 : 320,
                    ),

                    // Personalized tours section
                    SectionTitle(
                      title: 'Recommended For You',
                      isLoading: _isTourLoading,
                      onSeeAllPressed:
                          _personalizedTours.isNotEmpty
                              ? () {
                                // TODO: Navigate to all recommended tours screen
                              }
                              : null,
                    ),
                    RecommendedToursList(
                      recommendations: _personalizedTours,
                      onTourTap: _navigateToTourDetails,
                      isLoading: _isTourLoading,
                      cardWidth: isMobile ? 280 : 320,
                    ),

                    // Popular destinations section
                    SectionTitle(
                      title: 'Popular Destinations',
                      isLoading: _isDestinationLoading,
                    ),
                    PopularDestinationsList(
                      destinations: _popularDestinations,
                      onDestinationTap: _filterToursByDestination,
                      isLoading: _isDestinationLoading,
                    ),

                    // Travel packages section
                    SectionTitle(
                      title: 'Trending Packages',
                      isLoading: _isPackageLoading,
                      onSeeAllPressed:
                          _trendingPackages.isNotEmpty
                              ? () {
                                // TODO: Navigate to all packages screen
                              }
                              : null,
                    ),
                    TravelPackagesList(
                      packages: _trendingPackages,
                      onPackageTap: _navigateToTravelPackageDetails,
                      isLoading: _isPackageLoading,
                      cardWidth: isMobile ? 300 : 350,
                    ),

                    // Seasonal offers section
                    SectionTitle(
                      title: 'Seasonal Offers',
                      isLoading: _isOfferLoading,
                      onSeeAllPressed:
                          _seasonalOffers.isNotEmpty
                              ? () {
                                // TODO: Navigate to all offers screen
                              }
                              : null,
                    ),
                    SeasonalOffersList(
                      offers: _seasonalOffers,
                      onOfferTap: _handleSeasonalOfferTap,
                      isLoading: _isOfferLoading,
                      cardWidth: isMobile ? 280 : 320,
                    ),
                  ],
                ),
      ),
    );
  }
}
