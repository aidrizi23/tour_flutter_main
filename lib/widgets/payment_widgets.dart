import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final bool enabled;

  const PaymentButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = 56,
    this.enabled = true,
  });

  @override
  State<PaymentButton> createState() => _PaymentButtonState();
}

class _PaymentButtonState extends State<PaymentButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled && !widget.isLoading) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enabled && !widget.isLoading) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enabled && !widget.isLoading) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = widget.backgroundColor ?? colorScheme.primary;
    final foregroundColor = widget.foregroundColor ?? colorScheme.onPrimary;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.enabled && !widget.isLoading ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width ?? double.infinity,
              height: widget.height,
              decoration: BoxDecoration(
                color:
                    widget.enabled
                        ? backgroundColor.withOpacity(_isPressed ? 0.9 : 1.0)
                        : backgroundColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                boxShadow:
                    widget.enabled && !widget.isLoading
                        ? [
                          BoxShadow(
                            color: backgroundColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  child:
                      widget.isLoading
                          ? Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  foregroundColor,
                                ),
                              ),
                            ),
                          )
                          : Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.icon != null) ...[
                                  Icon(
                                    widget.icon,
                                    color: foregroundColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  widget.label,
                                  style: TextStyle(
                                    color: foregroundColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class StripeButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;

  const StripeButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PaymentButton(
      label: isLoading ? 'Processing...' : 'Pay with Stripe',
      onPressed: onPressed,
      isLoading: isLoading,
      enabled: enabled,
      icon: Icons.credit_card_rounded,
      backgroundColor: const Color(0xFF635BFF), // Stripe's brand color
      foregroundColor: Colors.white,
    );
  }
}

class PaymentStatusChip extends StatelessWidget {
  final String status;
  final Color? backgroundColor;
  final Color? textColor;

  const PaymentStatusChip({
    super.key,
    required this.status,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color chipColor;
    Color chipTextColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'succeeded':
      case 'paid':
        chipColor = Colors.green.withOpacity(0.2);
        chipTextColor = Colors.green.shade700;
        icon = Icons.check_circle;
        break;
      case 'pending':
      case 'processing':
        chipColor = Colors.orange.withOpacity(0.2);
        chipTextColor = Colors.orange.shade700;
        icon = Icons.schedule;
        break;
      case 'failed':
      case 'declined':
        chipColor = Colors.red.withOpacity(0.2);
        chipTextColor = Colors.red.shade700;
        icon = Icons.error;
        break;
      default:
        chipColor = colorScheme.surfaceContainerLow;
        chipTextColor = colorScheme.onSurface;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? chipColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor ?? chipTextColor),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor ?? chipTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
