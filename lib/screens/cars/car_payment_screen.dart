import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../models/car_booking_models.dart';
import '../../services/car_booking_service.dart';
import '../../widgets/payment_method_widget.dart';
import '../../widgets/payment_widgets.dart';
import '../../utils/billing_details_helper.dart';

class CarPaymentScreen extends StatefulWidget {
  final CarPaymentInfo paymentInfo;

  const CarPaymentScreen({super.key, required this.paymentInfo});

  @override
  State<CarPaymentScreen> createState() => _CarPaymentScreenState();
}

class _CarPaymentScreenState extends State<CarPaymentScreen>
    with TickerProviderStateMixin {
  final CarBookingService _bookingService = CarBookingService();

  bool _isProcessing = false;
  bool _isPaymentComplete = false;
  bool _showError = false;
  String _errorMessage = '';
  bool _saveCard = false;
  CardFieldInputDetails? _cardFieldInputDetails;
  BillingDetails? _billingDetails;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Load user billing details
    _loadBillingDetails();

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadBillingDetails() async {
    final billingDetails = await BillingDetailsHelper.getUserBillingDetails();
    setState(() {
      _billingDetails = billingDetails;
    });
  }

  Future<void> _processPayment() async {
    if (_cardFieldInputDetails == null || !_cardFieldInputDetails!.complete) {
      setState(() {
        _showError = true;
        _errorMessage = 'Please enter valid card information';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _showError = false;
    });

    try {
      // Get the booking ID
      final bookingId = widget.paymentInfo.bookingId;

      // If we don't already have a payment intent client secret, create one
      CarPaymentInfo paymentInfo = widget.paymentInfo;
      if (widget.paymentInfo.clientSecret == null ||
          widget.paymentInfo.clientSecret!.isEmpty) {
        await _bookingService.initiatePayment(bookingId);
        // Get updated payment info with client secret
        paymentInfo = await _bookingService.getBookingPaymentInfo(bookingId);
      }

      if (paymentInfo.clientSecret == null ||
          paymentInfo.clientSecret!.isEmpty) {
        throw Exception('Unable to create payment intent');
      }

      // First, create a payment method
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(billingDetails: _billingDetails),
        ),
      );

      // Then, confirm the payment with the payment method
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentInfo.clientSecret!,
        data: PaymentMethodParams.cardFromMethodId(
          paymentMethodData: PaymentMethodDataCardFromMethod(
            paymentMethodId: paymentMethod.id,
            // Optional fields for 3DS authentication if needed
            // cvc: _cardFieldInputDetails?.cvc,
          ),
        ),
      );

      // Check if payment succeeded
      if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
        // Process payment on server
        await _bookingService.processPayment(
          bookingId: bookingId,
          paymentMethod: paymentMethod.id,
          paymentIntentId: paymentIntent.id,
        );

        setState(() {
          _isPaymentComplete = true;
          _isProcessing = false;
        });

        // Show success and navigate back
        _showSuccessAnimation();
      } else {
        throw Exception('Payment failed: ${paymentIntent.status}');
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      setState(() {
        _isProcessing = false;
        _showError = true;
        _errorMessage = 'Payment failed: ${e.toString()}';
      });
    }
  }

  void _showSuccessAnimation() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.transparent,
            content: Center(
              child: material.Card(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 80),
                      SizedBox(height: 20),
                      Text(
                        'Payment Successful!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('Your car rental has been confirmed.'),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );

    // Return to details screen with success result
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking summary card
                  _buildBookingSummaryCard(),

                  const SizedBox(height: 24),

                  // Payment method
                  Text(
                    'Payment Method',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Card input form
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
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
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.credit_card,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Card Information',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CardField(
                          onCardChanged: (card) {
                            setState(() {
                              _cardFieldInputDetails = card;
                              _showError = false;
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.outline.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.outline.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            labelText: 'Card Details',
                            hintText: 'XXXX XXXX XXXX XXXX',
                          ),
                          enablePostalCode: true,
                        ),
                        if (_cardFieldInputDetails != null &&
                            !_cardFieldInputDetails!.complete)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Please enter complete card information',
                              style: TextStyle(
                                color: colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Billing details option
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: SwitchListTile(
                      value: _saveCard,
                      onChanged: (value) {
                        setState(() {
                          _saveCard = value;
                        });
                      },
                      title: const Text('Save card for future payments'),
                      subtitle: const Text(
                        'Your payment information will be securely stored',
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  // Error message
                  if (_showError) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: colorScheme.error),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Payment button
                  SizedBox(
                    width: double.infinity,
                    child: StripeButton(
                      onPressed: _isProcessing ? null : _processPayment,
                      isLoading: _isProcessing,
                      enabled:
                          _cardFieldInputDetails?.complete == true &&
                          !_isProcessing,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Secure payment note
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 16,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Secure payment powered by Stripe',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingSummaryCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Car image
              Container(
                width: 100,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: colorScheme.surfaceContainerLow,
                  image:
                      widget.paymentInfo.carImageUrl != null
                          ? DecorationImage(
                            image: NetworkImage(
                              widget.paymentInfo.carImageUrl!,
                            ),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    widget.paymentInfo.carImageUrl == null
                        ? Center(
                          child: Icon(
                            Icons.directions_car,
                            size: 40,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        )
                        : null,
              ),

              const SizedBox(width: 16),

              // Car details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.paymentInfo.carName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.paymentInfo.rentalPeriod,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.paymentInfo.totalDays} ${widget.paymentInfo.totalDays == 1 ? 'day' : 'days'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 32),

          // Payment details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Rate:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                widget.paymentInfo.formattedDailyRate,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rental Duration:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${widget.paymentInfo.totalDays} ${widget.paymentInfo.totalDays == 1 ? 'day' : 'days'}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),

          const Divider(height: 16),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount:',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                widget.paymentInfo.formattedTotalAmount,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),

          // Payment status
          const SizedBox(height: 16),
          PaymentStatusChip(status: widget.paymentInfo.paymentStatus),
        ],
      ),
    );
  }
}
