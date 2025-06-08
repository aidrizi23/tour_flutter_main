import 'package:flutter/material.dart';
import '../../../models/tour_models.dart';

class TourInfoSection extends StatelessWidget {
  final Tour tour;
  const TourInfoSection({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _InfoChip(
            icon: Icons.schedule_outlined,
            label: tour.durationText,
            backgroundColor: colorScheme.surfaceContainerLowest,
            textColor: colorScheme.onSurface,
          ),
          _InfoChip(
            icon: tour.activityIcon,
            label: tour.activityType,
            backgroundColor: colorScheme.secondaryContainer.withOpacity(0.5),
            textColor: colorScheme.onSecondaryContainer,
          ),
          _InfoChip(
            icon: Icons.trending_up_outlined,
            label: tour.difficultyLevel,
            backgroundColor: tour.difficultyColor.withOpacity(0.2),
            textColor: tour.difficultyColor,
          ),
          _InfoChip(
            icon: Icons.groups_2_outlined,
            label: 'Max ${tour.maxGroupSize}',
            backgroundColor: colorScheme.tertiaryContainer.withOpacity(0.5),
            textColor: colorScheme.onTertiaryContainer,
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
