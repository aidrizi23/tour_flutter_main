import 'package:flutter/material.dart';
import 'package:tour_flutter_main/screens/tours/tour_details_screen.dart';
import '../models/tour_models.dart';
import '../services/recommendation_service.dart';
import '../widgets/recommendation_widgets.dart';

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

  @override
  void initState() {
    super.initState();
    _loadSimilarTours();
  }

  Future<void> _loadSimilarTours() async {
    try {
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
        });
      }
    }
  }

  void _navigateToTourDetails(Tour tour) {
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

    return SimilarToursSection(
      tourId: widget.tourId,
      similarTours: _similarTours,
      onTourTap: _navigateToTourDetails,
      isLoading: _isLoading,
    );
  }
}
