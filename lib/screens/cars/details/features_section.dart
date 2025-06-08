import 'package:flutter/material.dart';
import '../../../models/car_models.dart';

class CarFeaturesSection extends StatelessWidget {
  final List<CarFeature> features;
  const CarFeaturesSection({super.key, required this.features});

  @override
  Widget build(BuildContext context) {
    if (features.isEmpty) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 16,
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
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: colorScheme.onTertiaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "What's Included",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 1.0 : 1.2,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final f = features[index];
              return _FeatureCard(feature: f);
            },
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final CarFeature feature;
  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getFeatureIcon(feature.name),
              color: colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            feature.name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          if (feature.description != null) ...[
            const SizedBox(height: 6),
            Text(
              feature.description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  IconData _getFeatureIcon(String name) {
    switch (name.toLowerCase()) {
      case 'air conditioning':
      case 'climate control':
        return Icons.ac_unit_rounded;
      case 'bluetooth':
      case 'bluetooth connectivity':
        return Icons.bluetooth_rounded;
      case 'gps navigation':
      case 'navigation system':
        return Icons.navigation_rounded;
      case 'usb charging':
      case 'usb ports':
        return Icons.usb_rounded;
      case 'backup camera':
      case 'rear camera':
        return Icons.camera_rear_rounded;
      case 'cruise control':
        return Icons.speed_rounded;
      case 'alloy wheels':
        return Icons.tire_repair_rounded;
      case 'sunroof':
        return Icons.wb_sunny_rounded;
      case 'leather seats':
        return Icons.weekend_rounded;
      case 'keyless entry':
        return Icons.key_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }
}
