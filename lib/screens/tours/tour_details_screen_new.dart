import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/tour_models.dart';
import '../../models/booking_models.dart';
import '../../services/tour_service.dart';
import 'widgets/tour_details/tour_image_gallery.dart';
import 'widgets/tour_details/tour_header.dart';
import 'widgets/tour_details/tour_information.dart';
import 'widgets/tour_details/tour_itinerary.dart';
import 'widgets/tour_details/tour_features.dart';
import 'widgets/tour_details/tour_booking_panel.dart';
import '../booking/payment_screen.dart';

class TourDetailsScreenNew extends StatefulWidget {
  final int tourId;

  const TourDetailsScreenNew({super.key, required this.tourId});

  @override
  State<TourDetailsScreenNew> createState() => _TourDetailsScreenNewState();
}

class _TourDetailsScreenNewState extends State<TourDetailsScreenNew>
    with TickerProviderStateMixin {
  final TourService _tourService = TourService();
  final ScrollController _scrollController = ScrollController();

  Tour? _tour;
  List<TourReview> _reviews = [];
  bool _isLoadingTour = true;
  bool _isLoadingReviews = false;
  bool _isBooking = false;
  String? _errorMessage;
  bool _isScrolled = false;
  bool _isFavorite = false;

  // Booking related state
  DateTime? _selectedDate;
  int _numberOfPeople = 1;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scrollController.addListener(_onScroll);
    _loadTourDetails();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
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

      setState(() {
        _tour = tour;
        _isLoadingTour = false;
      });

      _animationController.forward();
      
      // Load reviews after tour details are loaded
      _loadTourReviews();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingTour = false;
      });
    }
  }

  Future<void> _loadTourReviews() async {
    if (_tour == null) return;
    
    setState(() {
      _isLoadingReviews = true;
    });

    try {
      final reviews = await _tourService.getTourReviews(_tour!.id);
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (e) {
      debugPrint('Error loading reviews: $e');
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  Future<void> _onBookNow() async {
    if (_tour == null || _selectedDate == null) return;

    setState(() {
      _isBooking = true;
    });

    try {
      // Create payment info object
      final paymentInfo = PaymentInfo(
        bookingId: 0, // Will be set by the backend
        tourId: _tour!.id,
        tourName: _tour!.name,
        tourImageUrl: _tour!.mainImageUrl,
        tourLocation: _tour!.location,
        numberOfPeople: _numberOfPeople,
        tourStartDate: _selectedDate!,
        durationInDays: _tour!.durationInDays,
        pricePerPerson: _tour!.discountedPrice ?? _tour!.price,
        totalAmount: (_tour!.discountedPrice ?? _tour!.price) * _numberOfPeople,
        paymentStatus: 'pending',
      );

      // Navigate to payment screen
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            paymentInfo: paymentInfo,
          ),
        ),
      );

      if (result == true && mounted) {
        // Booking successful
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Tour booked successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    // TODO: Implement actual favorite functionality
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
      return _buildLoadingScreen(colorScheme);
    }

    if (_errorMessage != null || _tour == null) {
      return _buildErrorScreen(colorScheme);
    }

    return _buildContent(colorScheme, screenWidth, screenHeight, isDesktop, isTablet, isMobile);
  }

  Widget _buildContent(
    ColorScheme colorScheme,
    double screenWidth,
    double screenHeight,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    if (isDesktop) {
      return _buildDesktopLayout(colorScheme, screenWidth, screenHeight);
    } else {
      return _buildMobileTabletLayout(colorScheme, screenWidth, screenHeight, isTablet);
    }
  }

  Widget _buildDesktopLayout(ColorScheme colorScheme, double screenWidth, double screenHeight) {
    return Row(
      children: [
        // Left side - Image gallery and basic info
        Expanded(
          flex: 5,
          child: Container(
            height: screenHeight,
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
                // Custom app bar for desktop
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.surfaceContainer,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _toggleFavorite();
                        },
                        icon: Icon(
                          _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: _isFavorite ? Colors.red : colorScheme.outline,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.surfaceContainer,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
                // Image gallery
                Expanded(
                  child: TourImageGallery(
                    tour: _tour!,
                    isDesktop: true,
                    height: double.infinity,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right side - Content and booking
        Expanded(
          flex: 4,
          child: Container(
            height: screenHeight,
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
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        TourHeader(
                          tour: _tour!,
                          isDesktop: true,
                          showBackButton: false,
                          onFavoriteToggle: _toggleFavorite,
                          isFavorite: _isFavorite,
                        ),
                        const SizedBox(height: 32),
                        TourInformation(
                          tour: _tour!,
                          isDesktop: true,
                        ),
                        const SizedBox(height: 32),
                        TourItinerary(
                          tour: _tour!,
                          isDesktop: true,
                        ),
                        const SizedBox(height: 32),
                        TourFeatures(
                          tour: _tour!,
                          isDesktop: true,
                        ),
                        const SizedBox(height: 32),
                        TourBookingPanel(
                          tour: _tour!,
                          isDesktop: true,
                          onBookNow: _onBookNow,
                          onDateChanged: (date) => setState(() => _selectedDate = date),
                          onPeopleChanged: (people) => setState(() => _numberOfPeople = people),
                          selectedDate: _selectedDate,
                          numberOfPeople: _numberOfPeople,
                          isLoading: _isBooking,
                        ),
                        const SizedBox(height: 32),
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

  Widget _buildMobileTabletLayout(
    ColorScheme colorScheme,
    double screenWidth,
    double screenHeight,
    bool isTablet,
  ) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // App bar with image gallery
        SliverAppBar(
          expandedHeight: isTablet ? 500 : 400,
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
                TourImageGallery(
                  tour: _tour!,
                  isDesktop: false,
                ),
                // Gradient overlay
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
          actions: [
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _toggleFavorite();
              },
              icon: Icon(
                _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _isFavorite ? Colors.red : Colors.white,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),

        // Content
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                const SizedBox(height: 24),
                TourHeader(
                  tour: _tour!,
                  isDesktop: false,
                  showBackButton: false,
                  onFavoriteToggle: _toggleFavorite,
                  isFavorite: _isFavorite,
                ),
                const SizedBox(height: 32),
                TourInformation(
                  tour: _tour!,
                  isDesktop: false,
                ),
                const SizedBox(height: 32),
                TourItinerary(
                  tour: _tour!,
                  isDesktop: false,
                ),
                const SizedBox(height: 32),
                TourFeatures(
                  tour: _tour!,
                  isDesktop: false,
                ),
                const SizedBox(height: 32),
                TourBookingPanel(
                  tour: _tour!,
                  isDesktop: false,
                  onBookNow: _onBookNow,
                  onDateChanged: (date) => setState(() => _selectedDate = date),
                  onPeopleChanged: (people) => setState(() => _numberOfPeople = people),
                  selectedDate: _selectedDate,
                  numberOfPeople: _numberOfPeople,
                  isLoading: _isBooking,
                ),
                const SizedBox(height: 120), // Space for potential FAB
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingScreen(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
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
                Text(
                  'Loading tour details...',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
}