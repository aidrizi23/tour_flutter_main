import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/recommendation_models.dart';
import '../../models/tour_models.dart';
import '../../services/recommendation_service.dart';
import '../../widgets/recommendation_widgets.dart';
import '../tours/tour_details_screen.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen>
    with TickerProviderStateMixin {
  final RecommendationService _recommendationService = RecommendationService();
  final ScrollController _scrollController = ScrollController();

  // State variables for different recommendation types
  List<RecommendedTour> _personalizedTours = [];
  List<TravelPackage> _trendingPackages = [];
  List<String> _popularDestinations = [];
  List<FlashDeal> _flashDeals = [];
  List<SeasonalOffer> _seasonalOffers = [];
  UserInsights? _userInsights;

  // Loading states
  bool _isLoadingTours = true;
  bool _isLoadingPackages = true;
  bool _isLoadingDestinations = true;
  bool _isLoadingDeals = true;
  bool _isLoadingOffers = true;
  bool _isLoadingInsights = true;

  // Animation controllers
  late AnimationController _fadeInController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeInController, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Load recommendation data
    _loadRecommendations();

    // Start animations
    _fadeInController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRecommendations() async {
    // Load all recommendation data in parallel
    await Future.wait([
      _loadPersonalizedTours(),
      _loadTrendingPackages(),
      _loadPopularDestinations(),
      _loadFlashDeals(),
      _loadSeasonalOffers(),
      _loadUserInsights(),
    ]);
  }

  Future<void> _loadPersonalizedTours() async {
    try {
      final recommendations =
          await _recommendationService.getPersonalizedTourRecommendations();
      if (mounted) {
        setState(() {
          _personalizedTours = recommendations;
          _isLoadingTours = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _personalizedTours = [];
          _isLoadingTours = false;
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
          _isLoadingPackages = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _trendingPackages = [];
          _isLoadingPackages = false;
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
          _isLoadingDestinations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _popularDestinations = [];
          _isLoadingDestinations = false;
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
          _isLoadingDeals = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _flashDeals = [];
          _isLoadingDeals = false;
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
          _isLoadingOffers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _seasonalOffers = [];
          _isLoadingOffers = false;
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
          _isLoadingInsights = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userInsights = null;
          _isLoadingInsights = false;
        });
      }
    }
  }

  Future<void> _refreshRecommendations() async {
    setState(() {
      _isLoadingTours = true;
      _isLoadingPackages = true;
      _isLoadingDestinations = true;
      _isLoadingDeals = true;
      _isLoadingOffers = true;
      _isLoadingInsights = true;
    });

    await _loadRecommendations();
  }

  void _navigateToTourDetails(Tour tour) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TourDetailsScreen(tourId: tour.id),
      ),
    );
  }

  void _viewPackageDetails(TravelPackage package) {
    HapticFeedback.lightImpact();
    // TODO: Navigate to package details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Package details coming soon: ${package.name}'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _viewFlashDeal(FlashDeal deal) {
    HapticFeedback.lightImpact();
    // TODO: Navigate to appropriate screen based on deal type
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Flash deal details: ${deal.name}'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _viewSeasonalOffer(SeasonalOffer offer) {
    HapticFeedback.lightImpact();
    // TODO: Navigate to seasonal offer details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Seasonal offer details: ${offer.name}'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _exploreDestination(String destination) {
    HapticFeedback.lightImpact();
    // TODO: Navigate to a filtered tour list for this destination
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exploring: $destination'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _viewInsightsDetails() {
    HapticFeedback.lightImpact();
    // TODO: Navigate to detailed user insights screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Detailed travel insights coming soon!'),
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
    final cardWidth = isMobile ? 280.0 : 350.0;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For You',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 24 : 28,
              ),
            ),
            Text(
              'Personalized recommendations',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary.withOpacity(0.9),
                fontSize: isMobile ? 13 : 14,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _refreshRecommendations,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh recommendations',
          ),
        ],
        flexibleSpace: Container(
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
      body: RefreshIndicator(
        onRefresh: _refreshRecommendations,
        color: colorScheme.primary,
        backgroundColor: colorScheme.surface,
        strokeWidth: 3,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              children: [
                // User insights widget (if available)
                if (_userInsights != null && !_isLoadingInsights)
                  UserInsightsWidget(
                    insights: _userInsights!,
                    onViewMorePressed: _viewInsightsDetails,
                  )
                else if (!_isLoadingInsights)
                  const SizedBox(height: 16),

                // Flash deals section
                SectionTitle(title: 'Flash Deals', isLoading: _isLoadingDeals),
                FlashDealsList(
                  deals: _flashDeals,
                  onDealTap: _viewFlashDeal,
                  isLoading: _isLoadingDeals,
                  cardWidth: cardWidth,
                ),

                // Personalized tour recommendations
                SectionTitle(
                  title: 'Recommended for You',
                  isLoading: _isLoadingTours,
                ),
                RecommendedToursList(
                  recommendations: _personalizedTours,
                  onTourTap: (tour) => _navigateToTourDetails(tour),
                  isLoading: _isLoadingTours,
                  onRefresh: _loadPersonalizedTours,
                  cardWidth: cardWidth,
                ),

                // Popular destinations section
                SectionTitle(
                  title: 'Popular Destinations',
                  isLoading: _isLoadingDestinations,
                ),
                PopularDestinationsList(
                  destinations: _popularDestinations,
                  onDestinationTap: _exploreDestination,
                  isLoading: _isLoadingDestinations,
                ),

                // Trending packages section
                SectionTitle(
                  title: 'Trending Packages',
                  isLoading: _isLoadingPackages,
                ),
                TravelPackagesList(
                  packages: _trendingPackages,
                  onPackageTap: _viewPackageDetails,
                  isLoading: _isLoadingPackages,
                  cardWidth: cardWidth,
                ),

                // Seasonal offers section
                SectionTitle(
                  title: 'Seasonal Offers',
                  isLoading: _isLoadingOffers,
                ),
                SeasonalOffersList(
                  offers: _seasonalOffers,
                  onOfferTap: _viewSeasonalOffer,
                  isLoading: _isLoadingOffers,
                  cardWidth: cardWidth,
                ),

                // Bottom spacing
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
