import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/recommendation_models.dart';
import '../models/tour_models.dart';

// Section title widget with optional "See All" button
class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllPressed;
  final bool isLoading;
  final IconData? icon;

  const SectionTitle({
    super.key,
    required this.title,
    this.onSeeAllPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 16, color: colorScheme.primary),
                ),
                const SizedBox(width: 12),
              ],
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              if (isLoading) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onSeeAllPressed != null)
          TextButton.icon(
            onPressed: onSeeAllPressed,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('See All'),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
      ],
    );
  }
}

// Enhanced horizontal list for recommended tours
class RecommendedToursList extends StatelessWidget {
  final List<RecommendedTour> recommendations;
  final Function(Tour) onTourTap;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final double cardWidth;

  const RecommendedToursList({
    super.key,
    required this.recommendations,
    required this.onTourTap,
    this.isLoading = false,
    this.onRefresh,
    this.cardWidth = 280,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return SizedBox(
        height: 340, // Increased height for better cards
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          itemBuilder: (context, index) => _buildLoadingCard(context),
        ),
      );
    }

    if (recommendations.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border_rounded,
                size: 48,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No recommendations available yet',
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
              ),
              if (onRefresh != null) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Refresh'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 380, // Increased height for better cards
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final recommendation = recommendations[index];
          // Add a small rotation effect for a more dynamic feel
          return Transform.rotate(
            angle: (index % 2 == 0) ? 0.01 : -0.01, // Very slight angle
            child: _buildRecommendationCard(context, recommendation, index),
          );
        },
      ),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    RecommendedTour recommendation,
    int index,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tour = recommendation.tour;

    // Create a smooth tween animation for hover-like effect
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)), // Slides up
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 16, bottom: 8, top: 8),
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 6, // Increased elevation for better depth
          shadowColor: Colors.black.withOpacity(0.2),
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTourTap(tour);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section with overlay
                Stack(
                  children: [
                    // Image with gradient container
                    Container(
                      height: 180, // Increased height
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primary.withOpacity(0.9),
                            colorScheme.primary.withOpacity(0.6),
                          ],
                        ),
                      ),
                      child:
                          tour.mainImageUrl != null
                              ? Hero(
                                tag: 'tour_${tour.id}',
                                child: Image.network(
                                  tour.mainImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          _buildImagePlaceholder(context),
                                ),
                              )
                              : _buildImagePlaceholder(context),
                    ),

                    // Gradient overlay for better text readability
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Category badge at top left
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(tour.category),
                              size: 12,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tour.category,
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Location at bottom
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tour.location,
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Price badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              tour.hasDiscount
                                  ? Colors.red
                                  : colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          tour.displayPrice,
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                    // Discount badge if applicable
                    if (tour.hasDiscount)
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade700,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.flash_on_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${tour.discountPercentage}% OFF',
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                // Content section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tour name with star rating
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                tour.name,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (tour.averageRating != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer
                                      .withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      tour.averageRating!.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Features chips in a wrap
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildFeatureChip(
                              context,
                              icon: Icons.schedule_rounded,
                              label: tour.durationText,
                              color: colorScheme.primaryContainer,
                            ),
                            _buildFeatureChip(
                              context,
                              icon: tour.activityIcon,
                              label: tour.activityType,
                              color: colorScheme.secondaryContainer,
                            ),
                            _buildFeatureChip(
                              context,
                              icon: Icons.speed_rounded,
                              label: tour.difficultyLevel,
                              color: _getDifficultyColor(
                                tour.difficultyLevel,
                                colorScheme,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Reason for recommendation in a highlighted container
                        if (recommendation.reasonForRecommendation.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colorScheme.primary.withOpacity(0.1),
                                  colorScheme.primaryContainer.withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: colorScheme.primary.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    recommendation.reasonForRecommendation,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface.withOpacity(
                                        0.8,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'adventure':
        return Icons.terrain_rounded;
      case 'cultural':
        return Icons.museum_rounded;
      case 'relaxation':
        return Icons.spa_rounded;
      case 'historical':
        return Icons.history_edu_rounded;
      case 'culinary':
        return Icons.restaurant_rounded;
      case 'wildlife':
        return Icons.pets_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getDifficultyColor(String difficulty, ColorScheme colorScheme) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green.withOpacity(0.2);
      case 'moderate':
        return Colors.orange.withOpacity(0.2);
      case 'challenging':
        return Colors.red.withOpacity(0.2);
      default:
        return colorScheme.surfaceContainerLow;
    }
  }

  Widget _buildFeatureChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colorScheme.onSurface.withOpacity(0.7)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.4),
            colorScheme.secondary.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.landscape_rounded,
              size: 40,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 8),
            Text(
              'Image not available',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 16, bottom: 4, top: 4),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6, // Increased elevation
        shadowColor: Colors.black.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated shimmer effect for loading
            _buildShimmerContainer(
              context: context,
              height: 180,
              width: double.infinity,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),

            // Shimmer content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title shimmer
                  Row(
                    children: [
                      Expanded(
                        child: _buildShimmerContainer(
                          context: context,
                          height: 18,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildShimmerContainer(
                        context: context,
                        height: 24,
                        width: 40,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildShimmerContainer(
                    context: context,
                    height: 18,
                    width: 200,
                    borderRadius: BorderRadius.circular(4),
                  ),

                  const SizedBox(height: 16),

                  // Features shimmer
                  Row(
                    children: [
                      _buildShimmerContainer(
                        context: context,
                        height: 24,
                        width: 80,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(width: 8),
                      _buildShimmerContainer(
                        context: context,
                        height: 24,
                        width: 80,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ],
                  ),

                  const SizedBox(height: 50), // Spacer
                  // Recommendation reason shimmer
                  _buildShimmerContainer(
                    context: context,
                    height: 60,
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerContainer({
    required BuildContext context,
    required double height,
    double? width,
    BorderRadius? borderRadius,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainerLow,
            colorScheme.surfaceContainer,
            colorScheme.surfaceContainerLow,
          ],
        ),
      ),
    );
  }
}

// Flash deals horizontal list
class FlashDealsList extends StatelessWidget {
  final List<FlashDeal> deals;
  final Function(FlashDeal) onDealTap;
  final bool isLoading;
  final double cardWidth;

  const FlashDealsList({
    super.key,
    required this.deals,
    required this.onDealTap,
    this.isLoading = false,
    this.cardWidth = 280,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return SizedBox(
        height: 260,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          itemBuilder: (context, index) => _buildLoadingCard(context),
        ),
      );
    }

    if (deals.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flash_off_rounded,
                size: 48,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No flash deals available',
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: deals.length,
        itemBuilder: (context, index) {
          final deal = deals[index];
          return _buildDealCard(context, deal);
        },
      ),
    );
  }

  Widget _buildDealCard(BuildContext context, FlashDeal deal) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final typeColor = deal.getTypeColor();

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 16, bottom: 4, top: 4),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onDealTap(deal);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timer banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors:
                        deal.isExpiringSoon
                            ? [Colors.red.shade800, Colors.red.shade600]
                            : [Colors.amber.shade800, Colors.amber.shade600],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      deal.timeRemaining,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        deal.type,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Image section
              Stack(
                children: [
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                    ),
                    child:
                        deal.imageUrl != null
                            ? Image.network(
                              deal.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      _buildImagePlaceholder(
                                        context,
                                        typeColor,
                                      ),
                            )
                            : _buildImagePlaceholder(context, typeColor),
                  ),

                  // Location
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            deal.location,
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Discount badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        deal.displayDiscount,
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Content section
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Deal name
                    Text(
                      deal.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Description
                    Text(
                      deal.description,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // Price comparison row
                    Row(
                      children: [
                        // Original price
                        Text(
                          deal.displayOriginalPrice,
                          style: textTheme.bodyMedium?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Discounted price
                        Text(
                          deal.displayDiscountedPrice,
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Spacer(),

                        // Book button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Book',
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context, Color typeColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [typeColor.withOpacity(0.2), typeColor.withOpacity(0.1)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.local_offer_rounded,
          size: 40,
          color: typeColor.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 16, bottom: 4, top: 4),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timer banner shimmer
            Container(height: 40, color: colorScheme.surfaceContainerLow),

            // Image shimmer
            Container(
              height: 100,
              color: colorScheme.surfaceContainerLow.withOpacity(0.7),
            ),

            // Content shimmer
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title shimmer
                  Container(
                    height: 18,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Description shimmer
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 14,
                    width: 200,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Price row shimmer
                  Row(
                    children: [
                      Container(
                        height: 16,
                        width: 60,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 20,
                        width: 80,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 32,
                        width: 60,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
