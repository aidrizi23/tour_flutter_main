import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/tour_models.dart';
import '../../models/booking_models.dart';
import '../../services/tour_service.dart';
import '../../services/booking_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/responsive_layout.dart';
import '../booking/payment_screen.dart';

class TourDetailsScreen extends StatefulWidget {
  final int tourId;

  const TourDetailsScreen({super.key, required this.tourId});

  @override
  State<TourDetailsScreen> createState() => _TourDetailsScreenState();
}

class _TourDetailsScreenState extends State<TourDetailsScreen>
    with TickerProviderStateMixin {
  final TourService _tourService = TourService();
  final BookingService _bookingService = BookingService();
  final ScrollController _scrollController = ScrollController();
  final PageController _imageController = PageController();
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  Tour? _tour;
  List<TourReview> _reviews = [];
  bool _isLoadingTour = true;
  bool _isLoadingReviews = false;
  bool _isSubmittingReview = false;
  bool _isBooking = false;
  bool _isCheckingAvailability = false;
  String? _errorMessage;
  int _currentImageIndex = 0;
  int _selectedRating = 5;
  bool _showBookingPanel = false;
  bool _isScrolled = false;
  bool _isFavorite = false;

  // Booking related state
  DateTime? _selectedDate;
  int _numberOfPeople = 1;
  AvailabilityResponse? _availability;
  String? _discountCode;
  bool _agreedToTerms = false;

  late AnimationController _animationController;
  late AnimationController _fabController;
  late AnimationController _staggerController;
  late AnimationController _bookingPanelController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _bookingPanelAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _bookingPanelController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    _bookingPanelAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bookingPanelController,
        curve: Curves.easeOutCirc,
      ),
    );

    _scrollController.addListener(_onScroll);
    _loadTourDetails();
    _fabController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabController.dispose();
    _staggerController.dispose();
    _bookingPanelController.dispose();
    _scrollController.dispose();
    _imageController.dispose();
    _reviewController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onScroll() {
    bool isScrolled = _scrollController.offset > 100;
    if (isScrolled != _isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
    }
  }

  Future<void> _loadTourDetails() async {
    try {
      final tour = await _tourService.getTourById(widget.tourId);
      final reviews = await _tourService.getTourReviews(widget.tourId);

      setState(() {
        _tour = tour;
        _reviews = reviews;
        _isLoadingTour = false;
        _isLoadingReviews = false;
      });

      _animationController.forward();
      _staggerController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingTour = false;
        _isLoadingReviews = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;

    if (_isLoadingTour) {
      return ResponsiveLayout(
        currentIndex: 0,
        onDestinationSelected: (index) {},
        isAdmin: false,
        child: _buildLoadingScreen(colorScheme),
      );
    }

    if (_errorMessage != null || _tour == null) {
      return ResponsiveLayout(
        currentIndex: 0,
        onDestinationSelected: (index) {},
        isAdmin: false,
        child: _buildErrorScreen(colorScheme),
      );
    }

    return ResponsiveLayout(
      currentIndex: 0,
      onDestinationSelected: (index) {
        // Handle navigation
        Navigator.of(context).pop();
      },
      isAdmin: false,
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLowest,
        body: Stack(
          children: [
            // Main Content
            if (isDesktop)
              _buildModernDesktopLayout(colorScheme, screenWidth, screenHeight)
            else if (isTablet)
              _buildModernTabletLayout(colorScheme, screenWidth, screenHeight)
            else
              _buildModernMobileLayout(colorScheme, screenWidth, screenHeight),

            // Floating Action Button - Responsive positioning
            Positioned(
              bottom: isMobile ? 24 : 32,
              left: isMobile ? 24 : 32,
              right: isMobile ? 24 : 32,
              child: _buildModernBookingFAB(colorScheme, isMobile),
            ),

            // Booking Panel Overlay
            if (_showBookingPanel)
              _buildModernBookingPanelOverlay(colorScheme, isMobile, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(ColorScheme colorScheme) {
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Loading amazing tour details...',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(ColorScheme colorScheme) {
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Tour Details'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 60,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tour Not Found',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'The requested tour could not be found.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernDesktopLayout(
    ColorScheme colorScheme,
    double width,
    double height,
  ) {
    return Row(
      children: [
        // Left side - Interactive Image Gallery
        Expanded(
          flex: 5,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildModernDesktopHeader(colorScheme),
                Expanded(child: _buildInteractiveImageGallery(true)),
              ],
            ),
          ),
        ),

        // Right side - Content Panel
        Expanded(
          flex: 4,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              border: Border(
                left: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        _buildModernTourHeader(colorScheme, false),
                        _buildModernTourInfo(colorScheme),
                        _buildModernItinerary(colorScheme),
                        _buildModernFeatures(colorScheme, false),
                        _buildModernLocationSection(colorScheme),
                        _buildModernReviewsSection(colorScheme),
                        const SizedBox(height: 120), // Space for FAB
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernTabletLayout(
    ColorScheme colorScheme,
    double width,
    double height,
  ) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          expandedHeight: 500,
          pinned: true,
          stretch: true,
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          scrolledUnderElevation: 8,
          surfaceTintColor: colorScheme.surface,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                _buildInteractiveImageGallery(false),
                // Modern gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        colorScheme.surface.withValues(alpha: 0.9),
                      ],
                      stops: const [0.7, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: _buildModernAppBarActions(colorScheme),
        ),
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              constraints: BoxConstraints(maxWidth: width * 0.9),
              margin: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildModernTourHeader(colorScheme, true),
                  const SizedBox(height: 40),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            _buildModernTourInfo(colorScheme),
                            const SizedBox(height: 32),
                            _buildModernItinerary(colorScheme),
                            const SizedBox(height: 32),
                            _buildModernLocationSection(colorScheme),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildModernFeatures(colorScheme, true),
                            const SizedBox(height: 32),
                            _buildModernReviewsSection(colorScheme),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 120), // Space for FAB
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernMobileLayout(
    ColorScheme colorScheme,
    double width,
    double height,
  ) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          expandedHeight: 400,
          pinned: true,
          stretch: true,
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          scrolledUnderElevation: 8,
          surfaceTintColor: colorScheme.surface,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                _buildInteractiveImageGallery(false),
                // Modern gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        colorScheme.surface.withValues(alpha: 0.95),
                      ],
                      stops: const [0.6, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: _buildModernAppBarActions(colorScheme),
        ),
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildModernTourHeader(colorScheme, true),
                    _buildModernTourInfo(colorScheme),
                    _buildModernItinerary(colorScheme),
                    _buildModernFeatures(colorScheme, true),
                    _buildModernLocationSection(colorScheme),
                    _buildModernReviewsSection(colorScheme),
                    const SizedBox(height: 120), // Space for FAB
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernDesktopHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              style: IconButton.styleFrom(padding: const EdgeInsets.all(12)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tour Experience',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Discover amazing destinations',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          ..._buildModernAppBarActions(colorScheme),
        ],
      ),
    );
  }

  List<Widget> _buildModernAppBarActions(ColorScheme colorScheme) {
    return [
      Container(
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: IconButton(
          icon: const Icon(Icons.share_rounded),
          onPressed: _shareTotal,
          style: IconButton.styleFrom(padding: const EdgeInsets.all(12)),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(_isFavorite),
              color: _isFavorite ? Colors.red : colorScheme.onSurface,
            ),
          ),
          onPressed: _toggleFavorite,
          style: IconButton.styleFrom(padding: const EdgeInsets.all(12)),
        ),
      ),
    ];
  }

  Widget _buildInteractiveImageGallery(bool isDesktop) {
    final images =
        _tour!.images.isEmpty
            ? [TourImage(id: 0, imageUrl: '', displayOrder: 0)]
            : _tour!.images;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: isDesktop ? null : BorderRadius.circular(0),
      ),
      child: Stack(
        children: [
          // Main Image Display
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: GestureDetector(
              key: ValueKey(_currentImageIndex),
              onTap: () => _openImageViewer(images, _currentImageIndex),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image:
                      images[_currentImageIndex].imageUrl.isNotEmpty
                          ? DecorationImage(
                            image: NetworkImage(
                              images[_currentImageIndex].imageUrl,
                            ),
                            fit: BoxFit.cover,
                            onError: (error, stackTrace) {},
                          )
                          : null,
                ),
                child:
                    images[_currentImageIndex].imageUrl.isEmpty
                        ? _buildImagePlaceholder()
                        : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.2),
                              ],
                              stops: const [0.7, 1.0],
                            ),
                          ),
                        ),
              ),
            ),
          ),

          // Navigation Arrows (Desktop)
          if (isDesktop && images.length > 1)
            ..._buildImageNavigationArrows(colorScheme),

          // Thumbnail Strip (Desktop)
          if (isDesktop && images.length > 1)
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: _buildImageThumbnailStrip(images, colorScheme),
            ),

          // Dot Indicators (Mobile/Tablet)
          if (!isDesktop && images.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: _buildImageDotIndicators(images.length, colorScheme),
            ),

          // Image Counter and Actions
          Positioned(
            top: isDesktop ? 24 : 20,
            right: isDesktop ? 24 : 20,
            child: _buildImageActions(images.length, colorScheme),
          ),

          // Zoom Icon
          Positioned(
            top: isDesktop ? 24 : 20,
            left: isDesktop ? 24 : 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.zoom_in_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.3),
            colorScheme.secondary.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.landscape_rounded,
              size: 80,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No Image Available',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTourHeader(ColorScheme colorScheme, bool isMobile) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _tour!.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_tour!.hasDiscount)
                      Text(
                        _tour!.originalPrice,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    Text(
                      _tour!.displayPrice,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _tour!.location,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (isMobile) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_tour!.hasDiscount)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tour!.originalPrice,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        _tour!.displayPrice,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    _tour!.displayPrice,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildInfoChip(
                icon: Icons.access_time_rounded,
                label: _tour!.durationText,
                color: colorScheme.primaryContainer,
                textColor: colorScheme.onPrimaryContainer,
              ),
              _buildInfoChip(
                icon: Icons.group_rounded,
                label: 'Max ${_tour!.maxGroupSize}',
                color: colorScheme.secondaryContainer,
                textColor: colorScheme.onSecondaryContainer,
              ),
              _buildInfoChip(
                icon: _tour!.activityIcon,
                label: _tour!.activityType,
                color: colorScheme.tertiaryContainer,
                textColor: colorScheme.onTertiaryContainer,
              ),
              _buildInfoChip(
                icon: Icons.fitness_center_rounded,
                label: _tour!.difficultyLevel,
                color: _tour!.difficultyColor.withValues(alpha: 0.15),
                textColor: _tour!.difficultyColor,
              ),
              if (_tour!.averageRating != null)
                _buildInfoChip(
                  icon: Icons.star_rounded,
                  label:
                      '${_tour!.averageRating!.toStringAsFixed(1)} (${_tour!.reviewCount})',
                  color: Colors.amber.withValues(alpha: 0.15),
                  textColor: Colors.orange.shade800,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTourInfo(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.description_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'About This Tour',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _tour!.description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(height: 1.7, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildModernItinerary(ColorScheme colorScheme) {
    if (_tour!.itineraryItems.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.route_rounded,
                  color: colorScheme.onSecondaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Itinerary',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...List.generate(_tour!.itineraryItems.length, (index) {
            final item = _tour!.itineraryItems[index];
            return _buildItineraryItem(
              item,
              index,
              index == _tour!.itineraryItems.length - 1,
              colorScheme,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItineraryItem(
    ItineraryItem item,
    int index,
    bool isLast,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced day indicator
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Day',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimary,
                  ),
                ),
                Text(
                  '${item.dayNumber}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                ),
                if (item.startTime != null && item.endTime != null)
                  Text(
                    '${item.startTime}-${item.endTime}',
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onPrimary.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (item.location != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.place_rounded,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.location!,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    item.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.6, fontSize: 15),
                  ),
                  if (item.activityType != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.activityType!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFeatures(ColorScheme colorScheme, bool isMobile) {
    if (_tour!.features.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: colorScheme.onTertiaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'What\'s Included',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 1.0 : 1.2,
            ),
            itemCount: _tour!.features.length,
            itemBuilder: (context, index) {
              final feature = _tour!.features[index];
              return _buildFeatureCard(feature, colorScheme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(TourFeature feature, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getFeatureIcon(feature.name),
              color: colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            feature.name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          if (feature.description != null) ...[
            const SizedBox(height: 6),
            Text(
              feature.description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernLocationSection(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: colorScheme.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Location',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Stack(
              children: [
                // Map placeholder with gradient
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.1),
                        colorScheme.secondary.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_rounded,
                        size: 60,
                        color: colorScheme.primary.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Interactive Map',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _tour!.location,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernReviewsSection(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.reviews_rounded,
                      color: Colors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Reviews',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (_tour!.averageRating != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_tour!.averageRating!.toStringAsFixed(1)} (${_tour!.reviewCount})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Enhanced add review form
          _buildAddReviewForm(colorScheme),

          const SizedBox(height: 24),

          // Enhanced reviews list
          if (_reviews.isEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.rate_review_outlined,
                        size: 60,
                        color: colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No reviews yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to share your experience!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children:
                  _reviews
                      .take(3)
                      .map((review) => _buildReviewItem(review, colorScheme))
                      .toList(),
            ),

          if (_reviews.length > 3) ...[
            const SizedBox(height: 20),
            Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Navigate to all reviews screen
                },
                icon: const Icon(Icons.visibility_rounded),
                label: Text('View all ${_reviews.length} reviews'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddReviewForm(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share your experience',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Modern rating stars
          Row(
            children: [
              Text(
                'Rating: ',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              ...List.generate(5, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRating = index + 1;
                      });
                      HapticFeedback.lightImpact();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        index < _selectedRating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color:
                            index < _selectedRating
                                ? Colors.amber
                                : colorScheme.outline,
                        size: 32,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),

          // Enhanced review text field
          CustomTextField(
            controller: _reviewController,
            label: 'Write your review',
            hint: 'Tell others about your experience...',
            maxLines: 4,
            enabled: !_isSubmittingReview,
          ),
          const SizedBox(height: 16),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              onPressed: _submitReview,
              isLoading: _isSubmittingReview,
              minimumSize: const Size(double.infinity, 52),
              borderRadius: 16,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Submit Review',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(TourReview review, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color:
                                index < review.rating
                                    ? Colors.amber
                                    : colorScheme.outline,
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            review.comment,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(height: 1.6, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildModernBookingFAB(ColorScheme colorScheme, bool isMobile) {
    return RotationTransition(
      turns: _rotateAnimation,
      child: ScaleTransition(
        scale: _fabController,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: CustomButton(
            onPressed: _toggleBookingPanel,
            isLoading: false,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            minimumSize: Size(double.infinity, isMobile ? 64 : 72),
            borderRadius: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today_rounded, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Book Now - ${_tour!.displayPrice}',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_tour!.hasDiscount) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_tour!.discountPercentage}% OFF',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernBookingPanelOverlay(
    ColorScheme colorScheme,
    bool isMobile,
    bool isTablet,
  ) {
    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: InkWell(
          onTap: () => _toggleBookingPanel(),
          child: Container(
            alignment: Alignment.center,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : (isTablet ? 40 : 80),
                vertical: 40,
              ),
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 600,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: AnimatedBuilder(
                animation: _bookingPanelAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * _bookingPanelAnimation.value),
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        50 * (1 - _bookingPanelAnimation.value),
                      ),
                      child: Opacity(
                        opacity: _bookingPanelAnimation.value,
                        child: child,
                      ),
                    ),
                  );
                },
                child: _buildBookingPanel(colorScheme),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingPanel(ColorScheme colorScheme) {
    return Material(
      borderRadius: BorderRadius.circular(24),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Book Your Adventure',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _isBooking ? null : _toggleBookingPanel,
                    icon: const Icon(Icons.close_rounded),
                    iconSize: 28,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildBookingContent(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingContent(ColorScheme colorScheme) {
    return Column(
      children: [
        // Tour Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primaryContainer.withValues(alpha: 0.3),
                colorScheme.secondaryContainer.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.tour_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _tour!.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duration',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        _tour!.durationText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Price per person',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        _tour!.displayPrice,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Date and People Selection
        Row(
          children: [
            // Date Selection
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Date',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap:
                        _isBooking
                            ? null
                            : () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(
                                  const Duration(days: 1),
                                ),
                                firstDate: DateTime.now().add(
                                  const Duration(days: 1),
                                ),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (date != null) {
                                setState(() {
                                  _selectedDate = date;
                                  _availability = null;
                                });
                              }
                            },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            _selectedDate != null
                                ? colorScheme.primaryContainer.withValues(
                                  alpha: 0.3,
                                )
                                : colorScheme.surfaceContainerLow,
                        border: Border.all(
                          color:
                              _selectedDate != null
                                  ? colorScheme.primary.withValues(alpha: 0.5)
                                  : colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            color:
                                _selectedDate != null
                                    ? colorScheme.primary
                                    : colorScheme.outline,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedDate != null
                                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                  : 'Choose date...',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color:
                                    _selectedDate != null
                                        ? colorScheme.onSurface
                                        : colorScheme.onSurface.withValues(
                                          alpha: 0.6,
                                        ),
                                fontWeight:
                                    _selectedDate != null
                                        ? FontWeight.w600
                                        : FontWeight.normal,
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
            const SizedBox(width: 16),

            // Number of People
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'People',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed:
                              _isBooking || _numberOfPeople <= 1
                                  ? null
                                  : () {
                                    setState(() {
                                      _numberOfPeople--;
                                      _availability = null;
                                    });
                                    HapticFeedback.lightImpact();
                                  },
                          icon: Icon(
                            Icons.remove_rounded,
                            color:
                                _numberOfPeople > 1
                                    ? colorScheme.primary
                                    : colorScheme.outline,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '$_numberOfPeople',
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed:
                              _isBooking ||
                                      _numberOfPeople >=
                                          (_tour?.maxGroupSize ?? 10)
                                  ? null
                                  : () {
                                    setState(() {
                                      _numberOfPeople++;
                                      _availability = null;
                                    });
                                    HapticFeedback.lightImpact();
                                  },
                          icon: Icon(
                            Icons.add_rounded,
                            color:
                                _numberOfPeople < (_tour?.maxGroupSize ?? 10)
                                    ? colorScheme.primary
                                    : colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_numberOfPeople >= (_tour?.maxGroupSize ?? 10))
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Maximum group size reached',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Check Availability Button
        if (_selectedDate != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed:
                  _isBooking || _isCheckingAvailability
                      ? null
                      : _checkAvailability,
              icon:
                  _isCheckingAvailability
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.search_rounded),
              label: Text(
                _isCheckingAvailability ? 'Checking...' : 'Check Availability',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

        // Availability Result
        if (_availability != null) ...[
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  _availability!.isAvailable
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _availability!.statusColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        _availability!.isAvailable
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: _availability!.statusColor,
                        key: ValueKey(_availability!.isAvailable),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _availability!.statusText,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _availability!.statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_availability!.isAvailable) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Price:',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        _availability!.formattedPrice,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Duration:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        _availability!.formattedDuration,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],

        // Additional booking fields and terms when available
        if (_selectedDate != null && _availability?.isAvailable == true) ...[
          const SizedBox(height: 20),
          _buildBookingFields(colorScheme),
          const SizedBox(height: 24),
          _buildBookingButton(colorScheme),
        ],
      ],
    );
  }

  Widget _buildBookingFields(ColorScheme colorScheme) {
    return Column(
      children: [
        // Discount Code Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Discount Code',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Optional',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              enabled: !_isBooking,
              onChanged: (value) => _discountCode = value.toUpperCase(),
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Enter discount code (e.g., SAVE20)',
                prefixIcon: const Icon(Icons.discount_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Notes Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Special Requests',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              enabled: !_isBooking,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Any special requirements or dietary restrictions...',
                prefixIcon: const Icon(Icons.note_add_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Terms and Conditions
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _agreedToTerms,
              onChanged:
                  _isBooking
                      ? null
                      : (value) {
                        setState(() {
                          _agreedToTerms = value ?? false;
                        });
                        HapticFeedback.lightImpact();
                      },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap:
                    _isBooking
                        ? null
                        : () {
                          setState(() {
                            _agreedToTerms = !_agreedToTerms;
                          });
                          HapticFeedback.lightImpact();
                        },
                child: Text(
                  'I agree to the terms and conditions and privacy policy',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBookingButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: CustomButton(
          onPressed: _isBooking || !_agreedToTerms ? null : _proceedWithBooking,
          isLoading: _isBooking,
          minimumSize: const Size(double.infinity, 56),
          borderRadius: 16,
          backgroundColor:
              _agreedToTerms
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isBooking) ...[
                Icon(
                  _agreedToTerms
                      ? Icons.payment_rounded
                      : Icons.warning_rounded,
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                _isBooking
                    ? 'Creating Booking...'
                    : _agreedToTerms
                    ? 'Proceed to Payment'
                    : 'Please agree to terms',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for functionality
  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty) {
      _showSnackBar('Please write a review', Colors.orange);
      return;
    }

    setState(() {
      _isSubmittingReview = true;
    });

    try {
      final review = await _tourService.addReview(
        AddReviewRequest(
          tourId: widget.tourId,
          comment: _reviewController.text.trim(),
          rating: _selectedRating,
        ),
      );

      setState(() {
        _reviews.insert(0, review);
        _reviewController.clear();
        _selectedRating = 5;
        _isSubmittingReview = false;
      });

      _showSnackBar('Review submitted successfully!', Colors.green);
    } catch (e) {
      setState(() {
        _isSubmittingReview = false;
      });
      _showSnackBar('Failed to submit review: $e', Colors.red);
    }
  }

  void _toggleBookingPanel() {
    if (_showBookingPanel) {
      _bookingPanelController.reverse().then((_) {
        setState(() {
          _showBookingPanel = false;
        });
      });
    } else {
      setState(() {
        _showBookingPanel = true;
      });
      _bookingPanelController.forward();
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    HapticFeedback.lightImpact();
    _showSnackBar(
      _isFavorite ? 'Added to favorites' : 'Removed from favorites',
      _isFavorite ? Colors.red : Colors.grey,
    );
  }

  Future<void> _checkAvailability() async {
    if (_selectedDate == null || _tour == null) {
      _showSnackBar('Please select a date', Colors.orange);
      return;
    }

    // Validate date is not in the past
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    if (_selectedDate!.isBefore(tomorrow)) {
      _showSnackBar('Please select a future date', Colors.orange);
      return;
    }

    setState(() {
      _isCheckingAvailability = true;
      _availability = null;
    });

    try {
      final availability = await _bookingService.checkAvailability(
        tourId: _tour!.id,
        startDate: _selectedDate!,
        groupSize: _numberOfPeople,
      );

      setState(() {
        _availability = availability;
        _isCheckingAvailability = false;
      });

      HapticFeedback.lightImpact();
    } catch (e) {
      setState(() {
        _isCheckingAvailability = false;
      });
      _showSnackBar('Failed to check availability: $e', Colors.red);
    }
  }

  Future<void> _proceedWithBooking() async {
    if (_tour == null ||
        _selectedDate == null ||
        _availability == null ||
        !_availability!.isAvailable) {
      return;
    }

    if (!_agreedToTerms) {
      _showSnackBar('Please agree to the terms and conditions', Colors.orange);
      return;
    }

    setState(() {
      _isBooking = true;
    });

    HapticFeedback.mediumImpact();

    try {
      // Create quick booking
      final booking = await _bookingService.quickBook(
        tourId: _tour!.id,
        numberOfPeople: _numberOfPeople,
        tourStartDate: _selectedDate!,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        initiatePaymentImmediately: true,
        discountCode: _discountCode?.isNotEmpty == true ? _discountCode : null,
      );

      // Get payment info
      if (booking.paymentInfo != null) {
        // Navigate to payment screen
        final result = await Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    PaymentScreen(paymentInfo: booking.paymentInfo!),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return SlideTransition(
                position: animation.drive(
                  Tween(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              );
            },
          ),
        );

        // Handle payment result
        if (result == true) {
          setState(() {
            _showBookingPanel = false;
            _isBooking = false;
          });
          _showSuccessAnimation();
        } else {
          setState(() {
            _isBooking = false;
          });
        }
      } else {
        throw Exception('Payment information not available');
      }
    } catch (e) {
      setState(() {
        _isBooking = false;
      });
      _showSnackBar('Booking failed: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> _showSuccessAnimation() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const BookingSuccessDialog(),
    );

    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  IconData _getFeatureIcon(String featureName) {
    switch (featureName.toLowerCase()) {
      case 'guide':
      case 'tour guide':
        return Icons.person_pin_rounded;
      case 'transportation':
      case 'transport':
        return Icons.directions_bus_rounded;
      case 'meals':
      case 'food':
        return Icons.restaurant_rounded;
      case 'accommodation':
      case 'hotel':
        return Icons.hotel_rounded;
      case 'equipment':
        return Icons.construction_rounded;
      case 'audio guide':
        return Icons.headphones_rounded;
      case 'wifi':
        return Icons.wifi_rounded;
      case 'parking':
        return Icons.local_parking_rounded;
      case 'insurance':
        return Icons.security_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  void _openImageViewer(List<TourImage> images, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, _) =>
                _ImageViewer(images: images, initialIndex: initialIndex),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        opaque: false,
      ),
    );
  }

  List<Widget> _buildImageNavigationArrows(ColorScheme colorScheme) {
    return [
      // Previous Arrow
      Positioned(
        left: 24,
        top: 0,
        bottom: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _previousImage,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
      // Next Arrow
      Positioned(
        right: 24,
        top: 0,
        bottom: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _nextImage,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildImageThumbnailStrip(
    List<TourImage> images,
    ColorScheme colorScheme,
  ) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final isSelected = index == _currentImageIndex;
          return GestureDetector(
            onTap: () => _selectImage(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 8),
              width: isSelected ? 80 : 64,
              height: isSelected ? 64 : 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 2,
                ),
                image:
                    images[index].imageUrl.isNotEmpty
                        ? DecorationImage(
                          image: NetworkImage(images[index].imageUrl),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  images[index].imageUrl.isEmpty
                      ? Icon(
                        Icons.image_not_supported,
                        color: Colors.white.withValues(alpha: 0.7),
                      )
                      : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageDotIndicators(int length, ColorScheme colorScheme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            length,
            (index) => GestureDetector(
              onTap: () => _selectImage(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentImageIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color:
                      _currentImageIndex == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageActions(int length, ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${_currentImageIndex + 1}/$length',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            onPressed:
                () => _openImageViewer(
                  _tour!.images.isEmpty
                      ? [TourImage(id: 0, imageUrl: '', displayOrder: 0)]
                      : _tour!.images,
                  _currentImageIndex,
                ),
            icon: const Icon(
              Icons.fullscreen_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  void _selectImage(int index) {
    setState(() {
      _currentImageIndex = index;
    });
    HapticFeedback.lightImpact();
  }

  void _previousImage() {
    final images =
        _tour!.images.isEmpty
            ? [TourImage(id: 0, imageUrl: '', displayOrder: 0)]
            : _tour!.images;
    if (_currentImageIndex > 0) {
      _selectImage(_currentImageIndex - 1);
    } else {
      _selectImage(images.length - 1);
    }
  }

  void _nextImage() {
    final images =
        _tour!.images.isEmpty
            ? [TourImage(id: 0, imageUrl: '', displayOrder: 0)]
            : _tour!.images;
    if (_currentImageIndex < images.length - 1) {
      _selectImage(_currentImageIndex + 1);
    } else {
      _selectImage(0);
    }
  }

  void _shareTotal() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Share functionality coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class BookingSuccessDialog extends StatefulWidget {
  const BookingSuccessDialog({super.key});

  @override
  State<BookingSuccessDialog> createState() => _BookingSuccessDialogState();
}

class _BookingSuccessDialogState extends State<BookingSuccessDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _checkController, curve: Curves.easeOut));

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeOut),
    );

    _playAnimation();
  }

  void _playAnimation() async {
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _checkController.forward();
    _particleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _particleAnimation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      // Particle effects
                      for (int i = 0; i < 8; i++)
                        Positioned(
                          left: 40 + (40 * (i % 2)) * _particleAnimation.value,
                          top: 40 + (40 * (i ~/ 4)) * _particleAnimation.value,
                          child: Opacity(
                            opacity: 1 - _particleAnimation.value,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      // Success icon
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.green, Colors.green.shade700],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: AnimatedBuilder(
                            animation: _checkAnimation,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: CheckPainter(_checkAnimation.value),
                                child: const SizedBox(width: 100, height: 100),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _scaleAnimation,
                child: Column(
                  children: [
                    Text(
                      'Booking Initiated!',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your payment is being processed...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
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
}

class CheckPainter extends CustomPainter {
  final double animationValue;

  CheckPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (animationValue == 0) return;

    final paint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw check mark
    final path = Path();
    path.moveTo(center.dx - 15, center.dy);
    path.lineTo(center.dx - 5, center.dy + 10);
    path.lineTo(center.dx + 15, center.dy - 10);

    final pathMetrics = path.computeMetrics().first;
    final extractedPath = pathMetrics.extractPath(
      0,
      pathMetrics.length * animationValue,
    );

    canvas.drawPath(extractedPath, paint);
  }

  @override
  bool shouldRepaint(CheckPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class _ImageViewer extends StatefulWidget {
  final List<TourImage> images;
  final int initialIndex;

  const _ImageViewer({required this.images, required this.initialIndex});

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isControlsVisible = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = _fadeController.drive(CurveTween(curve: Curves.easeInOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Image Display
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                final image = widget.images[index];
                return InteractiveViewer(
                  child: Center(
                    child:
                        image.imageUrl.isNotEmpty
                            ? Image.network(
                              image.imageUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.white54,
                                    size: 64,
                                  ),
                                );
                              },
                            )
                            : const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.white54,
                                size: 64,
                              ),
                            ),
                  ),
                );
              },
            ),

            // Controls Overlay
            AnimatedOpacity(
              opacity: _isControlsVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Top Bar
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${_currentIndex + 1} / ${widget.images.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.share,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Bottom Thumbnail Strip
                      if (widget.images.length > 1)
                        Container(
                          height: 80,
                          margin: const EdgeInsets.all(16),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.images.length,
                            itemBuilder: (context, index) {
                              final isSelected = index == _currentIndex;
                              return GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.only(right: 8),
                                  width: isSelected ? 80 : 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.transparent,
                                      width: 2,
                                    ),
                                    image:
                                        widget.images[index].imageUrl.isNotEmpty
                                            ? DecorationImage(
                                              image: NetworkImage(
                                                widget.images[index].imageUrl,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                            : null,
                                  ),
                                  child:
                                      widget.images[index].imageUrl.isEmpty
                                          ? const Icon(
                                            Icons.image_not_supported,
                                            color: Colors.white54,
                                          )
                                          : null,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
