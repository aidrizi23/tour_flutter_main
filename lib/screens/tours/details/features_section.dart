import 'package:flutter/material.dart';
import '../../../models/tour_models.dart';

class TourFeaturesSection extends StatelessWidget {
  final List<TourFeature> features;
  const TourFeaturesSection({super.key, required this.features});

  @override
  Widget build(BuildContext context) {
    if (features.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Features',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in features)
                Chip(
                  label: Text(f.name),
                  backgroundColor: colorScheme.primaryContainer,
                  labelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
