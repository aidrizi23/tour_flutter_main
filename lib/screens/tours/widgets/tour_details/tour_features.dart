import 'package:flutter/material.dart';
import '../../../../models/tour_models.dart';

class TourFeatures extends StatelessWidget {
  final Tour tour;
  final bool isDesktop;
  final bool isCompact;

  const TourFeatures({
    super.key,
    required this.tour,
    this.isDesktop = false,
    this.isCompact = false,
  });

  IconData _getFeatureIcon(String featureName) {
    final name = featureName.toLowerCase();
    if (name.contains('guide') || name.contains('instructor')) {
      return Icons.person_rounded;
    } else if (name.contains('meal') || name.contains('food') || name.contains('lunch') || name.contains('dinner')) {
      return Icons.restaurant_rounded;
    } else if (name.contains('transport') || name.contains('bus') || name.contains('car')) {
      return Icons.directions_bus_rounded;
    } else if (name.contains('hotel') || name.contains('accommodation') || name.contains('stay')) {
      return Icons.hotel_rounded;
    } else if (name.contains('equipment') || name.contains('gear')) {
      return Icons.backpack_rounded;
    } else if (name.contains('insurance')) {
      return Icons.security_rounded;
    } else if (name.contains('photo') || name.contains('camera')) {
      return Icons.camera_alt_rounded;
    } else if (name.contains('wifi') || name.contains('internet')) {
      return Icons.wifi_rounded;
    } else if (name.contains('water') || name.contains('drink')) {
      return Icons.local_drink_rounded;
    } else if (name.contains('entry') || name.contains('ticket') || name.contains('admission')) {
      return Icons.confirmation_number_rounded;
    } else if (name.contains('safety') || name.contains('first aid')) {
      return Icons.medical_services_rounded;
    } else {
      return Icons.check_circle_rounded;
    }
  }

  Color _getFeatureColor(String featureName) {
    final name = featureName.toLowerCase();
    if (name.contains('guide') || name.contains('instructor')) {
      return Colors.blue;
    } else if (name.contains('meal') || name.contains('food')) {
      return Colors.orange;
    } else if (name.contains('transport')) {
      return Colors.purple;
    } else if (name.contains('hotel') || name.contains('accommodation')) {
      return Colors.indigo;
    } else if (name.contains('equipment') || name.contains('gear')) {
      return Colors.brown;
    } else if (name.contains('insurance') || name.contains('safety')) {
      return Colors.red;
    } else if (name.contains('photo')) {
      return Colors.pink;
    } else if (name.contains('water') || name.contains('drink')) {
      return Colors.cyan;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (tour.features.isEmpty) {
      return const SizedBox.shrink();
    }

    if (isCompact) {
      return _buildCompactFeatures(colorScheme);
    }

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
                  Icons.stars_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'What\'s Included',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            'Everything you need for an amazing experience',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 24),

          // Features grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 2 : 1,
              childAspectRatio: isDesktop ? 4 : 5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: tour.features.length,
            itemBuilder: (context, index) {
              final feature = tour.features[index];
              final featureColor = _getFeatureColor(feature.name);
              
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: featureColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: featureColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getFeatureIcon(feature.name),
                        color: featureColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            feature.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (feature.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              feature.description!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Additional info
          if (tour.features.length > 6) ...[
            const SizedBox(height: 24),
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
                      'And many more features to make your tour unforgettable!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

  Widget _buildCompactFeatures(ColorScheme colorScheme) {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What\'s Included',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...tour.features.take(6).map((feature) {
              final featureColor = _getFeatureColor(feature.name);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: featureColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getFeatureIcon(feature.name),
                        color: featureColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (tour.features.length > 6) ...[
              const SizedBox(height: 8),
              Text(
                '+${tour.features.length - 6} more features',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}