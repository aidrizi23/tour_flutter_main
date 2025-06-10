import 'package:flutter/material.dart';
import '../../../../models/tour_models.dart';

class TourFeaturesSection extends StatelessWidget {
  final List<TourFeature> features;

  const TourFeaturesSection({
    super.key,
    required this.features,
  });

  IconData _getFeatureIcon(String featureName) {
    final name = featureName.toLowerCase();
    
    if (name.contains('wifi') || name.contains('internet')) {
      return Icons.wifi_rounded;
    } else if (name.contains('food') || name.contains('meal') || name.contains('breakfast') || name.contains('lunch') || name.contains('dinner')) {
      return Icons.restaurant_rounded;
    } else if (name.contains('transport') || name.contains('pickup') || name.contains('bus') || name.contains('car')) {
      return Icons.directions_bus_rounded;
    } else if (name.contains('guide') || name.contains('expert')) {
      return Icons.person_rounded;
    } else if (name.contains('photo') || name.contains('camera')) {
      return Icons.camera_alt_rounded;
    } else if (name.contains('equipment') || name.contains('gear')) {
      return Icons.build_rounded;
    } else if (name.contains('insurance') || name.contains('safety')) {
      return Icons.security_rounded;
    } else if (name.contains('accommodation') || name.contains('hotel') || name.contains('stay')) {
      return Icons.hotel_rounded;
    } else if (name.contains('water') || name.contains('drink')) {
      return Icons.local_drink_rounded;
    } else if (name.contains('entrance') || name.contains('ticket') || name.contains('admission')) {
      return Icons.confirmation_number_rounded;
    } else if (name.contains('certificate') || name.contains('diploma')) {
      return Icons.school_rounded;
    } else if (name.contains('small') && name.contains('group')) {
      return Icons.group_rounded;
    } else if (name.contains('flexible') || name.contains('cancellation')) {
      return Icons.event_available_rounded;
    } else {
      return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (features.isEmpty) {
      return const SizedBox.shrink();
    }

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
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'What\'s Included',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => _FeatureItem(
            feature: feature,
            icon: _getFeatureIcon(feature.name),
            colorScheme: colorScheme,
            theme: theme,
          )),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final TourFeature feature;
  final IconData icon;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _FeatureItem({
    required this.feature,
    required this.icon,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (feature.description != null && feature.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    feature.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}