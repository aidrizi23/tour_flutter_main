import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/house_models.dart';
import '../../services/house_service.dart';
import '../../widgets/custom_button.dart';
import 'house_booking_screen.dart';

class HouseDetailScreen extends StatefulWidget {
  final int houseId;

  const HouseDetailScreen({super.key, required this.houseId});

  @override
  State<HouseDetailScreen> createState() => _HouseDetailScreenState();
}

class _HouseDetailScreenState extends State<HouseDetailScreen>
    with TickerProviderStateMixin {
  final HouseService _houseService = HouseService();
  final ScrollController _scrollController = ScrollController();
  final PageController _imageController = PageController();
  final TextEditingController _reviewController = TextEditingController();

  House? _house;
  List<HouseReview> _reviews = [];
  bool _isLoading = true;
  bool _isLoadingReviews = false;
  bool _isSubmittingReview = false;
  bool _isCheckingAvailability = false;
  String? _errorMessage;
  int _currentImageIndex = 0;
  int _selectedRating = 5;
  bool _showBookingPanel = false;
  bool _isScrolled = false;

  // Booking related state
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guestCount = 1;
  HouseAvailabilityResponse? _availability;
  bool _agreedToTerms = false;

  // Animation controllers
  late AnimationController _animationController;
  late AnimationController _fabController;
  late AnimationController _bookingPanelController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bookingPanelAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _bookingPanelAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bookingPanelController,
        curve: Curves.easeOutCirc,
      ),
    );

    _scrollController.addListener(_onScroll);
    _loadHouseDetails();
    _fabController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabController.dispose();
    _bookingPanelController.dispose();
    _scrollController.dispose();
    _imageController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      bool isScrolled = _scrollController.offset > 100;
      if (isScrolled != _isScrolled) {
        setState(() {
          _isScrolled = isScrolled;
        });
      }
    }
  }

  Future<void> _loadHouseDetails() async {
    try {
      final house = await _houseService.getHouseById(widget.houseId);
      final reviews = await _houseService.getHouseReviews(widget.houseId);

      setState(() {
        _house = house;
        _reviews = reviews;
        _isLoading = false;
        _isLoadingReviews = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
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
      final review = await _houseService.addReview(
        AddHouseReviewRequest(
          houseId: widget.houseId,
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

  Future<void> _checkAvailability() async {
    if (_checkInDate == null || _checkOutDate == null || _house == null) {
      _showSnackBar(
        'Please select both check-in and check-out dates',
        Colors.orange,
      );
      return;
    }

    // Validate dates
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_checkInDate!.isBefore(today)) {
      _showSnackBar('Please select a future check-in date', Colors.orange);
      return;
    }

    if (_checkOutDate!.isBefore(_checkInDate!)) {
      _showSnackBar(
        'Check-out date must be after check-in date',
        Colors.orange,
      );
      return;
    }

    setState(() {
      _isCheckingAvailability = true;
      _availability = null;
    });

    try {
      final availability = await _houseService.checkAvailability(
        houseId: _house!.id,
        checkInDate: _checkInDate!,
        checkOutDate: _checkOutDate!,
        guestCount: _guestCount,
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

  void _proceedToBooking() {
    if (_house == null ||
        _checkInDate == null ||
        _checkOutDate == null ||
        _availability == null ||
        !_availability!.isAvailable) {
      return;
    }

    if (!_agreedToTerms) {
      _showSnackBar('Please agree to the terms and conditions', Colors.orange);
      return;
    }

    HapticFeedback.mediumImpact();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => HouseBookingScreen(
              house: _house!,
              checkInDate: _checkInDate!,
              checkOutDate: _checkOutDate!,
              guestCount: _guestCount,
              availabilityResponse: _availability!,
            ),
      ),
    );
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

  void _shareHouse() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Share functionality coming soon!'),
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

    if (_isLoading) {
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
                  strokeWidth: 4,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Loading house details...',
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

    if (_errorMessage != null || _house == null) {
      return Scaffold(
        backgroundColor: colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          title: const Text('House Details'),
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
                  'House Not Found',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage ?? 'The requested house could not be found.',
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
                      _buildGallery(),
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
                leading: Container(
                  margin: const EdgeInsets.only(left: 8, top: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8, top: 8),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.3),
                      child: IconButton(
                        icon: const Icon(Icons.share_rounded),
                        onPressed: _shareHouse,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16, top: 8),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.3),
                      child: IconButton(
                        icon: const Icon(Icons.favorite_border_rounded),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to favorites'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              // House content with enhanced design
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHouseHeader(),
                            const SizedBox(height: 24),
                            _buildHouseDescription(),
                            const SizedBox(height: 24),
                            _buildHouseFeatures(),
                            const SizedBox(height: 24),
                            _buildLocation(),
                            const SizedBox(height: 24),
                            _buildReviewsSection(),
                            const SizedBox(height: 120), // Space for FAB
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Booking Button
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: CustomButton(
              onPressed: _toggleBookingPanel,
              isLoading: false,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              borderRadius: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Book Now - ${_house!.displayPrice}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Booking panel overlay
          if (_showBookingPanel)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleBookingPanel,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _bookingPanelAnimation,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _bookingPanelAnimation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(_bookingPanelAnimation),
                            child: Container(
                              margin: const EdgeInsets.all(24),
                              constraints: BoxConstraints(
                                maxWidth: isMobile ? double.infinity : 500,
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.8,
                              ),
                              child: _buildBookingPanel(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGallery() {
    final images =
        _house!.images.isEmpty
            ? [_house!.mainImageUrl ?? '']
            : _house!.images.map((img) => img.imageUrl).toList();

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
            final imageUrl = images[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                image:
                    imageUrl.isNotEmpty
                        ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  imageUrl.isEmpty
                      ? Center(
                        child: Icon(
                          _house!.propertyTypeIconData,
                          size: 80,
                          color: Colors.grey[500],
                        ),
                      )
                      : null,
            );
          },
        ),

        // Image indicators
        if (images.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentImageIndex == index ? 16 : 8,
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

        // Property type badge
        Positioned(
          top: 70,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _house!.propertyTypeColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  _house!.propertyTypeIconData,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  _house!.propertyType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Rating badge
        if (_house!.averageRating != null)
          Positioned(
            top: 70,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _house!.averageRating!.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHouseHeader() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _house!.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
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
                _house!.displayLocation,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInfoChip(
                Icon(
                  Icons.king_bed_outlined,
                  size: 16,
                  color: colorScheme.primary,
                ),
                "${_house!.bedrooms} ${_house!.bedrooms == 1 ? 'Bedroom' : 'Bedrooms'}",
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildInfoChip(
                Icon(
                  Icons.bathtub_outlined,
                  size: 16,
                  color: colorScheme.primary,
                ),
                "${_house!.bathrooms} ${_house!.bathrooms == 1 ? 'Bathroom' : 'Bathrooms'}",
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildInfoChip(
                Icon(
                  Icons.people_outline_rounded,
                  size: 16,
                  color: colorScheme.primary,
                ),
                "${_house!.maxGuests} ${_house!.maxGuests == 1 ? 'Guest' : 'Guests'}",
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price per night',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                Text(
                  _house!.displayPrice,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            if (_house!.cleaningFee != null && _house!.cleaningFee! > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '+ \$${_house!.cleaningFee!.toStringAsFixed(2)} cleaning fee',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(Icon icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHouseDescription() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About This Place',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            _house!.description,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: colorScheme.onSurface.withOpacity(0.9),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHouseFeatures() {
    final colorScheme = Theme.of(context).colorScheme;

    if (_house!.features.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children:
                _house!.features
                    .map((feature) => _buildFeatureItem(feature))
                    .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(HouseFeature feature) {
    final colorScheme = Theme.of(context).colorScheme;

    IconData iconData = Icons.check_circle_outline;
    // You could expand this to map common feature names to icons
    if (feature.name.toLowerCase().contains('wifi')) {
      iconData = Icons.wifi;
    } else if (feature.name.toLowerCase().contains('pool')) {
      iconData = Icons.pool;
    } else if (feature.name.toLowerCase().contains('kitchen')) {
      iconData = Icons.kitchen;
    } else if (feature.name.toLowerCase().contains('tv')) {
      iconData = Icons.tv;
    } else if (feature.name.toLowerCase().contains('parking')) {
      iconData = Icons.local_parking;
    } else if (feature.name.toLowerCase().contains('air')) {
      iconData = Icons.ac_unit;
    } else if (feature.name.toLowerCase().contains('washer')) {
      iconData = Icons.local_laundry_service;
    }

    return SizedBox(
      width: 150,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, size: 18, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocation() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_house!.address}, ${_house!.city}, ${_house!.country}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map,
                          size: 48,
                          color: colorScheme.primary.withOpacity(0.7),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Map View',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
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
      ],
    );
  }

  Widget _buildReviewsSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reviews',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (_house!.averageRating != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_house!.averageRating!.toStringAsFixed(1)} (${_house!.reviewCount})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Review input
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Write a Review',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Rating:',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRating = index + 1;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          index < _selectedRating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 28,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _reviewController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Share your experience',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmittingReview ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isSubmittingReview
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Submit Review'),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Review list
        if (_reviews.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No reviews yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Be the first to review this place',
                    style: TextStyle(
                      fontSize: 14,
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
                    .map((review) => _buildReviewItem(review))
                    .toList(),
          ),

        if (_reviews.length > 3) ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () {
                // Show all reviews
              },
              icon: const Icon(Icons.visibility),
              label: Text('View all ${_reviews.length} reviews'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewItem(HouseReview review) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy').format(review.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: colorScheme.onSurface.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingPanel() {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      borderRadius: BorderRadius.circular(24),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Book Your Stay',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _toggleBookingPanel,
                  icon: const Icon(Icons.close),
                  iconSize: 24,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Date Selection
            Text(
              'Select Dates',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateSelector(
                    'Check-in',
                    _checkInDate,
                    (date) => setState(() {
                      _checkInDate = date;
                      // If check-out date is before check-in, update it
                      if (_checkOutDate != null &&
                          _checkOutDate!.isBefore(_checkInDate!)) {
                        _checkOutDate = _checkInDate!.add(
                          const Duration(days: 1),
                        );
                      }
                      _availability = null;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateSelector(
                    'Check-out',
                    _checkOutDate,
                    (date) => setState(() {
                      _checkOutDate = date;
                      _availability = null;
                    }),
                    _checkInDate,
                  ),
                ),
              ],
            ),

            // Guest Count
            const SizedBox(height: 20),
            Text(
              'Number of Guests',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Guests',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed:
                            _guestCount > 1
                                ? () => setState(() {
                                  _guestCount--;
                                  _availability = null;
                                })
                                : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        color:
                            _guestCount > 1
                                ? colorScheme.primary
                                : colorScheme.onSurface.withOpacity(0.3),
                      ),
                      Text(
                        '$_guestCount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        onPressed:
                            _guestCount < _house!.maxGuests
                                ? () => setState(() {
                                  _guestCount++;
                                  _availability = null;
                                })
                                : null,
                        icon: const Icon(Icons.add_circle_outline),
                        color:
                            _guestCount < _house!.maxGuests
                                ? colorScheme.primary
                                : colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Check Availability Button
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCheckingAvailability ? null : _checkAvailability,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isCheckingAvailability
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Check Availability'),
              ),
            ),

            // Availability Result
            if (_availability != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      _availability!.isAvailable
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        _availability!.isAvailable ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _availability!.isAvailable
                              ? Icons.check_circle
                              : Icons.cancel,
                          color:
                              _availability!.isAvailable
                                  ? Colors.green
                                  : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _availability!.isAvailable
                                ? 'Available for your dates!'
                                : 'Sorry, not available for these dates',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  _availability!.isAvailable
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_availability!.isAvailable) ...[
                      const Divider(height: 24),
                      _buildPriceRow(
                        '${_availability!.formattedNightlyRate} × ${_availability!.nights} nights',
                        (_availability!.nightlyRate * _availability!.nights)
                            .toStringAsFixed(2),
                      ),
                      if (_availability!.cleaningFee != null) ...[
                        const SizedBox(height: 8),
                        _buildPriceRow(
                          'Cleaning fee',
                          _availability!.formattedCleaningFee,
                        ),
                      ],
                      const Divider(height: 24),
                      _buildPriceRow(
                        'Total',
                        _availability!.formattedTotalPrice,
                        isBold: true,
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Terms & Book Button
            if (_availability != null && _availability!.isAvailable) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged:
                        (value) => setState(() => _agreedToTerms = value!),
                  ),
                  Expanded(
                    child: Text(
                      'I agree to the house rules and cancellation policy',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _agreedToTerms ? _proceedToBooking : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(
    String label,
    DateTime? selectedDate,
    Function(DateTime) onDateSelected, [
    DateTime? minDate,
  ]) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final firstDate =
        minDate != null && minDate.isAfter(now)
            ? minDate.add(const Duration(days: 1))
            : now;

    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? firstDate,
          firstDate: firstDate,
          lastDate: now.add(const Duration(days: 365)),
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                selectedDate != null
                    ? colorScheme.primary
                    : colorScheme.outline.withOpacity(0.3),
            width: selectedDate != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color:
              selectedDate != null
                  ? colorScheme.primary.withOpacity(0.1)
                  : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color:
                      selectedDate != null
                          ? colorScheme.primary
                          : colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? DateFormat('MMM d, yyyy').format(selectedDate)
                        : 'Select',
                    style: TextStyle(
                      fontWeight:
                          selectedDate != null
                              ? FontWeight.bold
                              : FontWeight.normal,
                      color:
                          selectedDate != null
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withOpacity(0.5),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String price, {bool isBold = false}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: colorScheme.onSurface.withOpacity(isBold ? 1.0 : 0.7),
          ),
        ),
        Text(
          '\$$price',
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
