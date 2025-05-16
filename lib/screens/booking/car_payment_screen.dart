import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../models/car_booking_models.dart';
import '../../services/car_booking_service.dart';
import '../../services/stripe_service.dart';
import '../../utils/billing_details_helper.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/payment_widgets.dart';
import '../../widgets/payment_method_widget.dart';

class CarPaymentScreen extends StatefulWidget {
  final CarPaymentInfo paymentInfo;

  const CarPaymentScreen({super.key, required this.paymentInfo});

  @override
  State<CarPaymentScreen> createState() => _CarPaymentScreenState();
}

class _CarPaymentScreenState extends State<CarPaymentScreen>
    with TickerProviderStateMixin {
  final CarBookingService _bookingService = CarBookingService();
  final ScrollController _scrollController = ScrollController();

  bool _isProcessingPayment = false;
  bool _paymentMethodReady = false;
  String? _errorMessage;
  Map<String, dynamic>? _selectedPaymentMethod;
  BillingDetails? _billingDetails;

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 0.3, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);

    _loadBillingDetails();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBillingDetails() async {
    final billingDetails = await BillingDetailsHelper.getUserBillingDetails();
    setState(() {
      _billingDetails = billingDetails;
    });
  }

  Future<void> _processPayment() async {
    if (!_paymentMethodReady || _selectedPaymentMethod == null) {
      _showError('Please enter valid payment details');
      return;
    }

    setState(() {
      _isProcessingPayment = true;
      _errorMessage = null;
    });

    HapticFeedback.lightImpact();

    try {
      // Confirm payment with Stripe
      final success = await StripeService.confirmPayment(
        clientSecret: widget.paymentInfo.clientSecret!,
        billingDetails: _billingDetails,
      );

      if (success) {
        // Process payment with backend
        await _bookingService.processPayment(
          bookingId: widget.paymentInfo.bookingId,
          paymentIntentId: widget.paymentInfo.transactionId,
        );

        HapticFeedback.heavyImpact();
        _showSuccessAnimation();
      } else {
        throw Exception('Payment confirmation failed');
      }
    } catch (e) {
      setState(() {
        _isProcessingPayment = false;
        _errorMessage = StripeService.getErrorMessage(e);
      });
      _showError(_errorMessage!);
    }
  }

  void _showError(String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _showSuccessAnimation() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PaymentSuccessDialog(),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pop(); // Close dialog
      Navigator.of(context).pop(true); // Return to previous screen with success
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
        title: const Text('Complete Payment'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          if (_isProcessingPayment)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, _slideAnimation.value),
            end: Offset.zero,
          ).animate(_animationController),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Enhanced Booking Summary
                    _buildBookingSummary(),

                    // Payment Method Section
                    _buildPaymentMethodSection(),

                    // Billing Information
                    _buildBillingSection(),

                    // Security Notice
                    _buildSecurityNotice(),

                    // Total and Pay Button
                    _buildPaymentButton(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingSummary() {
    final colorScheme = Theme.of(context).colorScheme;

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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.directions_car_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Booking Summary',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Car Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.paymentInfo.carName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSummaryRow(
                  'Rental Period',
                  widget.paymentInfo.rentalPeriod,
                ),
                _buildSummaryRow(
                  'Total Days',
                  '${widget.paymentInfo.totalDays} days',
                ),
                _buildSummaryRow(
                  'Daily Rate',
                  widget.paymentInfo.formattedDailyRate,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Payment Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  widget.paymentInfo.paymentStatus == 'Pending'
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    widget.paymentInfo.paymentStatus == 'Pending'
                        ? Colors.orange.withOpacity(0.3)
                        : Colors.green.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.paymentInfo.paymentStatus == 'Pending'
                      ? Icons.schedule
                      : Icons.check_circle,
                  color:
                      widget.paymentInfo.paymentStatus == 'Pending'
                          ? Colors.orange
                          : Colors.green,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Payment Status: ${widget.paymentInfo.paymentStatus}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          widget.paymentInfo.paymentStatus == 'Pending'
                              ? Colors.orange.shade800
                              : Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Total Amount
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary.withOpacity(0.1),
                  colorScheme.secondary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Text(
                        widget.paymentInfo.formattedTotalAmount,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
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
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.payment_rounded,
                  color: colorScheme.onSecondaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Payment Method',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          PaymentMethodWidget(
            onPaymentMethodChanged: (paymentMethod) {
              setState(() {
                _selectedPaymentMethod = paymentMethod;
                _paymentMethodReady = paymentMethod?['complete'] == true;
              });
            },
            enabled: !_isProcessingPayment,
          ),

          const SizedBox(height: 16),

          // Stripe Button (main payment method)
          if (widget.paymentInfo.clientSecret != null)
            StripeButton(
              onPressed:
                  _paymentMethodReady && !_isProcessingPayment
                      ? _processPayment
                      : null,
              isLoading: _isProcessingPayment,
              enabled: _paymentMethodReady,
            ),
        ],
      ),
    );
  }

  Widget _buildBillingSection() {
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
        children: [
          BillingDetailsHelper.buildBillingForm(
            onChanged: (billingDetails) {
              setState(() {
                _billingDetails = billingDetails;
              });
            },
            initialDetails: _billingDetails,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNotice() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.security, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Payment',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your payment is processed securely using Stripe\'s encrypted servers.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Error Message
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Payment Button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              onPressed:
                  _paymentMethodReady && !_isProcessingPayment
                      ? _processPayment
                      : null,
              isLoading: _isProcessingPayment,
              minimumSize: const Size(double.infinity, 60),
              borderRadius: 16,
              backgroundColor:
                  _paymentMethodReady && !_isProcessingPayment
                      ? colorScheme.primary
                      : colorScheme.outline.withOpacity(0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isProcessingPayment) ...[
                    Icon(
                      _paymentMethodReady
                          ? Icons.payment_rounded
                          : Icons.warning_rounded,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    _isProcessingPayment
                        ? 'Processing Payment...'
                        : _paymentMethodReady
                        ? 'Pay ${widget.paymentInfo.formattedTotalAmount}'
                        : 'Enter Payment Details',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Terms and Conditions
          Text(
            'By completing this payment, you agree to our Terms of Service and Privacy Policy.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class PaymentSuccessDialog extends StatefulWidget {
  const PaymentSuccessDialog({super.key});

  @override
  State<PaymentSuccessDialog> createState() => _PaymentSuccessDialogState();
}

class _PaymentSuccessDialogState extends State<PaymentSuccessDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

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

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _checkController, curve: Curves.easeOut));

    _playAnimation();
  }

  void _playAnimation() async {
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _checkController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
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
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _scaleAnimation,
                child: Column(
                  children: [
                    Text(
                      'Payment Successful!',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your car rental has been confirmed.',
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
