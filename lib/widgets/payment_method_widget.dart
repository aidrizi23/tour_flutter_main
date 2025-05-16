import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentMethodWidget extends StatefulWidget {
  final Function(Map<String, dynamic>?) onPaymentMethodChanged;
  final bool enabled;

  const PaymentMethodWidget({
    super.key,
    required this.onPaymentMethodChanged,
    this.enabled = true,
  });

  @override
  State<PaymentMethodWidget> createState() => _PaymentMethodWidgetState();
}

class _PaymentMethodWidgetState extends State<PaymentMethodWidget> {
  CardFieldInputDetails? _cardDetails;
  final GlobalKey _cardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
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
                'Payment Details',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
            ),
            child: CardField(
              key: _cardKey,
              onCardChanged: (card) {
                setState(() {
                  _cardDetails = card;
                });
                widget.onPaymentMethodChanged(
                  card?.complete == true
                      ? {
                          'number': '**** **** **** ${card?.last4}',
                          'brand': card?.brand.toString().split('.').last,
                          'complete': card?.complete,
                        }
                      : null,
                );
              },
              decoration: InputDecoration(
                labelText: 'Card Information',
                hintText: '1234 1234 1234 1234',
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerLow,
                contentPadding: const EdgeInsets.all(16),
              ),
              enablePostalCode: true,
            ),
          ),
          if (_cardDetails?.complete == false && _cardDetails != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Please enter complete card information',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colorScheme.error),
              ),
            ),
          if (_cardDetails?.complete == true)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Card information is complete',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.green),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.security, color: colorScheme.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your payment information is encrypted and secure',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SavedPaymentMethodWidget extends StatelessWidget {
  final String? last4;
  final String? brand;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SavedPaymentMethodWidget({
    super.key,
    this.last4,
    this.brand,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCardIcon(brand),
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '••••  ••••  ••••  ${last4 ?? '****'}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  brand?.toUpperCase() ?? 'CARD',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit_rounded, color: colorScheme.primary),
            ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_rounded, color: colorScheme.error),
            ),
        ],
      ),
    );
  }

  IconData _getCardIcon(String? brand) {
    switch (brand?.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'amex':
      case 'american express':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }
}
