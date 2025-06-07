import 'package:flutter/material.dart';
import '../../models/tour_models.dart';
import '../../services/tour_service.dart';
import '../../services/booking_service.dart';
import '../../widgets/modern_widgets.dart';
import '../../widgets/custom_button.dart';
import 'components/tour_header.dart';
import 'components/tour_info_section.dart';
import 'components/reviews_section.dart';
import 'components/booking_panel.dart';

class TourDetailsScreen extends StatefulWidget {
  final int tourId;
  const TourDetailsScreen({super.key, required this.tourId});

  @override
  State<TourDetailsScreen> createState() => _TourDetailsScreenState();
}

class _TourDetailsScreenState extends State<TourDetailsScreen> {
  final TourService _tourService = TourService();
  final BookingService _bookingService = BookingService();

  Tour? _tour;
  List<TourReview> _reviews = [];
  bool _loading = true;
  String? _error;
  bool _showBooking = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final tour = await _tourService.getTourById(widget.tourId);
      final reviews = await _tourService.getTourReviews(widget.tourId);
      setState(() {
        _tour = tour;
        _reviews = reviews;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _openBooking() {
    setState(() => _showBooking = true);
  }

  void _closeBooking() {
    setState(() => _showBooking = false);
  }

  Future<void> _proceedBooking() async {
    setState(() => _showBooking = false);
    if (!mounted) return;
    ModernSnackBar.show(
      context,
      message: 'Booking flow not implemented',
      type: SnackBarType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null || _tour == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tour Details')),
        body: Center(child: Text(_error ?? 'Failed to load tour')),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              TourHeader(tour: _tour!),
              SliverToBoxAdapter(child: TourInfoSection(tour: _tour!)),
              SliverToBoxAdapter(child: ReviewsSection(reviews: _reviews)),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: CustomButton(
              onPressed: _openBooking,
              text: 'Book Now',
              icon: Icons.calendar_today,
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
          if (_showBooking)
            BookingPanel(onClose: _closeBooking, onBook: _proceedBooking),
        ],
      ),
    );
  }
}
