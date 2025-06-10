import 'package:flutter/material.dart';
import '../../../../models/tour_models.dart';

class TourInfoSection extends StatelessWidget {
  final Tour tour;

  const TourInfoSection({
    super.key,
    required this.tour,
  });

  String _formatDuration(int days) {
    if (days == 0) return 'Duration not specified';
    if (days == 1) return '1 day';
    return '$days days';
  }

  String _formatPrice(double? price) {
    if (price == null) return 'Price on request';
    return '\$${price.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tour Information',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.access_time_rounded,
                  title: 'Duration',
                  value: _formatDuration(tour.durationInDays),
                  colorScheme: colorScheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  icon: Icons.attach_money_rounded,
                  title: 'Price',
                  value: _formatPrice(tour.price),
                  colorScheme: colorScheme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.people_rounded,
                  title: 'Group Size',
                  value: 'Max ${tour.maxGroupSize}',
                  colorScheme: colorScheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  icon: Icons.location_on_rounded,
                  title: 'Location',
                  value: tour.location,
                  colorScheme: colorScheme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.fitness_center_rounded,
                  title: 'Difficulty',
                  value: tour.difficultyLevel,
                  colorScheme: colorScheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  icon: Icons.category_rounded,
                  title: 'Category',
                  value: tour.category,
                  colorScheme: colorScheme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.hiking_rounded,
            title: 'Activity Type',
            value: tour.activityType,
            colorScheme: colorScheme,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final ColorScheme colorScheme;
  final bool fullWidth;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.colorScheme,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}