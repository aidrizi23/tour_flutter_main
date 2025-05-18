import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/house_models.dart';
import '../../services/house_service.dart';
import '../../widgets/modern_widgets.dart';
import 'house_detail_screen.dart';

class HouseBookingsScreen extends StatefulWidget {
  const HouseBookingsScreen({super.key});

  @override
  State<HouseBookingsScreen> createState() => _HouseBookingsScreenState();
}

class _HouseBookingsScreenState extends State<HouseBookingsScreen> {
  final HouseService _houseService = HouseService();

  List<HouseBooking> _bookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bookings = await _houseService.getUserBookings();

      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookings,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBookings,
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? _buildErrorState()
                : _bookings.isEmpty
                ? _buildEmptyState()
                : _buildBookingsList(),
      ),
    );
  }

  Widget _buildErrorState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Bookings',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unknown error occurred. Please try again.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadBookings,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home_outlined,
                size: 64,
                color: colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Bookings Yet',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your bookings will appear here when you book a stay.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to house listings
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.search),
              label: const Text('Find a Place'),
              style: ElevatedButton.styleFrom(
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

  Widget _buildBookingsList() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildBookingCard(HouseBooking booking) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ModernCard(
        onTap: () {
          // Navigate to house detail or booking detail
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HouseDetailScreen(houseId: booking.houseId),
            ),
          );
        },
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            // Image and status
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: SizedBox(
                    height: 150,
                    width: double.infinity,
                    child:
                        booking.mainImageUrl != null
                            ? Image.network(
                              booking.mainImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: colorScheme.surfaceContainerLow,
                                  child: Center(
                                    child: Icon(
                                      Icons.home_outlined,
                                      size: 48,
                                      color: colorScheme.onSurfaceVariant
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                );
                              },
                            )
                            : Container(
                              color: colorScheme.surfaceContainerLow,
                              child: Center(
                                child: Icon(
                                  Icons.home_outlined,
                                  size: 48,
                                  color: colorScheme.onSurfaceVariant
                                      .withOpacity(0.5),
                                ),
                              ),
                            ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: booking.statusColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(booking.statusIcon, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          booking.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.houseName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (booking.location.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            booking.location,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Dates and guests
                  isMobile
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            Icons.calendar_month,
                            'Check-in',
                            DateFormat(
                              'MMM dd, yyyy',
                            ).format(booking.checkInDate),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.calendar_month,
                            'Check-out',
                            DateFormat(
                              'MMM dd, yyyy',
                            ).format(booking.checkOutDate),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.people,
                            'Guests',
                            '${booking.guestCount}',
                          ),
                        ],
                      )
                      : Row(
                        children: [
                          Expanded(
                            child: _buildInfoRow(
                              Icons.calendar_month,
                              'Check-in',
                              DateFormat(
                                'MMM dd, yyyy',
                              ).format(booking.checkInDate),
                            ),
                          ),
                          Expanded(
                            child: _buildInfoRow(
                              Icons.calendar_month,
                              'Check-out',
                              DateFormat(
                                'MMM dd, yyyy',
                              ).format(booking.checkOutDate),
                            ),
                          ),
                          Expanded(
                            child: _buildInfoRow(
                              Icons.people,
                              'Guests',
                              '${booking.guestCount}',
                            ),
                          ),
                        ],
                      ),

                  const Divider(height: 24),

                  // Payment status and price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: booking.paymentStatusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: booking.paymentStatusColor.withOpacity(0.3),
                          ),
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
                      Text(
                        booking.displayTotalAmount,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
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
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}
