import 'package:flutter/material.dart';
import '../../../../models/tour_models.dart';

class TourInformation extends StatelessWidget {
  final Tour tour;
  final bool isDesktop;

  const TourInformation({
    super.key,
    required this.tour,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
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
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'About This Tour',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            tour.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.6,
              fontSize: isDesktop ? 16 : 15,
            ),
          ),

          const SizedBox(height: 32),

          // Quick stats grid
          _buildQuickStats(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, ColorScheme colorScheme) {
    final stats = [
      {
        'icon': Icons.schedule_rounded,
        'title': 'Duration',
        'value': '${tour.durationInDays} day${tour.durationInDays != 1 ? 's' : ''}',
        'color': colorScheme.primary,
      },
      {
        'icon': Icons.group_rounded,
        'title': 'Group Size',
        'value': 'Max ${tour.maxGroupSize}',
        'color': colorScheme.secondary,
      },
      {
        'icon': Icons.terrain_rounded,
        'title': 'Difficulty',
        'value': tour.difficultyLevel,
        'color': _getDifficultyColor(tour.difficultyLevel),
      },
      {
        'icon': tour.activityType.toLowerCase() == 'outdoor' 
            ? Icons.nature_rounded 
            : tour.activityType.toLowerCase() == 'indoor'
                ? Icons.business_rounded
                : Icons.explore_rounded,
        'title': 'Activity Type',
        'value': tour.activityType,
        'color': colorScheme.tertiary,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tour Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 2 : 2,
            childAspectRatio: isDesktop ? 3.5 : 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(
                        stat['icon'] as IconData,
                        color: stat['color'] as Color,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          stat['title'] as String,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stat['value'] as String,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
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
}