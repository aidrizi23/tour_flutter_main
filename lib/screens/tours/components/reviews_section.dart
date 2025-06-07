import 'package:flutter/material.dart';
import '../../../models/tour_models.dart';
import '../../../widgets/modern_widgets.dart';

class ReviewsSection extends StatelessWidget {
  final List<TourReview> reviews;
  const ReviewsSection({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: ModernCard(
          child: Center(
            child: Text(
              'No reviews yet',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: reviews
              .map(
                (r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.userName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      ModernRatingStars(rating: r.rating.toDouble()),
                      const SizedBox(height: 4),
                      Text(r.comment),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
