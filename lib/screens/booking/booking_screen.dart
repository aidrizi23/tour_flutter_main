import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/booking_models.dart';
import '../../services/booking_service.dart';
import '../../widgets/custom_button.dart';
import 'booking_details_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with TickerProviderStateMixin {
  final BookingService _bookingService = BookingService();
  List<Booking> _bookings = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _loadBookings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    try {
      final bookings = await _bookingService.getUserBookings();
      if (mounted) {
        setState(() {
          _bookings = bookings;
          _isLoading = false;
          _errorMessage = null;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshBookings() async {
    setState(() {
      _isRefreshing = true;
    });

    HapticFeedback.lightImpact();

    try {
      final bookings = await _bookingService.getUserBookings();
      if (mounted) {
        setState(() {
          _bookings = bookings;
          _isRefreshing = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _cancelBooking(Booking booking) async {
    final colorScheme = Theme.of(context).colorScheme;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.cancel_rounded, color: colorScheme.error),
                const SizedBox(width: 12),
                const Text('Cancel Booking'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Are you sure you want to cancel this booking?'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.tourName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('Tour Date: ${booking.formattedTourDate}'),
                      Text('Amount: ${booking.formattedTotal}'),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep Booking'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
                child: const Text('Cancel Booking'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _bookingService.cancelBooking(booking.id);
        await _refreshBookings();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Booking cancelled successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel booking: $e'),
              backgroundColor: colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isLoading || _isRefreshing ? null : _refreshBookings,
            icon:
                _isRefreshing
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading your bookings...'),
                  ],
                ),
              )
              : FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildBookingsList(),
                ),
              ),
    );
  }

  Widget _buildBookingsList() {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 60,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to load bookings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
              CustomButton(
                onPressed: _loadBookings,
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Try Again'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.book_online_rounded,
                  size: 60,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No bookings yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'When you book a tour, it will appear here',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomButton(
                onPressed: () {
                  // Navigate to tours screen
                  Navigator.of(context).pushNamed('/tours');
                },
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.explore_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Explore Tours'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshBookings,
      color: colorScheme.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];

          // Simple animation for each card that doesn't interfere with scrolling
          return AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 50)),
            curve: Curves.easeOut,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildBookingCard(booking),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.tourName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: booking.statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: booking.statusColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(
                      color: booking.statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Booking details
            Row(
              children: [
                _buildDetailItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Tour Date',
                  value: booking.formattedTourDate,
                ),
                const SizedBox(width: 20),
                _buildDetailItem(
                  icon: Icons.group_rounded,
                  label: 'People',
                  value: '${booking.numberOfPeople}',
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _buildDetailItem(
                  icon: Icons.receipt_rounded,
                  label: 'Booking ID',
                  value: '#${booking.id}',
                ),
                const SizedBox(width: 20),
                _buildDetailItem(
                  icon: Icons.monetization_on_rounded,
                  label: 'Amount',
                  value: booking.formattedTotal,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Payment status
            Row(
              children: [
                Icon(
                  Icons.payment_rounded,
                  size: 16,
                  color: booking.paymentStatusColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'Payment: ',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: booking.paymentStatusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.paymentStatus,
                    style: TextStyle(
                      color: booking.paymentStatusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            if (booking.notes != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // Navigate to booking details
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  BookingDetailsScreen(bookingId: booking.id),
                        ),
                      );

                      // Refresh bookings if the booking was cancelled
                      if (result == true) {
                        await _refreshBookings();
                      }
                    },
                    icon: const Icon(Icons.visibility_rounded, size: 18),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (booking.status.toLowerCase() == 'confirmed' ||
                    booking.status.toLowerCase() == 'pending') ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _cancelBooking(booking),
                      icon: const Icon(Icons.cancel_rounded, size: 18),
                      label: const Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: colorScheme.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
