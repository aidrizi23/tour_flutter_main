import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../models/tour_models.dart';

class TourBookingPanel extends StatefulWidget {
  final Tour tour;
  final bool isDesktop;
  final VoidCallback? onBookNow;
  final ValueChanged<DateTime?>? onDateChanged;
  final ValueChanged<int>? onPeopleChanged;
  final DateTime? selectedDate;
  final int numberOfPeople;
  final bool isLoading;

  const TourBookingPanel({
    super.key,
    required this.tour,
    this.isDesktop = false,
    this.onBookNow,
    this.onDateChanged,
    this.onPeopleChanged,
    this.selectedDate,
    this.numberOfPeople = 1,
    this.isLoading = false,
  });

  @override
  State<TourBookingPanel> createState() => _TourBookingPanelState();
}

class _TourBookingPanelState extends State<TourBookingPanel> {
  double get _totalPrice {
    final basePrice = widget.tour.discountedPrice ?? widget.tour.price;
    return basePrice * widget.numberOfPeople;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(widget.isDesktop ? 32 : 24),
      margin: EdgeInsets.symmetric(horizontal: widget.isDesktop ? 0 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
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
                  Icons.calendar_today_rounded,
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
                      'Book Your Adventure',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Secure your spot today',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Date selection
          _buildDateSelector(colorScheme),

          const SizedBox(height: 20),

          // Number of people selector
          _buildPeopleSelector(colorScheme),

          const SizedBox(height: 24),

          // Price breakdown
          _buildPriceBreakdown(colorScheme),

          const SizedBox(height: 32),

          // Book now button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.isLoading || widget.selectedDate == null 
                  ? null 
                  : () {
                      HapticFeedback.mediumImpact();
                      widget.onBookNow?.call();
                    },
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: widget.isDesktop ? 20 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: widget.isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('Checking availability...'),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.travel_explore_rounded),
                        const SizedBox(width: 12),
                        Text(
                          'Book Now - \$${_totalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: widget.isDesktop ? 18 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          if (widget.selectedDate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Free cancellation up to 24 hours before the tour',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateSelector(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              HapticFeedback.selectionClick();
              final date = await showDatePicker(
                context: context,
                initialDate: widget.selectedDate ?? DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: colorScheme,
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                widget.onDateChanged?.call(date);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.selectedDate != null
                    ? colorScheme.primary.withValues(alpha: 0.05)
                    : colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.selectedDate != null
                      ? colorScheme.primary.withValues(alpha: 0.3)
                      : colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: widget.selectedDate != null
                        ? colorScheme.primary
                        : colorScheme.outline,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.selectedDate != null
                          ? '${widget.selectedDate!.day}/${widget.selectedDate!.month}/${widget.selectedDate!.year}'
                          : 'Choose your preferred date',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: widget.selectedDate != null
                            ? colorScheme.onSurface
                            : colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: colorScheme.outline,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeopleSelector(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of People',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.numberOfPeople > 1
                    ? () {
                        HapticFeedback.selectionClick();
                        widget.onPeopleChanged?.call(widget.numberOfPeople - 1);
                      }
                    : null,
                icon: const Icon(Icons.remove_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: widget.numberOfPeople > 1
                      ? colorScheme.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  foregroundColor: widget.numberOfPeople > 1
                      ? colorScheme.primary
                      : colorScheme.outline,
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${widget.numberOfPeople} ${widget.numberOfPeople == 1 ? 'person' : 'people'}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.numberOfPeople < widget.tour.maxGroupSize
                    ? () {
                        HapticFeedback.selectionClick();
                        widget.onPeopleChanged?.call(widget.numberOfPeople + 1);
                      }
                    : null,
                icon: const Icon(Icons.add_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: widget.numberOfPeople < widget.tour.maxGroupSize
                      ? colorScheme.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  foregroundColor: widget.numberOfPeople < widget.tour.maxGroupSize
                      ? colorScheme.primary
                      : colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Maximum ${widget.tour.maxGroupSize} people per booking',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown(ColorScheme colorScheme) {
    final basePrice = widget.tour.discountedPrice ?? widget.tour.price;
    final hasDiscount = widget.tour.discountedPrice != null && 
                       widget.tour.discountedPrice! < widget.tour.price;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price per person',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              Row(
                children: [
                  if (hasDiscount) ...[
                    Text(
                      '\$${widget.tour.price.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    '\$${basePrice.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.numberOfPeople} × \$${basePrice.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              Text(
                '\$${_totalPrice.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          if (hasDiscount) ...[
            const SizedBox(height: 8),
            Divider(color: colorScheme.outline.withValues(alpha: 0.2)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discount (${widget.tour.discountPercentage}%)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '-\$${((widget.tour.price - basePrice) * widget.numberOfPeople).toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Divider(color: colorScheme.outline.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                '\$${_totalPrice.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}