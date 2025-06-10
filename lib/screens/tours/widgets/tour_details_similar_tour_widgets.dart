import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tour_flutter_main/models/tour_models.dart';
import 'package:tour_flutter_main/screens/tours/tour_details_screen.dart';
import 'package:tour_flutter_main/services/recommendation_service.dart';

class TourDetailsSimilarToursWidget extends StatefulWidget {
  final int tourId;

  const TourDetailsSimilarToursWidget({super.key, required this.tourId});

  @override
  State<TourDetailsSimilarToursWidget> createState() =>
      _TourDetailsSimilarToursWidgetState();
}

class _TourDetailsSimilarToursWidgetState
    extends State<TourDetailsSimilarToursWidget> {
  final RecommendationService _recommendationService = RecommendationService();

  List<Tour> _similarTours = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadSimilarTours();
  }

  Future<void> _loadSimilarTours() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final tours = await _recommendationService.getSimilarTours(widget.tourId);

      // Make sure we don't include the current tour in the similar tours list
      final filteredTours =
          tours.where((tour) => tour.id != widget.tourId).toList();

      if (mounted) {
        setState(() {
          _similarTours = filteredTours;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _similarTours = [];
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _navigateToTourDetails(Tour tour) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TourDetailsScreen(tourId: tour.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only show the widget if we have similar tours or are still loading
    if (_similarTours.isEmpty && !_isLoading) {
      return const SizedBox.shrink();
    }

    return _buildSimilarToursSection();
  }

  Widget _buildSimilarToursSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isMobile = screenWidth < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, isMobile ? 12 : 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.travel_explore_rounded,
                  color: colorScheme.primary,
                  size: isMobile ? 20 : 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You Might Also Like',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        fontSize: isMobile ? 18 : 20,
                      ),
                    ),
                    if (!_isLoading && _similarTours.isNotEmpty)
                      Text(
                        'Similar experiences for you',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: isMobile ? 12 : 13,
                        ),
                      ),
                  ],
                ),
              ),
              if (_isLoading) ...[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),

        if (_isLoading)
          _buildLoadingState()
        else if (_hasError)
          _buildErrorState()
        else
          SizedBox(
            height: isMobile ? 200 : 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _similarTours.length,
              itemBuilder: (context, index) {
                final tour = _similarTours[index];
                return _buildSimilarTourCard(tour);
              },
            ),
          ),

        SizedBox(height: isMobile ? 24 : 32),
      ],
    );
  }

  Widget _buildSimilarTourCard(Tour tour) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.of(context).size.width < 600;

    final cardWidth = isMobile ? 200.0 : 230.0;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: () => _navigateToTourDetails(tour),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Stack(
                children: [
                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child:
                        tour.mainImageUrl != null
                            ? Image.network(
                              tour.mainImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    color: colorScheme.surfaceContainerLow,
                                    child: Center(
                                      child: Icon(
                                        Icons.landscape_rounded,
                                        size: 32,
                                        color: colorScheme.outline,
                                      ),
                                    ),
                                  ),
                            )
                            : Container(
                              color: colorScheme.surfaceContainerLow,
                              child: Center(
                                child: Icon(
                                  Icons.landscape_rounded,
                                  size: 32,
                                  color: colorScheme.outline,
                                ),
                              ),
                            ),
                  ),

                  // Semi-transparent gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Price badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
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
                        tour.displayPrice,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),

                  // Location at bottom
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 10,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            tour.location,
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tour name
                    Text(
                      tour.name,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 13 : 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Duration and rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tour.durationText,
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        if (tour.averageRating != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                tour.averageRating!.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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

  Widget _buildLoadingState() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return SizedBox(
      height: isMobile ? 180 : 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 4,
        itemBuilder: (context, index) => _buildLoadingCard(),
      ),
    );
  }

  Widget _buildLoadingCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final cardWidth = isMobile ? 200.0 : 230.0;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shimmer image placeholder
            Container(height: 100, color: colorScheme.surfaceContainerLow),

            // Shimmer content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title shimmer
                  Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 14,
                    width: 150,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Details shimmer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 18,
                        width: 60,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Container(
                        height: 18,
                        width: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
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

  Widget _buildErrorState() {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: isMobile ? 8 : 16),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.errorContainer),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: colorScheme.error,
            size: isMobile ? 24 : 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unable to load recommendations',
                  style: TextStyle(
                    color: colorScheme.error,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please try again later',
                  style: TextStyle(
                    color: colorScheme.onErrorContainer,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: _loadSimilarTours, child: const Text('Retry')),
        ],
      ),
    );
  }
}
