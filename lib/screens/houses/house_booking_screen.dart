import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/house_models.dart';
import '../../services/house_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/modern_widgets.dart';
import '../../widgets/payment_method_widget.dart';
import 'booking_confirmation_screen.dart';

class HouseBookingScreen extends StatefulWidget {
  final House house;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guestCount;
  final HouseAvailabilityResponse availabilityResponse;

  const HouseBookingScreen({
    super.key,
    required this.house,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guestCount,
    required this.availabilityResponse,
  });

  @override
  State<HouseBookingScreen> createState() => _HouseBookingScreenState();
}

class _HouseBookingScreenState extends State<HouseBookingScreen>
    with SingleTickerProviderStateMixin {
  final HouseService _houseService = HouseService();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _discountCodeController = TextEditingController();

  final bool _isLoading = false;
  bool _isApplyingDiscount = false;
  bool _isCreatingBooking = false;
  bool _agreeToTerms = false;
  bool _sendUpdates = true;
  Map<String, dynamic>? _paymentMethodData;

  String? _discountError;
  String? _bookingError;
  double _discountedTotal = 0;
  int _discountPercentage = 0;
  bool _hasDiscount = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _discountedTotal = widget.availabilityResponse.totalPrice;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _discountCodeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _applyDiscountCode() async {
    if (_discountCodeController.text.trim().isEmpty) {
      setState(() {
        _discountError = 'Please enter a discount code';
      });
      return;
    }

    setState(() {
      _isApplyingDiscount = true;
      _discountError = null;
    });

    try {
      // TODO: Replace with actual discount validation API call
      // This is a mock implementation
      await Future.delayed(const Duration(seconds: 1));

      if (_discountCodeController.text.trim().toUpperCase() == 'DISCOUNT20') {
        setState(() {
          _discountPercentage = 20;
          _discountedTotal = widget.availabilityResponse.totalPrice * 0.8;
          _hasDiscount = true;
          _isApplyingDiscount = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Discount applied successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        setState(() {
          _discountError = 'Invalid discount code';
          _isApplyingDiscount = false;
        });
      }
    } catch (e) {
      setState(() {
        _discountError = 'Error applying discount: ${e.toString()}';
        _isApplyingDiscount = false;
      });
    }
  }

  Future<void> _createBooking() async {
    if (!_agreeToTerms) {
      setState(() {
        _bookingError = 'Please agree to the terms and conditions';
      });
      return;
    }

    if (_paymentMethodData == null) {
      setState(() {
        _bookingError = 'Please add a payment method';
      });
      return;
    }

    setState(() {
      _isCreatingBooking = true;
      _bookingError = null;
    });

    try {
      // Create the booking
      final booking = await _houseService.createBooking(
        houseId: widget.house.id,
        checkInDate: widget.checkInDate,
        checkOutDate: widget.checkOutDate,
        guestCount: widget.guestCount,
        notes:
            _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
        discountCode: _hasDiscount ? _discountCodeController.text.trim() : null,
      );

      if (mounted) {
        setState(() {
          _isCreatingBooking = false;
        });

        // Navigate to confirmation screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => BookingConfirmationScreen(
                  title: 'Booking Confirmed!',
                  message:
                      'Your stay at ${widget.house.name} has been confirmed!',
                  details: [
                    'Check-in: ${DateFormat('MMM dd, yyyy').format(widget.checkInDate)}',
                    'Check-out: ${DateFormat('MMM dd, yyyy').format(widget.checkOutDate)}',
                    'Guests: ${widget.guestCount}',
                    'Total: \$${_discountedTotal.toStringAsFixed(2)}',
                    'Property: ${widget.house.propertyType} in ${widget.house.city}, ${widget.house.country}',
                  ],
                  imagePath: widget.house.mainImageUrl,
                  bookingId: booking.id.toString(),
                ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _bookingError = 'Error creating booking: ${e.toString()}';
          _isCreatingBooking = false;
        });
      }
    }
  }

  void _handlePaymentMethodChanged(Map<String, dynamic>? paymentData) {
    setState(() {
      _paymentMethodData = paymentData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Booking'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 32,
                    vertical: 16,
                  ),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBookingSummary(),
                          const SizedBox(height: 24),
                          _buildGuestInfoSection(),
                          const SizedBox(height: 24),
                          _buildDiscountSection(),
                          const SizedBox(height: 24),
                          _buildPaymentSection(),
                          const SizedBox(height: 24),
                          _buildTermsSection(),
                          const SizedBox(height: 24),
                          if (_bookingError != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _bookingError!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'Complete Booking',
                            icon: Icons.check_circle,
                            isLoading: _isCreatingBooking,
                            onPressed: _createBooking,
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildBookingSummary() {
    final colorScheme = Theme.of(context).colorScheme;

    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // House image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child:
                      widget.house.mainImageUrl != null
                          ? Image.network(
                            widget.house.mainImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Center(
                                  child: Icon(
                                    widget.house.propertyTypeIconData,
                                    color: Colors.grey[500],
                                    size: 40,
                                  ),
                                ),
                              );
                            },
                          )
                          : Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: Icon(
                                widget.house.propertyTypeIconData,
                                color: Colors.grey[500],
                                size: 40,
                              ),
                            ),
                          ),
                ),
              ),
              const SizedBox(width: 16),

              // House info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.house.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.house.displayLocation,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${widget.house.bedrooms} bed · ${widget.house.bathrooms} bath · ${widget.guestCount} guests',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),

          // Booking details
          Row(
            children: [
              Expanded(
                child: _buildBookingDetail(
                  'Check-in',
                  DateFormat('MMM dd, yyyy').format(widget.checkInDate),
                  Icons.login,
                ),
              ),
              Expanded(
                child: _buildBookingDetail(
                  'Check-out',
                  DateFormat('MMM dd, yyyy').format(widget.checkOutDate),
                  Icons.logout,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pricing details
          Column(
            children: [
              _buildPriceItem(
                'Nightly Rate:',
                '\$${widget.availabilityResponse.nightlyRate.toStringAsFixed(2)} × ${widget.availabilityResponse.nights} nights',
                '\$${(widget.availabilityResponse.nightlyRate * widget.availabilityResponse.nights).toStringAsFixed(2)}',
              ),
              if (widget.availabilityResponse.cleaningFee != null &&
                  widget.availabilityResponse.cleaningFee! > 0) ...[
                const SizedBox(height: 8),
                _buildPriceItem(
                  'Cleaning Fee:',
                  '',
                  '\$${widget.availabilityResponse.cleaningFee!.toStringAsFixed(2)}',
                ),
              ],
              if (_hasDiscount) ...[
                const SizedBox(height: 8),
                _buildPriceItem(
                  'Discount:',
                  '$_discountPercentage% off',
                  '-\$${(widget.availabilityResponse.totalPrice - _discountedTotal).toStringAsFixed(2)}',
                  isDiscount: true,
                ),
              ],
              const Divider(height: 24),
              _buildPriceItem(
                'Total:',
                '',
                '\$${_discountedTotal.toStringAsFixed(2)}',
                isBold: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetail(String label, String value, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: colorScheme.primary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceItem(
    String label,
    String details,
    String value, {
    bool isBold = false,
    bool isDiscount = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        if (details.isNotEmpty)
          Expanded(
            child: Text(
              details,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color:
                isDiscount
                    ? Colors.green
                    : isBold
                    ? colorScheme.primary
                    : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildGuestInfoSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Special Requests',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Notes for the host (optional)',
              hintText: 'Any special requests or information for your stay...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _sendUpdates,
                onChanged: (value) {
                  setState(() {
                    _sendUpdates = value ?? false;
                  });
                },
              ),
              Expanded(
                child: Text(
                  'Send me updates about my booking',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discount Code',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _discountCodeController,
                  enabled: !_hasDiscount,
                  decoration: InputDecoration(
                    labelText: 'Enter discount code',
                    hintText: 'e.g. SUMMER20',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText: _discountError,
                    suffixIcon:
                        _hasDiscount
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : null,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      _hasDiscount
                          ? () {
                            setState(() {
                              _hasDiscount = false;
                              _discountPercentage = 0;
                              _discountedTotal =
                                  widget.availabilityResponse.totalPrice;
                              _discountCodeController.clear();
                            });
                          }
                          : _isApplyingDiscount
                          ? null
                          : _applyDiscountCode,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    backgroundColor:
                        _hasDiscount ? Colors.red : colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isApplyingDiscount
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Text(_hasDiscount ? 'Remove' : 'Apply'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Try "DISCOUNT20" for 20% off your first booking!',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          PaymentMethodWidget(
            onPaymentMethodChanged: _handlePaymentMethodChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terms and Conditions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreeToTerms = value ?? false;
                  });
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'I agree to the Terms and Conditions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'By checking this box, you agree to the house rules, cancellation policy, and payment terms.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                        children: [
                          TextSpan(
                            text: 'Cancellation Policy: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const TextSpan(
                            text:
                                'Free cancellation up to 48 hours before check-in. After that, the first night is non-refundable.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
