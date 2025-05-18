import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tour_flutter_main/models/house_models.dart';
import 'package:tour_flutter_main/services/house_service.dart';
import 'package:tour_flutter_main/widgets/custom_button.dart';
import 'package:tour_flutter_main/widgets/modern_widgets.dart';
import 'package:tour_flutter_main/widgets/payment_method_widget.dart';

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

class _HouseBookingScreenState extends State<HouseBookingScreen> {
  final HouseService _houseService = HouseService();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _discountCodeController = TextEditingController();

  bool _isLoading = false;
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

  @override
  void initState() {
    super.initState();
    _discountedTotal = widget.availabilityResponse.totalPrice;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _discountCodeController.dispose();
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
                  title: 'House Booking Confirmed',
                  message:
                      'Your booking at ${widget.house.name} has been confirmed!',
                  details: [
                    'Check-in: ${DateFormat('MMM dd, yyyy').format(widget.checkInDate)}',
                    'Check-out: ${DateFormat('MMM dd, yyyy').format(widget.checkOutDate)}',
                    'Guests: ${widget.guestCount}',
                    'Total: \$${_discountedTotal.toStringAsFixed(2)}',
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
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Booking')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
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
                            const Icon(Icons.error_outline, color: Colors.red),
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
    );
  }

  Widget _buildBookingSummary() {
    return ModernCard(
      padding: const EdgeInsets.all(16),
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
                                    Icons.image_not_supported_outlined,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              );
                            },
                          )
                          : Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: Icon(
                                Icons.home_outlined,
                                color: Colors.grey[500],
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
              if (widget.availabilityResponse.cleaningFee != null) ...[
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        if (details.isNotEmpty)
          Expanded(
            child: Text(
              details,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color:
                isDiscount
                    ? Colors.green
                    : isBold
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildGuestInfoSection() {
    return Column(
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
    );
  }

  Widget _buildDiscountSection() {
    return Column(
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
                      _hasDiscount
                          ? Colors.red
                          : Theme.of(context).colorScheme.primary,
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
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
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
    );
  }

  Widget _buildTermsSection() {
    return Row(
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
              const Text(
                'I agree to the Terms and Conditions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'By checking this box, you agree to the house rules, cancellation policy, and payment terms.',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
