import 'package:flutter/material.dart';
import '../../../models/tour_models.dart';

class TourDescriptionSection extends StatelessWidget {
  final Tour tour;
  const TourDescriptionSection({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        tour.description,
        style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
      ),
    );
  }
}
