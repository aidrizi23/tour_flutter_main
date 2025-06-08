import 'package:flutter/material.dart';
import '../../../models/tour_models.dart';
import '../../../widgets/modern_widgets.dart';

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
              Expanded(child: Text(tour.location)),
              if (tour.averageRating != null)
                Row(
                  children: [
                    ModernRatingStars(rating: tour.averageRating!, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '(${tour.reviewCount ?? 0})',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                tour.displayPrice,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/person',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
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
