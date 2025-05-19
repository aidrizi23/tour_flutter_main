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
  bool _isRefreshing = false;

  // Animation controllers
  late AnimationController _fadeInController;
  late Animation<double> _fadeAnimation;

  // Current section being viewed - for analytics or future features
  String _currentSection = "All";

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeInController, curve: Curves.easeOut),
    );

    // Load recommendation data
    _loadRecommendations();

    // Start animations
    _fadeInController.forward();
  }

  @override
  void dispose() {
    _fadeInController.dispose();
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

    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
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
      _isRefreshing = true;
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
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      ),
    );
  }

  void _onSectionSelected(String section) {
    setState(() {
      _currentSection = section;
    });

    // Scroll to respective section
    switch (section) {
      case "Deals":
        _scrollToSection(0);
        break;
      case "For You":
        _scrollToSection(1);
        break;
      case "Destinations":
        _scrollToSection(2);
        break;
      case "Packages":
        _scrollToSection(3);
        break;
      case "Seasonal":
        _scrollToSection(4);
        break;
      default:
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutQuad,
        );
    }
  }

  void _scrollToSection(int sectionIndex) {
    // Calculate approximate scroll positions for each section
    // This is a simple approach - for more accuracy, you could use GlobalKeys
    final sectionHeights = [0, 330, 580, 790, 1190];

    if (sectionIndex < sectionHeights.length) {
      _scrollController.animateTo(
        sectionHeights[sectionIndex].toDouble(),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuad,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isMobile = screenWidth < 600;

    // Responsive card widths - scale based on screen size
    final cardWidth = isMobile ? screenWidth * 0.85 : screenWidth * 0.4;

    // Calculate container heights based on screen size for more responsiveness
    final destinationHeight = isMobile ? 160.0 : 180.0;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildAppBar(context, isMobile),
            // Quick navigation tabs
            SliverPersistentHeader(
              pinned: true,
              delegate: _QuickNavHeaderDelegate(
                minHeight: 60,
                maxHeight: 60,
                child: Container(
                  color: colorScheme.surface,
                  child: _buildNavigationTabs(context),
                ),
              ),
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: _refreshRecommendations,
          color: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          strokeWidth: 3,
          child:
              _isRefreshing
                  ? _buildRefreshingUI(context)
                  : FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView(
                      controller: _scrollController,
                      padding: EdgeInsets.zero,
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        // User insights widget (if available)
                        if (_userInsights != null && !_isLoadingInsights)
                          UserInsightsWidget(
                            insights: _userInsights!,
                            onViewMorePressed: _viewInsightsDetails,
                          )
                        else if (!_isLoadingInsights)
                          SizedBox(height: isMobile ? 8 : 16),

                        // Flash deals section
                        SectionTitle(
                          title: 'Limited Time Deals',
                          isLoading: _isLoadingDeals,
                        ),
                        FlashDealsList(
                          deals: _flashDeals,
                          onDealTap: _viewFlashDeal,
                          isLoading: _isLoadingDeals,
                          cardWidth: cardWidth,
                        ),

                        // Personalized tour recommendations
                        SectionTitle(
                          title: 'Just For You',
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
                          title: 'Trending Destinations',
                          isLoading: _isLoadingDestinations,
                        ),
                        SizedBox(
                          height: destinationHeight,
                          child: PopularDestinationsList(
                            destinations: _popularDestinations,
                            onDestinationTap: _exploreDestination,
                            isLoading: _isLoadingDestinations,
                          ),
                        ),

                        // Trending packages section
                        SectionTitle(
                          title: 'Premium Travel Packages',
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
                          title: 'Seasonal Experiences',
                          isLoading: _isLoadingOffers,
                        ),
                        SeasonalOffersList(
                          offers: _seasonalOffers,
                          onOfferTap: _viewSeasonalOffer,
                          isLoading: _isLoadingOffers,
                          cardWidth: cardWidth,
                        ),

                        // Bottom spacing
                        SizedBox(height: isMobile ? 100 : 80),
                      ],
                    ),
                  ),
        ),
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: _isScrolledDown(100) ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton(
          onPressed: () {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
            );
          },
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 4,
          mini: isMobile,
          child: const Icon(Icons.arrow_upward_rounded),
        ),
      ),
    );
  }

  bool _isScrolledDown(double threshold) {
    if (!_scrollController.hasClients) return false;
    return _scrollController.position.pixels > threshold;
  }

  Widget _buildRefreshingUI(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary, strokeWidth: 3),
          const SizedBox(height: 20),
          Text(
            "Refreshing your recommendations...",
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTabs(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.of(context).size.width < 600;

    final tabs = [
      'All',
      'Deals',
      'For You',
      'Destinations',
      'Packages',
      'Seasonal',
    ];

    final icons = [
      Icons.apps_rounded,
      Icons.flash_on_rounded,
      Icons.favorite_rounded,
      Icons.place_rounded,
      Icons.card_travel_rounded,
      Icons.wb_sunny_rounded,
    ];

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: tabs.length,
      itemBuilder: (context, index) {
        final isSelected = _currentSection == tabs[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _onSectionSelected(tabs[index]),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color:
                        isSelected
                            ? colorScheme.primary
                            : colorScheme.outline.withOpacity(0.2),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icons[index],
                      size: 16,
                      color:
                          isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface.withOpacity(0.7),
                    ),
                    if (!isMobile || tabs[index] == 'All' || isSelected) ...[
                      const SizedBox(width: 8),
                      Text(
                        tabs[index],
                        style: textTheme.labelMedium?.copyWith(
                          color:
                              isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurface.withOpacity(0.8),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, bool isMobile) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      expandedHeight: isMobile ? 110.0 : 130.0,
      pinned: true,
      floating: false,
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.fromLTRB(16, 0, 16, isMobile ? 16 : 20),
        centerTitle: false,
        collapseMode: CollapseMode.pin,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For You',
              style: TextStyle(
                fontSize: isMobile ? 22 : 26,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
            SizedBox(height: isMobile ? 2 : 4),
            Text(
              'Personalized recommendations',
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w400,
                color: colorScheme.onPrimary.withOpacity(0.9),
              ),
            ),
          ],
        ),
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
          onPressed: _refreshRecommendations,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh recommendations',
        ),
      ],
    );
  }
}

class _QuickNavHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _QuickNavHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_QuickNavHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
