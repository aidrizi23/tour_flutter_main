import 'package:flutter/material.dart';
import '../../models/car_booking_models.dart';
import '../../services/car_booking_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/payment_widgets.dart';
import '../booking/car_payment_screen.dart';

class CarBookingScreen extends StatefulWidget {
  const CarBookingScreen({super.key});

  @override
  State<CarBookingScreen> createState() => _CarBookingScreenState();
}

class _CarBookingScreenState extends State<CarBookingScreen>
    with TickerProviderStateMixin {
  final CarBookingService _bookingService = CarBookingService();
  final ScrollController _scrollController = ScrollController();

  List<CarBooking> _bookings = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  late AnimationController _animationController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 0.3, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _loadBookings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _staggerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    if (!_isRefreshing) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final bookings = await _bookingService.getUserBookings();

      setState(() {
        _bookings = bookings;
        _isLoading = false;
        _isRefreshing = false;
      });

      _animationController.forward();
      _staggerController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _refreshBookings() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadBookings();
  }

  Future<void> _processPayment(CarBooking booking) async {
    try {
      final paymentInfo = await _bookingService.getBookingPaymentInfo(
        booking.id,
      );

      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CarPaymentScreen(paymentInfo: paymentInfo),
        ),
      );

      if (result == true) {
        _refreshBookings();
        _showSnackBar('Payment successful!', Colors.green);
      }
    } catch (e) {
      _showSnackBar('Failed to process payment: $e', Colors.red);
    }
  }

  Future<void> _cancelBooking(CarBooking booking) async {
    final confirmed = await _showCancelDialog(booking);
    if (!confirmed) return;

    try {
      await _bookingService.cancelBooking(booking.id);
      _refreshBookings();
      _showSnackBar('Booking cancelled successfully', Colors.green);
    } catch (e) {
      _showSnackBar('Failed to cancel booking: $e', Colors.red);
    }
  }

  Future<bool> _showCancelDialog(CarBooking booking) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text(
          'Are you sure you want to cancel your booking for ${booking.carName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Booking'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'My Car Bookings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
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
                onPressed: _refreshBookings,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh',
              ),
            ],
          ),

          // Content
          if (_isLoading && _bookings.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Loading your bookings...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 40,
                        color: colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Failed to load bookings',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _loadBookings,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_bookings.isEmpty)
            SliverFillRemaining(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, _slideAnimation.value),
                    end: Offset.zero,
                  ).animate(_animationController),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withOpacity(
                              0.3,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.directions_car_rounded,
                            size: 60,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'No Car Bookings Yet',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'When you book a car, it will appear here.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        FilledButton.icon(
                          onPressed: () {
                            // Navigate to car list screen
                            Navigator.of(context).pushReplacementNamed('/cars');
                          },
                          icon: const Icon(Icons.search_rounded),
                          label: const Text('Browse Cars'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, _slideAnimation.value),
                    end: Offset.zero,
                  ).animate(_animationController),
                  child: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return AnimatedBuilder(
                        animation: _staggerController,
                        builder: (context, child) {
                          final animationValue = Curves.easeOut.transform(
                            (_staggerController.value - (index * 0.1)).clamp(
                              0.0,
                              1.0,
                            ),
                          );
                          return FadeTransition(
                            opacity: Tween<double>(
                              begin: 0.0,
                              end: 1.0,
                            ).animate(
                              CurvedAnimation(
                                parent: _staggerController,
                                curve: Interval(
                                  (index * 0.1).clamp(0.0, 1.0),
                                  ((index * 0.1) + 0.5).clamp(0.0, 1.0),
                                  curve: Curves.easeOut,
                                ),
                              ),
                            ),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(0, 0.5 * (1 - animationValue)),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _staggerController,
                                  curve: Interval(
                                    (index * 0.1).clamp(0.0, 1.0),
                                    ((index * 0.1) + 0.5).clamp(0.0, 1.0),
                                    curve: Curves.easeOutBack,
                                  ),
                                ),
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: _buildBookingCard(_bookings[index]),
                              ),
                            ),
                          );
                        },
                      );
                    }, childCount: _bookings.length),
                  ),
                ),
              ),
            ),

          // Loading indicator for refresh
          if (_isRefreshing)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(CarBooking booking) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => _showBookingDetails(booking),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.directions_car_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.carName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Booking #${booking.id}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: booking.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          booking.statusIcon,
                          size: 16,
                          color: booking.statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          booking.status,
                          style: TextStyle(
                            color: booking.statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Rental Dates
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Date',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${booking.rentalStartDate.day}/${booking.rentalStartDate.month}/${booking.rentalStartDate.year}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End Date',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${booking.rentalEndDate.day}/${booking.rentalEndDate.month}/${booking.rentalEndDate.year}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Duration',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${booking.rentalDays} ${booking.rentalDays == 1 ? 'day' : 'days'}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Payment and Amount
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.payment_rounded,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Payment Status',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                    color:
                                        colorScheme.onSurface.withOpacity(0.6),
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        PaymentStatusChip(status: booking.paymentStatus),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Amount',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.formattedAmount,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),

              // Notes
              if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.note_rounded,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          booking.notes!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Action Buttons
              const SizedBox(height: 20),
              Row(
                children: [
                  // Pay Now Button (if payment pending)
                  if (booking.paymentStatus.toLowerCase() == 'pending') ...[
                    Expanded(
                      child: CustomButton(
                        onPressed: () => _processPayment(booking),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        minimumSize: const Size(0, 44),
                        borderRadius: 12,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.payment_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Pay Now',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Cancel Button (if allowed)
                  if (booking.status.toLowerCase() != 'cancelled') ...[
                    if (booking.paymentStatus.toLowerCase() != 'pending')
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _cancelBooking(booking),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cancel_outlined, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Cancel',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _cancelBooking(booking),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cancel_outlined, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Cancel',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],

                  // View Details Button
                  if (booking.status.toLowerCase() == 'cancelled' ||
                      booking.paymentStatus.toLowerCase() == 'paid')
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showBookingDetails(booking),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Details',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingDetails(CarBooking booking) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Booking Details',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Details content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: _buildBookingDetailsContent(booking),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingDetailsContent(CarBooking booking) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Car Information
        _buildDetailSection('Car Information', [
          _buildDetailRow('Car', booking.carName),
          _buildDetailRow('Booking ID', '#${booking.id}'),
          _buildDetailRow(
            'Booking Date',
            '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year}',
          ),
        ]),

        // Rental Period
        _buildDetailSection('Rental Period', [
          _buildDetailRow(
            'Start Date',
            '${booking.rentalStartDate.day}/${booking.rentalStartDate.month}/${booking.rentalStartDate.year}',
          ),
          _buildDetailRow(
            'End Date',
            '${booking.rentalEndDate.day}/${booking.rentalEndDate.month}/${booking.rentalEndDate.year}',
          ),
          _buildDetailRow('Duration', '${booking.rentalDays} days'),
        ]),

        // Payment Information
        _buildDetailSection('Payment Information', [
          _buildDetailRow('Amount', booking.formattedAmount),
          _buildDetailRow('Payment Status', booking.paymentStatus),
          if (booking.paymentMethod != null)
            _buildDetailRow('Payment Method', booking.paymentMethod!),
          if (booking.paymentDate != null)
            _buildDetailRow(
              'Payment Date',
              '${booking.paymentDate!.day}/${booking.paymentDate!.month}/${booking.paymentDate!.year}',
            ),
          if (booking.transactionId != null)
            _buildDetailRow('Transaction ID', booking.transactionId!),
        ]),

        // Status
        _buildDetailSection('Status', [
          _buildDetailRow('Booking Status', booking.status),
        ]),

        // Notes
        if (booking.notes != null && booking.notes!.isNotEmpty)
          _buildDetailSection('Special Requests', [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                booking.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ]),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
