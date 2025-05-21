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
  List<FlashDeal> _flashDeals = [];
  List<SeasonalOffer> _seasonalOffers = [];
  UserInsights? _userInsights;

  // Loading states
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _hasError = false;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _fadeInController;
  late Animation<double> _fadeAnimation;

  // Current category
  String _currentCategory = "For You";

  // Connection state
  bool _hasConnection = true;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeOut,
    );

    // Load recommendation data
    _loadAllRecommendations();

    // Start animations
    _fadeInController.forward();
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAllRecommendations() async {
    if (_isRefreshing) return;

    setState(() {
      if (!_isRefreshing) _isLoading = true;
      _isRefreshing = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // Check connection first
      _hasConnection = await _recommendationService.checkConnection();

      // Load data in parallel
      final futures = await Future.wait([
        _loadPersonalizedTours(),
        _loadFlashDeals(),
        _loadSeasonalOffers(),
        _loadUserInsights(),
      ], eagerError: false);

      // Check if any data was loaded successfully
      final hasAnyData =
          _personalizedTours.isNotEmpty ||
          _flashDeals.isNotEmpty ||
          _seasonalOffers.isNotEmpty;

      if (!hasAnyData && !_hasConnection) {
        setState(() {
          _hasError = true;
          _errorMessage =
              "Couldn't load recommendations. Please check your connection.";
        });
      }
    } catch (e) {
      debugPrint('Error loading recommendations: $e');
      setState(() {
        _hasError = true;
        _errorMessage = "Something went wrong. Please try again.";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
        // Animations
        if (!_fadeInController.isCompleted) {
          _fadeInController.forward();
        }
      }
    }
  }

  Future<void> _loadPersonalizedTours() async {
    try {
      final recommendations =
          await _recommendationService.getPersonalizedTourRecommendations();
      if (mounted) {
        setState(() {
          _personalizedTours = recommendations;
        });
      }
      return;
    } catch (e) {
      debugPrint('Error loading personalized tours: $e');
      if (mounted) {
        setState(() {
          _personalizedTours = [];
        });
      }
      return;
    }
  }

  Future<void> _loadFlashDeals() async {
    try {
      final deals = await _recommendationService.getFlashDeals();
      if (mounted) {
        setState(() {
          _flashDeals = deals;
        });
      }
      return;
    } catch (e) {
      debugPrint('Error loading flash deals: $e');
      if (mounted) {
        setState(() {
          _flashDeals = [];
        });
      }
      return;
    }
  }

  Future<void> _loadSeasonalOffers() async {
    try {
      final offers = await _recommendationService.getSeasonalOffers();
      if (mounted) {
        setState(() {
          _seasonalOffers = offers;
        });
      }
      return;
    } catch (e) {
      debugPrint('Error loading seasonal offers: $e');
      if (mounted) {
        setState(() {
          _seasonalOffers = [];
        });
      }
      return;
    }
  }

  Future<void> _loadUserInsights() async {
    try {
      final insights = await _recommendationService.getUserInsights();
      if (mounted) {
        setState(() {
          _userInsights = insights;
        });
      }
      return;
    } catch (e) {
      debugPrint('Error loading user insights: $e');
      if (mounted) {
        setState(() {
          _userInsights = null;
        });
      }
      return;
    }
  }

  Future<void> _refreshRecommendations() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    await _loadAllRecommendations();
  }

  void _navigateToTourDetails(Tour tour) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                TourDetailsScreen(tourId: tour.id),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _viewFlashDeal(FlashDeal deal) {
    HapticFeedback.lightImpact();
    // Show snackbar for now
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Limited time offer: ${deal.name}'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _viewSeasonalOffer(SeasonalOffer offer) {
    HapticFeedback.lightImpact();
    // Show snackbar for now
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Seasonal offer: ${offer.name}'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _changeCategory(String category) {
    if (_currentCategory == category) return;

    HapticFeedback.selectionClick();
    setState(() {
      _currentCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isMobile = screenWidth < 600;

    // Responsive settings
    final horizontalPadding = isMobile ? 16.0 : 24.0;
    final cardWidth = isMobile ? 280.0 : 340.0;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(),
      body: _buildMainContent(context, horizontalPadding, cardWidth),
      floatingActionButton: _buildScrollToTopFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surface,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withOpacity(0.05),
              colorScheme.surface,
            ],
          ),
        ),
      ),
      title: Row(
        children: [
          Icon(Icons.recommend_rounded, color: colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'For You',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                'Personalized recommendations',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: _refreshRecommendations,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child:
                  _isRefreshing
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      )
                      : const Icon(Icons.refresh_rounded),
            ),
            tooltip: 'Refresh',
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    double horizontalPadding,
    double cardWidth,
  ) {
    if (_isLoading && !_isRefreshing) {
      return _buildLoadingState();
    }

    if (_hasError &&
        _personalizedTours.isEmpty &&
        _flashDeals.isEmpty &&
        _seasonalOffers.isEmpty) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: _refreshRecommendations,
      color: Theme.of(context).colorScheme.primary,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Add subtle decorative header
            SliverToBoxAdapter(child: _buildDecorativeHeader()),

            // Category selector
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  8,
                  horizontalPadding,
                  8,
                ),
                child: _buildCategorySelector(),
              ),
            ),

            // Show user insights compact card if available
            if (_userInsights != null && _currentCategory == "For You")
              SliverToBoxAdapter(child: _buildCompactInsightsCard()),

            // Content based on selected category
            if (_currentCategory == "For You" ||
                _currentCategory == "Recommendations")
              ..._buildRecommendationsSection(horizontalPadding, cardWidth),

            if (_currentCategory == "For You" || _currentCategory == "Deals")
              ..._buildDealsSection(horizontalPadding, cardWidth),

            if (_currentCategory == "For You" || _currentCategory == "Seasonal")
              ..._buildSeasonalSection(horizontalPadding, cardWidth),

            // Empty content state if no data in selected category
            if (_isEmptyCategory())
              SliverFillRemaining(child: _buildEmptyCategoryState()),

            // Extra bottom space for FAB
            SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      height: isMobile ? 15 : 20,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.05),
            colorScheme.primaryContainer.withOpacity(0.05),
            colorScheme.primary.withOpacity(0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Finding experiences for you...',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Connection Issue',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ??
                  'We couldn\'t load your recommendations. Please check your connection and try again.',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _loadAllRecommendations,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isEmptyCategory() {
    switch (_currentCategory) {
      case "Deals":
        return _flashDeals.isEmpty;
      case "Recommendations":
        return _personalizedTours.isEmpty;
      case "Seasonal":
        return _seasonalOffers.isEmpty;
      case "For You":
        return _flashDeals.isEmpty &&
            _personalizedTours.isEmpty &&
            _seasonalOffers.isEmpty;
      default:
        return false;
    }
  }

  Widget _buildEmptyCategoryState() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    IconData icon;
    String message;

    switch (_currentCategory) {
      case "Deals":
        icon = Icons.flash_on_rounded;
        message = 'No deals available at the moment';
        break;
      case "Recommendations":
        icon = Icons.recommend_rounded;
        message = 'No personalized recommendations yet';
        break;
      case "Seasonal":
        icon = Icons.wb_sunny_rounded;
        message = 'No seasonal offers currently available';
        break;
      default:
        icon = Icons.search_off_rounded;
        message = 'No recommendations available yet';
    }

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: colorScheme.outline.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _refreshRecommendations,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.of(context).size.width < 600;

    final categories = [
      {'title': 'For You', 'icon': Icons.recommend_rounded},
      {'title': 'Recommendations', 'icon': Icons.favorite_rounded},
      {'title': 'Deals', 'icon': Icons.flash_on_rounded},
      {'title': 'Seasonal', 'icon': Icons.wb_sunny_rounded},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surfaceContainerLowest,
      ),
      child: SizedBox(
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = _currentCategory == category['title'];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _changeCategory(category['title'] as String),
                  borderRadius: BorderRadius.circular(22),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? colorScheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category['icon'] as IconData,
                          size: 16,
                          color:
                              isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface.withOpacity(0.7),
                        ),
                        if (!isMobile ||
                            isSelected ||
                            category['title'] == 'For You') ...[
                          const SizedBox(width: 8),
                          Text(
                            category['title'] as String,
                            style: textTheme.bodyMedium?.copyWith(
                              color:
                                  isSelected
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurface.withOpacity(0.7),
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
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
        ),
      ),
    );
  }

  Widget _buildCompactInsightsCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final insights = _userInsights!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Card(
        elevation: 4,
        shadowColor: colorScheme.primary.withOpacity(0.2),
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withOpacity(0.05),
                colorScheme.primaryContainer.withOpacity(0.2),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.insights_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Travel Insights',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Based on your travel history',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Insights stats in a row
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    children: [
                      _buildInsightItem(
                        'Favorite',
                        insights.favoriteTourCategory,
                        Icons.category_rounded,
                      ),
                      _buildInsightItem(
                        'Trips',
                        '${insights.totalTrips}',
                        Icons.card_travel_rounded,
                      ),
                      _buildInsightItem(
                        'Avg Duration',
                        '${insights.averageTripDuration} days',
                        Icons.calendar_today_rounded,
                      ),
                      _buildInsightItem(
                        'Saved',
                        '\$${insights.totalSavings.toStringAsFixed(0)}',
                        Icons.savings_rounded,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightItem(
    String label,
    String value,
    IconData icon, {
    bool isLast = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 130,
      margin: EdgeInsets.only(right: isLast ? 0 : 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRecommendationsSection(
    double horizontalPadding,
    double cardWidth,
  ) {
    if (_personalizedTours.isEmpty && _currentCategory == "Recommendations") {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              8,
            ),
            child: SectionTitle(
              title: 'Recommended for You',
              icon: Icons.favorite_rounded,
              isLoading: _isRefreshing,
            ),
          ),
        ),
      ];
    }

    if (_personalizedTours.isEmpty) {
      return [];
    }

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            16,
          ),
          child: SectionTitle(
            title: 'Recommended for You',
            icon: Icons.favorite_rounded,
            onSeeAllPressed:
                _currentCategory == "For You"
                    ? () => _changeCategory("Recommendations")
                    : null,
            isLoading: _isRefreshing && _currentCategory == "Recommendations",
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: RecommendedToursList(
          recommendations: _personalizedTours,
          onTourTap: (tour) => _navigateToTourDetails(tour),
          isLoading: _isRefreshing && _currentCategory == "Recommendations",
          onRefresh: _loadPersonalizedTours,
          cardWidth: cardWidth,
        ),
      ),
    ];
  }

  List<Widget> _buildDealsSection(double horizontalPadding, double cardWidth) {
    if (_flashDeals.isEmpty && _currentCategory == "Deals") {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              8,
            ),
            child: SectionTitle(
              title: 'Limited Time Deals',
              icon: Icons.flash_on_rounded,
              isLoading: _isRefreshing,
            ),
          ),
        ),
      ];
    }

    if (_flashDeals.isEmpty) {
      return [];
    }

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            16,
          ),
          child: SectionTitle(
            title: 'Limited Time Deals',
            icon: Icons.flash_on_rounded,
            onSeeAllPressed:
                _currentCategory == "For You"
                    ? () => _changeCategory("Deals")
                    : null,
            isLoading: _isRefreshing && _currentCategory == "Deals",
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: FlashDealsList(
          deals: _flashDeals,
          onDealTap: _viewFlashDeal,
          isLoading: _isRefreshing && _currentCategory == "Deals",
          cardWidth: cardWidth,
        ),
      ),
    ];
  }

  List<Widget> _buildSeasonalSection(
    double horizontalPadding,
    double cardWidth,
  ) {
    if (_seasonalOffers.isEmpty && _currentCategory == "Seasonal") {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              8,
            ),
            child: SectionTitle(
              title: 'Seasonal Experiences',
              icon: Icons.wb_sunny_rounded,
              isLoading: _isRefreshing,
            ),
          ),
        ),
      ];
    }

    if (_seasonalOffers.isEmpty) {
      return [];
    }

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            8,
          ),
          child: SectionTitle(
            title: 'Seasonal Experiences',
            icon: Icons.wb_sunny_rounded,
            onSeeAllPressed:
                _currentCategory == "For You"
                    ? () => _changeCategory("Seasonal")
                    : null,
            isLoading: _isRefreshing && _currentCategory == "Seasonal",
          ),
        ),
      ),
    ];
  }

  Widget _buildScrollToTopFAB() {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        return AnimatedOpacity(
          opacity: _shouldShowScrollTopButton() ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: child,
        );
      },
      child: FloatingActionButton(
        mini: true,
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuad,
          );
        },
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        child: const Icon(Icons.keyboard_arrow_up_rounded),
      ),
    );
  }

  bool _shouldShowScrollTopButton() {
    if (!_scrollController.hasClients) return false;
    return _scrollController.offset > 300;
  }
}
