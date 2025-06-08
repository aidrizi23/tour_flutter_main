import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/tour_models.dart';

class TourHeader extends StatelessWidget {
  final Tour tour;
  final bool isDesktop;
  final bool showBackButton;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;

  const TourHeader({
    super.key,
    required this.tour,
    this.isDesktop = false,
    this.showBackButton = true,
    this.onFavoriteToggle,
    this.isFavorite = false,
  });

  String get _formatPrice {
    if (tour.discountedPrice != null && tour.discountedPrice! < tour.price) {
      return '\$${tour.discountedPrice!.toStringAsFixed(0)}';
    }
    return '\$${tour.price.toStringAsFixed(0)}';
  }

  String? get _originalPrice {
    if (tour.discountedPrice != null && tour.discountedPrice! < tour.price) {
      return '\$${tour.price.toStringAsFixed(0)}';
    }
    return null;
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'challenging':
      case 'hard':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Icons.terrain_rounded;
      case 'moderate':
        return Icons.hiking_rounded;
      case 'challenging':
      case 'hard':
        return Icons.landscape_rounded;
      default:
        return Icons.explore_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: isDesktop 
            ? const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              )
            : null,
        boxShadow: isDesktop
            ? [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with back button and favorite
          if (showBackButton)
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainer,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onFavoriteToggle?.call();
                  },
                  icon: Icon(
                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFavorite ? Colors.red : colorScheme.outline,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainer,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),

          if (showBackButton) const SizedBox(height: 24),

          // Tour category and rating
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tour.category.toUpperCase(),
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              if (tour.averageRating != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tour.averageRating!.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      if (tour.reviewCount != null && tour.reviewCount! > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(${tour.reviewCount})',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 20),

          // Tour title
          Text(
            tour.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: colorScheme.onSurface,
              fontSize: isDesktop ? 32 : 28,
            ),
          ),

          const SizedBox(height: 16),

          // Location
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tour.location,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                    fontSize: isDesktop ? 18 : 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Tour details row
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildDetailChip(
                icon: Icons.schedule_rounded,
                label: '${tour.durationInDays} day${tour.durationInDays != 1 ? 's' : ''}',
                color: colorScheme.secondary,
                backgroundColor: colorScheme.secondaryContainer,
              ),
              _buildDetailChip(
                icon: Icons.group_rounded,
                label: 'Max ${tour.maxGroupSize} people',
                color: colorScheme.tertiary,
                backgroundColor: colorScheme.tertiaryContainer,
              ),
              _buildDetailChip(
                icon: _getDifficultyIcon(tour.difficultyLevel),
                label: tour.difficultyLevel,
                color: _getDifficultyColor(tour.difficultyLevel),
                backgroundColor: _getDifficultyColor(tour.difficultyLevel).withValues(alpha: 0.1),
              ),
              _buildDetailChip(
                icon: tour.activityType.toLowerCase() == 'outdoor' 
                    ? Icons.nature_rounded 
                    : tour.activityType.toLowerCase() == 'indoor'
                        ? Icons.business_rounded
                        : Icons.explore_rounded,
                label: tour.activityType,
                color: colorScheme.primary,
                backgroundColor: colorScheme.primaryContainer,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Price section
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price per person',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatPrice,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: isDesktop ? 36 : 32,
                        ),
                      ),
                      if (_originalPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          _originalPrice!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                            decoration: TextDecoration.lineThrough,
                            fontSize: isDesktop ? 20 : 18,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (tour.discountPercentage != null && tour.discountPercentage! > 0) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${tour.discountPercentage}% OFF',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}