import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/tour_models.dart';
import '../../models/booking_models.dart';
import '../../services/tour_service.dart';
import '../../services/booking_service.dart';
import '../../widgets/custom_button.dart';
import '../booking/payment_screen.dart';
import 'details/image_gallery.dart';
import 'details/tour_header.dart';
import 'details/info_section.dart';
import 'details/description_section.dart';
import 'details/features_section.dart';
import 'details/itinerary_section.dart';
import 'details/reviews_section.dart';
import 'details/booking_bottom_sheet.dart';

class TourDetailsScreen extends StatefulWidget {
  final int tourId;
  const TourDetailsScreen({super.key, required this.tourId});

  @override
  State<TourDetailsScreen> createState() => _TourDetailsScreenState();
}

class _TourDetailsScreenState extends State<TourDetailsScreen> {
  final TourService _tourService = TourService();
  final BookingService _bookingService = BookingService();
  final TextEditingController _reviewController = TextEditingController();

  Tour? _tour;
  List<TourReview> _reviews = [];
  bool _loading = true;
  bool _loadingReviews = false;
  bool _submittingReview = false;

  // Booking state
  DateTime? _selectedDate;
  int _people = 1;
  AvailabilityResponse? _availability;
  bool _checkingAvailability = false;
  bool _booking = false;

  int _selectedRating = 5;

  @override
  void initState() {
    super.initState();
    _loadTour();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadTour() async {
    try {
      final tour = await _tourService.getTourById(widget.tourId);
      final rev = await _tourService.getTourReviews(widget.tourId);
      setState(() {
        _tour = tour;
        _reviews = rev;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load tour: $e')));
      }
    }
  }

  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty || _tour == null) return;
    setState(() => _submittingReview = true);
    try {
      final review = await _tourService.addReview(
        AddReviewRequest(
          tourId: _tour!.id,
          comment: _reviewController.text.trim(),
          rating: _selectedRating,
        ),
      );
      setState(() {
        _reviews.insert(0, review);
        _reviewController.clear();
        _selectedRating = 5;
        _submittingReview = false;
      });
    } catch (e) {
      setState(() => _submittingReview = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit review: $e')));
    }
  }

  Future<void> _checkAvailability() async {
    if (_selectedDate == null || _tour == null) return;
    setState(() {
      _checkingAvailability = true;
      _availability = null;
    });
    try {
      final avail = await _bookingService.checkAvailability(
        tourId: _tour!.id,
        startDate: _selectedDate!,
        groupSize: _people,
      );
      setState(() {
        _availability = avail;
        _checkingAvailability = false;
      });
    } catch (e) {
      setState(() => _checkingAvailability = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Availability check failed: $e')));
    }
  }

  Future<void> _book() async {
    if (_tour == null || _selectedDate == null) return;
    setState(() => _booking = true);
    try {
      final booking = await _bookingService.quickBook(
        tourId: _tour!.id,
        numberOfPeople: _people,
        tourStartDate: _selectedDate!,
        initiatePaymentImmediately: true,
      );
      if (booking.paymentInfo != null) {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PaymentScreen(paymentInfo: booking.paymentInfo!),
          ),
        );
        if (result == true) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Booking failed: $e')));
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  void _openBookingSheet() {
    if (_tour == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => BookingBottomSheet(
            selectedDate: _selectedDate,
            people: _people,
            onDateChanged: (d) => setState(() => _selectedDate = d),
            onPeopleChanged: (p) => setState(() => _people = p),
            onCheckAvailability: _checkAvailability,
            availability: _availability,
            checkingAvailability: _checkingAvailability,
            booking: _booking,
            onBook: _book,
          ),
    );
  }

  List<Widget> _buildSlivers() {
    return [
      SliverAppBar(
        pinned: true,
        expandedHeight: 300,
        flexibleSpace: FlexibleSpaceBar(
          background: TourImageGallery(images: _tour!.images),
        ),
      ),
      SliverToBoxAdapter(child: TourHeader(tour: _tour!)),
      SliverToBoxAdapter(child: TourInfoSection(tour: _tour!)),
      SliverToBoxAdapter(child: TourDescriptionSection(tour: _tour!)),
      SliverToBoxAdapter(child: TourFeaturesSection(features: _tour!.features)),
      SliverToBoxAdapter(
        child: TourItinerarySection(items: _tour!.itineraryItems),
      ),
      SliverToBoxAdapter(
        child: ReviewsSection(
          reviews: _reviews,
          reviewController: _reviewController,
          selectedRating: _selectedRating,
          onRatingChanged: (r) => setState(() => _selectedRating = r),
          onSubmit: _submittingReview ? () {} : _submitReview,
          submitting: _submittingReview,
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 100)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_tour == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tour')),
        body: const Center(child: Text('Tour not found')),
      );
    }
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomButton(
          onPressed: _openBookingSheet,
          text: 'Book Now',
          minimumSize: const Size(double.infinity, 56),
        ),
      ),
      body: CustomScrollView(slivers: _buildSlivers()),
    );
  }
}
