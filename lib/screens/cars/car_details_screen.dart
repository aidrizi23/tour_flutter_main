import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/car_models.dart';
import '../../models/car_availability_response.dart'; // Add this import
import '../../services/car_service.dart';
import '../../services/car_booking_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../booking/car_payment_screen.dart';

class CarDetailsScreen extends StatefulWidget {
  final int carId;

  const CarDetailsScreen({super.key, required this.carId});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen>
    with TickerProviderStateMixin {
  final CarService _carService = CarService();
  final CarBookingService _bookingService = CarBookingService();
  final ScrollController _scrollController = ScrollController();
  final PageController _imageController = PageController();
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  Car? _car;
  List<CarReview> _reviews = [];
  bool _isLoadingCar = true;
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
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  CarAvailabilityResponse? _availability;
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
    _loadCarDetails();
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

  Future<void> _loadCarDetails() async {
    try {
      final car = await _carService.getCarById(widget.carId);
      final reviews = await _carService.getCarReviews(widget.carId);

      setState(() {
        _car = car;
        _reviews = reviews;
        _isLoadingCar = false;
        _isLoadingReviews = false;
      });

      _animationController.forward();
      _staggerController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingCar = false;
        _isLoadingReviews = false;
      });
    }
  }

  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty) {
      _showSnackBar('Please write a review', Colors.orange);
      return;
    }

    setState(() {
      _isSubmittingReview = true;
    });

    try {
      final review = await _carService.addReview(
        AddCarReviewRequest(
          carId: widget.carId,
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
    if (_selectedStartDate == null ||
        _selectedEndDate == null ||
        _car == null) {
      _showSnackBar('Please select both start and end dates', Colors.orange);
      return;
    }

    // Validate dates
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_selectedStartDate!.isBefore(today)) {
      _showSnackBar('Please select a future start date', Colors.orange);
      return;
    }

    if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
      _showSnackBar('End date must be after start date', Colors.orange);
      return;
    }

    setState(() {
      _isCheckingAvailability = true;
      _availability = null;
    });

    try {
      final availability = await _bookingService.checkAvailability(
        carId: _car!.id,
        startDate: _selectedStartDate!,
        endDate: _selectedEndDate!,
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
    if (_car == null ||
        _selectedStartDate == null ||
        _selectedEndDate == null ||
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
        carId: _car!.id,
        rentalStartDate: _selectedStartDate!,
        rentalEndDate: _selectedEndDate!,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        initiatePaymentImmediately: true,
      );

      // Get payment info
      if (booking.paymentInfo != null) {
        // Navigate to payment screen
        final result = await Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    CarPaymentScreen(paymentInfo: booking.paymentInfo!),
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (_isLoadingCar) {
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
                  'Loading car details...',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
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

    if (_errorMessage != null || _car == null) {
      return Scaffold(
        backgroundColor: colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          title: const Text('Car Details'),
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
                  'Car Not Found',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage ?? 'The requested car could not be found.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
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

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Enhanced Image Gallery and App Bar
              SliverAppBar(
                expandedHeight: isMobile ? 320 : 400,
                pinned: true,
                stretch: true,
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.onSurface,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildEnhancedImageGallery(),
                      // Gradient overlay for better text visibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.3),
                      child: IconButton(
                        icon: const Icon(Icons.share_rounded),
                        onPressed: _shareTotal,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.3),
                      child: IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            key: ValueKey(_isFavorite),
                            color: _isFavorite ? Colors.red : Colors.white,
                          ),
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ),
                  ),
                ],
              ),

              // Car content with enhanced design
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        children: [
                          _buildEnhancedCarHeader(),
                          _buildModernCarInfo(),
                          _buildModernFeatures(),
                          _buildEnhancedLocationSection(),
                          _buildModernReviewsSection(),
                          const SizedBox(height: 120), // Space for FAB
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Enhanced Floating Action Button
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: RotationTransition(
              turns: _rotateAnimation,
              child: ScaleTransition(
                scale: _fabController,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
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
                    minimumSize: const Size(double.infinity, 64),
                    borderRadius: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Book Now - ${_car!.displayPrice}/day',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Enhanced Booking panel overlay
          if (_showBookingPanel)
            Positioned.fill(
              child: Material(
                color: Colors.black54,
                child: InkWell(
                  onTap: () => _toggleBookingPanel(),
                  child: Container(
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 40,
                        vertical: 40,
                      ),
                      constraints: const BoxConstraints(maxWidth: 500),
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
                        child: _buildEnhancedBookingPanel(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancedImageGallery() {
    final images =
        _car!.images.isEmpty
            ? [CarImage(id: 0, imageUrl: '', displayOrder: 0)]
            : _car!.images;

    return Stack(
      children: [
        PageView.builder(
          controller: _imageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: images.length,
          itemBuilder: (context, index) {
            final image = images[index];
            return Container(
              decoration: BoxDecoration(
                image:
                    image.imageUrl.isNotEmpty
                        ? DecorationImage(
                          image: NetworkImage(image.imageUrl),
                          fit: BoxFit.cover,
                          onError:
                              (error, stackTrace) => _buildImagePlaceholder(),
                        )
                        : null,
              ),
              child: image.imageUrl.isEmpty ? _buildImagePlaceholder() : null,
            );
          },
        ),

        // Enhanced image indicators
        if (images.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    images.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentImageIndex == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color:
                            _currentImageIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Image counter
        if (images.length > 1)
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
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
            colorScheme.primary.withOpacity(0.3),
            colorScheme.secondary.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              size: 80,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No Image Available',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.5),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedCarHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
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
                  _car!.displayName,
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
                    Text(
                      'Daily Rate',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      _car!.displayPrice,
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
                  _car!.location,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.8),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Rate',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      _car!.displayPrice,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildModernInfoChip(
                icon: _car!.categoryIcon,
                label: _car!.category,
                color: _car!.categoryColor.withOpacity(0.15),
                textColor: _car!.categoryColor,
              ),
              _buildModernInfoChip(
                icon: Icons.people_rounded,
                label: '${_car!.seats} seats',
                color: colorScheme.secondaryContainer,
                textColor: colorScheme.onSecondaryContainer,
              ),
              _buildModernInfoChip(
                icon: _car!.transmissionIcon,
                label: _car!.transmission,
                color: colorScheme.tertiaryContainer,
                textColor: colorScheme.onTertiaryContainer,
              ),
              _buildModernInfoChip(
                icon: _car!.fuelIcon,
                label: _car!.fuelType,
                color: colorScheme.primaryContainer,
                textColor: colorScheme.onPrimaryContainer,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernInfoChip({
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
        border: Border.all(color: textColor.withOpacity(0.2), width: 1),
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

  Widget _buildModernCarInfo() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
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
                'About This Car',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _car!.description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(height: 1.7, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFeatures() {
    if (_car!.features.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
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
            itemCount: _car!.features.length,
            itemBuilder: (context, index) {
              final feature = _car!.features[index];
              return _buildModernFeatureCard(feature);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModernFeatureCard(CarFeature feature) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
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
                color: colorScheme.onSurface.withOpacity(0.7),
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

  Widget _buildEnhancedLocationSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
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
              border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
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
                        colorScheme.primary.withOpacity(0.1),
                        colorScheme.secondary.withOpacity(0.1),
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
                        color: colorScheme.primary.withOpacity(0.6),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Interactive Map',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withOpacity(0.7),
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
                          _car!.location,
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

  Widget _buildModernReviewsSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
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
                      color: Colors.amber.withOpacity(0.2),
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
              if (_car!.averageRating != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
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
                        '${_car!.averageRating!.toStringAsFixed(1)} (${_car!.reviewCount})',
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
          _buildModernAddReviewForm(),

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
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to share your experience!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
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
                      .map((review) => _buildModernReviewItem(review))
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

  Widget _buildModernAddReviewForm() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
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

  Widget _buildModernReviewItem(CarReview review) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
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
                            color: colorScheme.onSurface.withOpacity(0.6),
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

  Widget _buildEnhancedBookingPanel() {
    final colorScheme = Theme.of(context).colorScheme;

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
                    'Book Your Car',
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

              // Car Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer.withOpacity(0.3),
                      colorScheme.secondaryContainer.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.1),
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
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.directions_car_rounded,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _car!.displayName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
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
                              'Seats',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            Text(
                              '${_car!.seats} people',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Daily rate',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            Text(
                              _car!.displayPrice,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
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

              // Date Selection
              Text(
                'Select Rental Dates',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Start Date
                  Expanded(
                    child: InkWell(
                      onTap:
                          _isBooking
                              ? null
                              : () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      _selectedStartDate ??
                                      DateTime.now().add(
                                        const Duration(days: 1),
                                      ),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (date != null) {
                                  setState(() {
                                    _selectedStartDate = date;
                                    if (_selectedEndDate != null &&
                                        _selectedEndDate!.isBefore(date)) {
                                      _selectedEndDate = null;
                                    }
                                    _availability = null;
                                  });
                                }
                              },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              _selectedStartDate != null
                                  ? colorScheme.primaryContainer.withOpacity(
                                    0.3,
                                  )
                                  : colorScheme.surfaceContainerLow,
                          border: Border.all(
                            color:
                                _selectedStartDate != null
                                    ? colorScheme.primary.withOpacity(0.5)
                                    : colorScheme.outline.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              color:
                                  _selectedStartDate != null
                                      ? colorScheme.primary
                                      : colorScheme.outline,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedStartDate != null
                                    ? '${_selectedStartDate!.day}/${_selectedStartDate!.month}/${_selectedStartDate!.year}'
                                    : 'Start date',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(
                                  color:
                                      _selectedStartDate != null
                                          ? colorScheme.onSurface
                                          : colorScheme.onSurface.withOpacity(
                                            0.6,
                                          ),
                                  fontWeight:
                                      _selectedStartDate != null
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // End Date
                  Expanded(
                    child: InkWell(
                      onTap:
                          _isBooking
                              ? null
                              : () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      _selectedEndDate ??
                                      (_selectedStartDate?.add(
                                            const Duration(days: 1),
                                          ) ??
                                          DateTime.now().add(
                                            const Duration(days: 2),
                                          )),
                                  firstDate:
                                      _selectedStartDate?.add(
                                        const Duration(days: 1),
                                      ) ??
                                      DateTime.now().add(
                                        const Duration(days: 1),
                                      ),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (date != null) {
                                  setState(() {
                                    _selectedEndDate = date;
                                    _availability = null;
                                  });
                                }
                              },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              _selectedEndDate != null
                                  ? colorScheme.primaryContainer.withOpacity(
                                    0.3,
                                  )
                                  : colorScheme.surfaceContainerLow,
                          border: Border.all(
                            color:
                                _selectedEndDate != null
                                    ? colorScheme.primary.withOpacity(0.5)
                                    : colorScheme.outline.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              color:
                                  _selectedEndDate != null
                                      ? colorScheme.primary
                                      : colorScheme.outline,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedEndDate != null
                                    ? '${_selectedEndDate!.day}/${_selectedEndDate!.month}/${_selectedEndDate!.year}'
                                    : 'End date',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(
                                  color:
                                      _selectedEndDate != null
                                          ? colorScheme.onSurface
                                          : colorScheme.onSurface.withOpacity(
                                            0.6,
                                          ),
                                  fontWeight:
                                      _selectedEndDate != null
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Check Availability Button
              if (_selectedStartDate != null && _selectedEndDate != null)
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
                      _isCheckingAvailability
                          ? 'Checking...'
                          : 'Check Availability',
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
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _availability!.statusColor.withOpacity(0.3),
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
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
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
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              _availability!.formattedDuration,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // Notes Field
              if (_selectedStartDate != null &&
                  _selectedEndDate != null &&
                  _availability?.isAvailable == true) ...[
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Special Requests',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      enabled: !_isBooking,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Any special requirements or requests...',
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

              // Book Now Button
              if (_availability?.isAvailable == true) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: CustomButton(
                      onPressed:
                          _isBooking || !_agreedToTerms
                              ? null
                              : _proceedWithBooking,
                      isLoading: _isBooking,
                      minimumSize: const Size(double.infinity, 56),
                      borderRadius: 16,
                      backgroundColor:
                          _agreedToTerms
                              ? colorScheme.primary
                              : colorScheme.outline.withOpacity(0.5),
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
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFeatureIcon(String featureName) {
    switch (featureName.toLowerCase()) {
      case 'air conditioning':
      case 'climate control':
        return Icons.ac_unit_rounded;
      case 'bluetooth':
      case 'bluetooth connectivity':
        return Icons.bluetooth_rounded;
      case 'gps navigation':
      case 'navigation system':
        return Icons.navigation_rounded;
      case 'usb charging':
      case 'usb ports':
        return Icons.usb_rounded;
      case 'backup camera':
      case 'rear camera':
        return Icons.camera_rear_rounded;
      case 'cruise control':
        return Icons.speed_rounded;
      case 'alloy wheels':
        return Icons.tire_repair_rounded;
      case 'sunroof':
        return Icons.wb_sunny_rounded;
      case 'leather seats':
        return Icons.weekend_rounded;
      case 'keyless entry':
        return Icons.key_rounded;
      default:
        return Icons.check_circle_rounded;
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
                color: Colors.black.withOpacity(0.1),
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
                                color: Colors.green.withOpacity(0.7),
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
                                color: Colors.green.withOpacity(0.3),
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
                        color: colorScheme.onSurface.withOpacity(0.7),
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
