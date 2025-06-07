import 'package:flutter/material.dart';
import '../../../models/tour_models.dart';
import '../../../widgets/modern_widgets.dart';

class TourInfoSection extends StatelessWidget {
  final Tour tour;
  const TourInfoSection({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ModernCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tour.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ModernPriceDisplay(
              price: tour.discountedPrice ?? tour.price,
              originalPrice: tour.discountedPrice != null ? tour.price : null,
            ),
            const SizedBox(height: 16),
            Text(
              tour.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
