import 'package:flutter/material.dart';
import '../../../models/tour_models.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/modern_widgets.dart';

class ReviewsSection extends StatelessWidget {
  final List<TourReview> reviews;
  final TextEditingController reviewController;
  final int selectedRating;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;
  final bool submitting;
  const ReviewsSection({
    super.key,
    required this.reviews,
    required this.reviewController,
    required this.selectedRating,
    required this.onRatingChanged,
    required this.onSubmit,
    required this.submitting,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reviews',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...reviews.map((e) => _ReviewTile(review: e)),
          const SizedBox(height: 16),
          Text('Add your review', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          ModernRatingStars(
            rating: selectedRating.toDouble(),
            onRatingChanged: onRatingChanged,
          ),
          CustomTextField(
            controller: reviewController,
            label: 'Write a review',
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          CustomButton(
            onPressed: submitting ? null : onSubmit,
            isLoading: submitting,
            text: 'Submit',
            minimumSize: const Size(double.infinity, 48),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final TourReview review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.userName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ModernRatingStars(rating: review.rating.toDouble(), size: 16),
            ],
          ),
          const SizedBox(height: 4),
          Text(review.comment),
        ],
      ),
    );
  }
}
