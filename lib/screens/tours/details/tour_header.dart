import 'package:flutter/material.dart';
import '../../../models/tour_models.dart';

class TourHeader extends StatelessWidget {
  final Tour tour;
  const TourHeader({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tour.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(tour.location),
              const Spacer(),
              if (tour.averageRating != null)
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(tour.averageRating!.toStringAsFixed(1)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tour.displayPrice,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (tour.hasDiscount)
            Text(
              tour.originalPrice,
              style: theme.textTheme.bodySmall?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
        ],
      ),
    );
  }
}
