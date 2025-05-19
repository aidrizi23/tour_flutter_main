import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../models/recommendation_models.dart';
import '../../models/tour_models.dart';
import '../../services/recommendation_service.dart';
import '../../widgets/recommendation_widgets.dart';
import '../../widgets/modern_widgets.dart';
import '../tours/tour_details_screen.dart';
import '../tours/tour_list_screen.dart';

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

  // Error states
  String? _toursError;
  String? _packagesError;
  String? _destinationsError;
  String? _dealsError;
  String? _offersError;
  String? _insightsError;

  // Animation controllers
  late AnimationController _fadeInController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Hero section animation
  late AnimationController _heroAnimationController;
  late Animation<double> _heroScaleAnimation;
  late Animation<double> _heroOpacityAnimation;

  // Refresh indicator key
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // Connection state
  bool _isOffline = false;
  Timer? _connectionCheckTimer;

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
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Hero section animation
    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _heroScaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _heroAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _heroOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _heroAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Load recommendation data
    _loadRecommendations();

    // Start animations
    _fadeInController.forward();
    _slideController.forward();
    _heroAnimationController.forward();

    // Set up periodic connection checker
    _connectionCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkConnection(),
    );

    // Initial connection check
    _checkConnection();
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _slideController.dispose();
    _heroAnimationController.dispose();
    _scrollController.dispose();
    _connectionCheckTimer?.cancel();
    super.dispose();
  }

  // Check internet connection
  Future<void> _checkConnection() async {
    try {
      // Simple API call to check connection
      final isConnected = await _recommendationService.checkConnection();
      if (mounted) {
        setState(() {
          _isOffline = !isConnected;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isOffline = true;
        });
      }
    }
  }

  Future<void> _loadRecommendations() async {
    // Reset error states
    setState(() {
      _toursError = null;
      _packagesError = null;
      _destinationsError = null;
      _dealsError = null;
      _offersError = null;
      _insightsError = null;
    });

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
      if (mounted) {
        setState(() {
          _isLoadingTours = true;
          _toursError = null;
        });
      }

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
          _toursError =
              'Unable to load recommended tours: ${e.toString().replaceAll('Exception: ', '')}';
        });
      }
    }
  }

  Future<void> _loadTrendingPackages() async {
    try {
      if (mounted) {
        setState(() {
          _isLoadingPackages = true;
          _packagesError = null;
        });
      }

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
          _packagesError =
              'Unable to load packages: ${e.toString().replaceAll('Exception: ', '')}';
        });
      }
    }
  }

  Future<void> _loadPopularDestinations() async {
    try {
      if (mounted) {
        setState(() {
          _isLoadingDestinations = true;
          _destinationsError = null;
        });
      }

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
          _destinationsError =
              'Unable to load destinations: ${e.toString().replaceAll('Exception: ', '')}';
        });
      }
    }
  }

  Future<void> _loadFlashDeals() async {
    try {
      if (mounted) {
        setState(() {
          _isLoadingDeals = true;
          _dealsError = null;
        });
      }

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
          _dealsError =
              'Unable to load flash deals: ${e.toString().replaceAll('Exception: ', '')}';
        });
      }
    }
  }

  Future<void> _loadSeasonalOffers() async {
    try {
      if (mounted) {
        setState(() {
          _isLoadingOffers = true;
          _offersError = null;
        });
      }

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
          _offersError =
              'Unable to load seasonal offers: ${e.toString().replaceAll('Exception: ', '')}';
        });
      }
    }
  }

  Future<void> _loadUserInsights() async {
    try {
      if (mounted) {
        setState(() {
          _isLoadingInsights = true;
          _insightsError = null;
        });
      }

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
          _insightsError =
              'Unable to load travel insights: ${e.toString().replaceAll('Exception: ', '')}';
        });
      }
    }
  }

  Future<void> _refreshRecommendations() async {
    HapticFeedback.mediumImpact();

    // Check connection first
    await _checkConnection();

    if (_isOffline) {
      // Show offline snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'You appear to be offline. Please check your connection.',
          ),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              _refreshIndicatorKey.currentState?.show();
            },
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoadingTours = true;
      _isLoadingPackages = true;
      _isLoadingDestinations = true;
      _isLoadingDeals = true;
      _isLoadingOffers = true;
      _isLoadingInsights = true;
    });

    await _loadRecommendations();

    // Show a success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Recommendations refreshed'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  void _navigateToTourDetails(Tour tour) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TourDetailsScreen(tourId: tour.id),
      ),
    ).then((_) {
      // Refresh recommendations when returning to this screen
      _loadPersonalizedTours();
    });
  }

  void _viewPackageDetails(TravelPackage package) {
    HapticFeedback.lightImpact();

    // Extract the actual tours so they can be viewed
    if (package.tours.isNotEmpty) {
      final tour = package.tours.first;

      // Show package info dialog before navigating
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text('Package: ${package.name}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(package.description),
                    const SizedBox(height: 16),
                    Text(
                      'Includes: ${package.tours.length} tours and ${package.houses.length} accommodations',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Location: ${package.location}'),
                    Text('Date: ${package.dateRange}'),
                    Text('Price: ${package.displayPrice}'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => TourDetailsScreen(tourId: tour.tourId),
                      ),
                    );
                  },
                  child: const Text('VIEW FIRST TOUR'),
                ),
              ],
            ),
      );
    } else {
      // If no tours, just show info
      ModernSnackBar.show(
        context,
        message: 'This package has no available tours to view at this time.',
        type: SnackBarType.info,
      );
    }
  }

  void _viewFlashDeal(FlashDeal deal) {
    HapticFeedback.lightImpact();

    // Show deal info with countdown
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Flash deal header
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        deal.getTypeColor().withOpacity(0.9),
                        deal.getTypeColor().withOpacity(0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flash_on,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'FLASH DEAL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              deal.displayDiscount,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        deal.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.white.withOpacity(0.9),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            deal.location,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              deal.isExpiringSoon
                                  ? Colors.red.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ends in: ${deal.timeRemaining}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Deal content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (deal.imageUrl != null)
                          Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                deal.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      color: deal.getTypeColor().withOpacity(
                                        0.1,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 40,
                                          color: deal
                                              .getTypeColor()
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Description
                        Text(
                          'About this Deal',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          deal.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),

                        const SizedBox(height: 24),

                        // Price
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      deal.displayDiscountedPrice,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      deal.displayOriginalPrice,
                                      style: TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.5),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Book now button
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // For demonstration, navigate to tour list filtered by location
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TourListScreen(),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'BOOK NOW',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

  void _viewSeasonalOffer(SeasonalOffer offer) {
    HapticFeedback.lightImpact();

    // Show offer info in a dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: EdgeInsets.zero,
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Season header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          offer.getSeasonColor().withOpacity(0.9),
                          offer.getSeasonColor().withOpacity(0.7),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          offer.getSeasonIcon(),
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${offer.season} Special',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Offer content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Theme.of(context).colorScheme.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              offer.location,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          offer.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: offer.getSeasonColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: offer.getSeasonColor().withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star_outline,
                                color: offer.getSeasonColor(),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  offer.seasonalHighlight,
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                                Text(
                                  offer.displayPrice,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            if (offer.hasDiscount)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  offer.displayDiscount,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
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
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  // For demonstration, navigate to tour list filtered by location
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TourListScreen(),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: offer.getSeasonColor(),
                ),
                child: const Text('EXPLORE'),
              ),
            ],
          ),
    );
  }

  void _exploreDestination(String destination) {
    HapticFeedback.lightImpact();

    // Navigate to a filtered tour list for this destination
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TourListScreen()),
    );
  }

  void _viewInsightsDetails() {
    HapticFeedback.lightImpact();

    // Show insights detail in bottom sheet
    if (_userInsights != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (context) => Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Insights header
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primaryContainer,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.insights_rounded,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Travel Insights',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  'Based on your travel history',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Insights content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInsightDetailCard(
                            context: context,
                            title: 'Travel Profile',
                            icon: Icons.person,
                            children: [
                              _buildInsightItem(
                                context: context,
                                title: 'Most Visited',
                                value: _userInsights!.mostVisitedDestination,
                                icon: Icons.location_city_outlined,
                              ),
                              _buildInsightItem(
                                context: context,
                                title: 'Favorite Category',
                                value: _userInsights!.favoriteTourCategory,
                                icon: Icons.category_outlined,
                              ),
                              _buildInsightItem(
                                context: context,
                                title: 'Total Trips',
                                value: _userInsights!.totalTrips.toString(),
                                icon: Icons.card_travel_outlined,
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          _buildInsightDetailCard(
                            context: context,
                            title: 'Trip Metrics',
                            icon: Icons.analytics_outlined,
                            children: [
                              _buildInsightItem(
                                context: context,
                                title: 'Average Duration',
                                value:
                                    '${_userInsights!.averageTripDuration} days',
                                icon: Icons.calendar_today_outlined,
                              ),
                              _buildInsightItem(
                                context: context,
                                title: 'Total Spent',
                                value:
                                    '\$${_userInsights!.totalSpent.toStringAsFixed(2)}',
                                icon: Icons.attach_money_outlined,
                              ),
                              _buildInsightItem(
                                context: context,
                                title: 'Total Savings',
                                value:
                                    '\$${_userInsights!.totalSavings.toStringAsFixed(2)}',
                                icon: Icons.savings_outlined,
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Recommendations based on insights
                          _buildInsightDetailCard(
                            context: context,
                            title: 'Recommendations For You',
                            icon: Icons.recommend,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                  child: Icon(
                                    Icons.travel_explore,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                title: Text(
                                  'Based on your interest in ${_userInsights!.favoriteTourCategory}',
                                ),
                                subtitle: const Text(
                                  'Try exploring more experiences in this category',
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.arrow_forward,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const TourListScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Theme.of(
                                        context,
                                      ).colorScheme.secondaryContainer,
                                  child: Icon(
                                    Icons.location_on,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                title: Text(
                                  'Explore more of ${_userInsights!.mostVisitedDestination}',
                                ),
                                subtitle: const Text(
                                  'Discover hidden gems in your favorite destination',
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.arrow_forward,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const TourListScreen(),
                                      ),
                                    );
                                  },
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
    } else {
      // Show error if insights not available
      ModernSnackBar.show(
        context,
        message: 'Travel insights are not available at this time.',
        type: SnackBarType.warning,
      );
    }
  }

  // Helper method to build insight detail items
  Widget _buildInsightItem({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build insight detail cards
  Widget _buildInsightDetailCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final cardWidth = isMobile ? 280.0 : 350.0;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // App bar
              SliverAppBar(
                pinned: true,
                expandedHeight: 200.0,
                elevation: 0,
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gradient background
                      Container(
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

                      // Decorative pattern
                      Opacity(
                        opacity: 0.2,
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0),
                              ],
                              stops: const [0.7, 1.0],
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.dstIn,
                          child: Image.network(
                            'https://images.unsplash.com/photo-1483729558449-99ef09a8c325?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    const SizedBox(),
                          ),
                        ),
                      ),

                      // Content
                      ScaleTransition(
                        scale: _heroScaleAnimation,
                        child: FadeTransition(
                          opacity: _heroOpacityAnimation,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'For You',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isMobile ? 28 : 32,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Personalized recommendations just for you',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onPrimary.withOpacity(
                                      0.9,
                                    ),
                                    fontSize: isMobile ? 14 : 16,
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  collapseMode: CollapseMode.parallax,
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      _refreshIndicatorKey.currentState?.show();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Refresh recommendations',
                  ),
                ],
              ),

              // Main content with refresh indicator
              SliverToBoxAdapter(
                child: RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _refreshRecommendations,
                  color: colorScheme.primary,
                  backgroundColor: colorScheme.surface,
                  strokeWidth: 3,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Connection warning if offline
                            if (_isOffline)
                              Container(
                                margin: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  0,
                                ),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.wifi_off_rounded,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'You\'re offline. Some recommendations may not be updated.',
                                        style: TextStyle(
                                          color: Colors.orange.shade800,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _refreshIndicatorKey.currentState
                                            ?.show();
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text('RETRY'),
                                    ),
                                  ],
                                ),
                              ),

                            // User insights widget (if available)
                            if (_userInsights != null && !_isLoadingInsights)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: UserInsightsWidget(
                                  insights: _userInsights!,
                                  onViewMorePressed: _viewInsightsDetails,
                                ),
                              )
                            else if (_isLoadingInsights)
                              Container(
                                height: 150,
                                margin: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: colorScheme.primary,
                                  ),
                                ),
                              )
                            else if (_insightsError != null)
                              Container(
                                margin: const EdgeInsets.all(16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.errorContainer.withOpacity(
                                    0.3,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: colorScheme.error,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Travel Insights',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(_insightsError!),
                                    const SizedBox(height: 12),
                                    TextButton.icon(
                                      onPressed: _loadUserInsights,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),

                            // Flash deals section
                            SectionTitle(
                              title: 'Limited Time Deals',
                              isLoading: _isLoadingDeals,
                              onSeeAllPressed:
                                  _flashDeals.length > 3
                                      ? () {
                                        // Show all flash deals in a full page
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (context) => Scaffold(
                                                  appBar: AppBar(
                                                    title: const Text(
                                                      'All Flash Deals',
                                                    ),
                                                  ),
                                                  body: ListView.builder(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          16,
                                                        ),
                                                    itemCount:
                                                        _flashDeals.length,
                                                    itemBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      return Card(
                                                        margin:
                                                            const EdgeInsets.only(
                                                              bottom: 16,
                                                            ),
                                                        child: ListTile(
                                                          contentPadding:
                                                              const EdgeInsets.all(
                                                                16,
                                                              ),
                                                          leading: CircleAvatar(
                                                            backgroundColor:
                                                                _flashDeals[index]
                                                                    .getTypeColor()
                                                                    .withOpacity(
                                                                      0.2,
                                                                    ),
                                                            child: Icon(
                                                              Icons.flash_on,
                                                              color:
                                                                  _flashDeals[index]
                                                                      .getTypeColor(),
                                                            ),
                                                          ),
                                                          title: Text(
                                                            _flashDeals[index]
                                                                .name,
                                                          ),
                                                          subtitle: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                _flashDeals[index]
                                                                    .location,
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                'Ends in: ${_flashDeals[index].timeRemaining}',
                                                              ),
                                                            ],
                                                          ),
                                                          trailing: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text(
                                                                _flashDeals[index]
                                                                    .displayDiscount,
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              Text(
                                                                _flashDeals[index]
                                                                    .displayDiscountedPrice,
                                                                style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      Theme.of(
                                                                        context,
                                                                      ).colorScheme.primary,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          onTap:
                                                              () => _viewFlashDeal(
                                                                _flashDeals[index],
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                          ),
                                        );
                                      }
                                      : null,
                            ),

                            if (_isLoadingDeals)
                              Container(
                                height: 280,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 3,
                                  itemBuilder:
                                      (context, index) => Container(
                                        width: cardWidth,
                                        margin: const EdgeInsets.only(
                                          right: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              colorScheme.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                ),
                              )
                            else if (_dealsError != null)
                              _buildErrorSection(
                                context: context,
                                error: _dealsError!,
                                onRetry: _loadFlashDeals,
                              )
                            else
                              FlashDealsList(
                                deals: _flashDeals,
                                onDealTap: _viewFlashDeal,
                                isLoading: _isLoadingDeals,
                                cardWidth: cardWidth,
                              ),

                            // Personalized tour recommendations
                            SectionTitle(
                              title: 'Recommended For You',
                              isLoading: _isLoadingTours,
                              onSeeAllPressed:
                                  _personalizedTours.length > 3
                                      ? () {
                                        // Show all recommendations in a full page
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (context) => Scaffold(
                                                  appBar: AppBar(
                                                    title: const Text(
                                                      'All Recommendations',
                                                    ),
                                                  ),
                                                  body: GridView.builder(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          16,
                                                        ),
                                                    gridDelegate:
                                                        SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount:
                                                              isMobile ? 1 : 2,
                                                          childAspectRatio:
                                                              3 / 2,
                                                          mainAxisSpacing: 16,
                                                          crossAxisSpacing: 16,
                                                        ),
                                                    itemCount:
                                                        _personalizedTours
                                                            .length,
                                                    itemBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      final recommendation =
                                                          _personalizedTours[index];
                                                      final tour =
                                                          recommendation.tour;
                                                      return ModernCard(
                                                        onTap:
                                                            () =>
                                                                _navigateToTourDetails(
                                                                  tour,
                                                                ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            if (tour.mainImageUrl !=
                                                                null)
                                                              ClipRRect(
                                                                borderRadius:
                                                                    const BorderRadius.vertical(
                                                                      top:
                                                                          Radius.circular(
                                                                            20,
                                                                          ),
                                                                    ),
                                                                child: Image.network(
                                                                  tour.mainImageUrl!,
                                                                  height: 100,
                                                                  width:
                                                                      double
                                                                          .infinity,
                                                                  fit:
                                                                      BoxFit
                                                                          .cover,
                                                                  errorBuilder:
                                                                      (
                                                                        context,
                                                                        error,
                                                                        stackTrace,
                                                                      ) => Container(
                                                                        height:
                                                                            100,
                                                                        color: colorScheme
                                                                            .primaryContainer
                                                                            .withOpacity(
                                                                              0.3,
                                                                            ),
                                                                        child: Center(
                                                                          child: Icon(
                                                                            Icons.landscape,
                                                                            color: colorScheme.primary.withOpacity(
                                                                              0.5,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                ),
                                                              ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    12,
                                                                  ),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    tour.name,
                                                                    style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 4,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .location_on,
                                                                        size:
                                                                            14,
                                                                        color:
                                                                            colorScheme.primary,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            4,
                                                                      ),
                                                                      Expanded(
                                                                        child: Text(
                                                                          tour.location,
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color: colorScheme.onSurface.withOpacity(
                                                                              0.7,
                                                                            ),
                                                                          ),
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 4,
                                                                  ),
                                                                  Text(
                                                                    tour.displayPrice,
                                                                    style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          16,
                                                                      color:
                                                                          colorScheme
                                                                              .primary,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                          ),
                                        );
                                      }
                                      : null,
                            ),

                            if (_isLoadingTours)
                              Container(
                                height: 300,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 3,
                                  itemBuilder:
                                      (context, index) => Container(
                                        width: cardWidth,
                                        margin: const EdgeInsets.only(
                                          right: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              colorScheme.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                ),
                              )
                            else if (_toursError != null)
                              _buildErrorSection(
                                context: context,
                                error: _toursError!,
                                onRetry: _loadPersonalizedTours,
                              )
                            else
                              RecommendedToursList(
                                recommendations: _personalizedTours,
                                onTourTap:
                                    (tour) => _navigateToTourDetails(tour),
                                isLoading: _isLoadingTours,
                                onRefresh: _loadPersonalizedTours,
                                cardWidth: cardWidth,
                              ),

                            // Popular destinations section
                            SectionTitle(
                              title: 'Popular Destinations',
                              isLoading: _isLoadingDestinations,
                            ),

                            if (_isLoadingDestinations)
                              Container(
                                height: 150,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 5,
                                  itemBuilder:
                                      (context, index) => Container(
                                        width: 160,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color:
                                              colorScheme.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                ),
                              )
                            else if (_destinationsError != null)
                              _buildErrorSection(
                                context: context,
                                error: _destinationsError!,
                                onRetry: _loadPopularDestinations,
                              )
                            else
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

                            if (_isLoadingPackages)
                              Container(
                                height: 400,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 2,
                                  itemBuilder:
                                      (context, index) => Container(
                                        width: cardWidth,
                                        margin: const EdgeInsets.only(
                                          right: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              colorScheme.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                ),
                              )
                            else if (_packagesError != null)
                              _buildErrorSection(
                                context: context,
                                error: _packagesError!,
                                onRetry: _loadTrendingPackages,
                              )
                            else
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

                            if (_isLoadingOffers)
                              Container(
                                height: 360,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 2,
                                  itemBuilder:
                                      (context, index) => Container(
                                        width: cardWidth,
                                        margin: const EdgeInsets.only(
                                          right: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              colorScheme.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                ),
                              )
                            else if (_offersError != null)
                              _buildErrorSection(
                                context: context,
                                error: _offersError!,
                                onRetry: _loadSeasonalOffers,
                              )
                            else
                              SeasonalOffersList(
                                offers: _seasonalOffers,
                                onOfferTap: _viewSeasonalOffer,
                                isLoading: _isLoadingOffers,
                                cardWidth: cardWidth,
                              ),

                            // Bottom spacing
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Floating action button for navigation to top
          Positioned(
            bottom: 16,
            right: 16,
            child: AnimatedOpacity(
              opacity:
                  _scrollController.hasClients &&
                          _scrollController.offset > screenHeight * 0.5
                      ? 1.0
                      : 0.0,
              duration: const Duration(milliseconds: 300),
              child: FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                  );
                },
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                elevation: 4,
                mini: true,
                child: const Icon(Icons.arrow_upward),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build error sections
  Widget _buildErrorSection({
    required BuildContext context,
    required String error,
    required VoidCallback onRetry,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: colorScheme.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(error, style: TextStyle(color: colorScheme.error)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
          ),
        ],
      ),
    );
  }
}
