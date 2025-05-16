import 'dart:convert';
import 'dart:developer';
import '../models/booking_models.dart';
import '../utils/api_client.dart';

class BookingService {
  final ApiClient _apiClient = ApiClient();

  // Check tour availability
  Future<AvailabilityResponse> checkAvailability({
    required int tourId,
    required DateTime startDate,
    required int groupSize,
  }) async {
    try {
      log('Checking availability for tour ID: $tourId');

      final request = CheckAvailabilityRequest(
        tourId: tourId,
        startDate: startDate,
        groupSize: groupSize,
      );

      final response = await _apiClient.post(
        '/tours/check-availability',
        data: request.toJson(),
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final availability = AvailabilityResponse.fromJson(data);
        log('Availability checked successfully: ${availability.isAvailable}');
        return availability;
      } else {
        log('Failed to check availability. Status: ${response.statusCode}');
        throw Exception('Failed to check availability');
      }
    } catch (e) {
      log('Error checking availability: $e');
      rethrow;
    }
  }

  // Quick book tour
  Future<Booking> quickBook({
    required int tourId,
    required int numberOfPeople,
    required DateTime tourStartDate,
    String? notes,
    bool initiatePaymentImmediately = true,
    String? discountCode,
  }) async {
    try {
      log('Creating quick booking for tour ID: $tourId');

      final request = QuickBookRequest(
        tourId: tourId,
        numberOfPeople: numberOfPeople,
        tourStartDate: tourStartDate,
        notes: notes,
        initiatePaymentImmediately: initiatePaymentImmediately,
        discountCode: discountCode,
      );

      final response = await _apiClient.post(
        '/bookings/quick-book',
        data: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final booking = Booking.fromJson(data);
        log('Quick booking created successfully: ${booking.id}');
        return booking;
      } else {
        log('Failed to create booking. Status: ${response.statusCode}');

        // Parse error message if available
        try {
          final errorData = json.decode(response.body);
          final message = errorData['message'] ?? 'Failed to create booking';
          throw Exception(message);
        } catch (e) {
          throw Exception('Failed to create booking');
        }
      }
    } catch (e) {
      log('Error creating booking: $e');

      // Handle specific error cases
      if (e.toString().contains('401')) {
        throw Exception('Please log in to book a tour');
      } else if (e.toString().contains('400')) {
        throw Exception(
          'Invalid booking details. Please check your information.',
        );
      } else if (e.toString().contains('409')) {
        throw Exception('Tour is no longer available for the selected date');
      }

      rethrow;
    }
  }

  // Get user bookings
  Future<List<Booking>> getUserBookings() async {
    try {
      log('Fetching user bookings');

      final response = await _apiClient.get('/bookings', requiresAuth: true);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        final bookings =
            data
                .map((item) => Booking.fromJson(item as Map<String, dynamic>))
                .toList();
        log('Successfully fetched ${bookings.length} bookings');
        return bookings;
      } else {
        log('Failed to fetch bookings. Status: ${response.statusCode}');
        throw Exception('Failed to fetch bookings');
      }
    } catch (e) {
      log('Error fetching bookings: $e');

      if (e.toString().contains('401')) {
        throw Exception('Please log in to view your bookings');
      }

      rethrow;
    }
  }

  // Get booking by ID
  Future<Booking> getBookingById(int bookingId) async {
    try {
      log('Fetching booking with ID: $bookingId');

      final response = await _apiClient.get(
        '/bookings/$bookingId',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final booking = Booking.fromJson(data);
        log('Successfully fetched booking: ${booking.id}');
        return booking;
      } else if (response.statusCode == 404) {
        throw Exception('Booking not found');
      } else {
        log('Failed to fetch booking. Status: ${response.statusCode}');
        throw Exception('Failed to fetch booking');
      }
    } catch (e) {
      log('Error fetching booking: $e');
      rethrow;
    }
  }

  // Get booking payment info
  Future<PaymentInfo> getBookingPaymentInfo(int bookingId) async {
    try {
      log('Fetching payment info for booking ID: $bookingId');

      final response = await _apiClient.get(
        '/bookings/$bookingId/payment-info',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final paymentInfo = PaymentInfo.fromJson(data);
        log('Successfully fetched payment info');
        return paymentInfo;
      } else {
        log('Failed to fetch payment info. Status: ${response.statusCode}');
        throw Exception('Failed to fetch payment information');
      }
    } catch (e) {
      log('Error fetching payment info: $e');
      rethrow;
    }
  }

  // Apply discount to booking
  Future<Booking> applyDiscountToBooking(
    int bookingId,
    String discountCode,
  ) async {
    try {
      log('Applying discount code "$discountCode" to booking ID: $bookingId');

      final response = await _apiClient.post(
        '/bookings/$bookingId/apply-discount',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final booking = Booking.fromJson(data);
        log('Successfully applied discount');
        return booking;
      } else {
        log('Failed to apply discount. Status: ${response.statusCode}');

        // Parse error message for discount-specific errors
        try {
          final errorData = json.decode(response.body);
          final message = errorData['message'] ?? 'Failed to apply discount';
          throw Exception(message);
        } catch (e) {
          throw Exception('Failed to apply discount code');
        }
      }
    } catch (e) {
      log('Error applying discount: $e');

      // Handle specific discount error cases
      if (e.toString().contains('400')) {
        throw Exception('Invalid discount code');
      } else if (e.toString().contains('404')) {
        throw Exception('Discount code not found or expired');
      } else if (e.toString().contains('409')) {
        throw Exception('Discount code already applied to this booking');
      }

      rethrow;
    }
  }

  // Initiate payment
  Future<Map<String, dynamic>> initiatePayment(int bookingId) async {
    try {
      log('Initiating payment for booking ID: $bookingId');

      final response = await _apiClient.post(
        '/bookings/$bookingId/initiate-payment',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log('Payment initiated successfully');
        return data;
      } else {
        log('Failed to initiate payment. Status: ${response.statusCode}');
        throw Exception('Failed to initiate payment');
      }
    } catch (e) {
      log('Error initiating payment: $e');
      rethrow;
    }
  }

  // Process payment
  Future<Booking> processPayment({
    required int bookingId,
    String? paymentMethod,
    String? paymentIntentId,
    String? stripeToken,
  }) async {
    try {
      log('Processing payment for booking ID: $bookingId');

      final requestData = <String, dynamic>{};
      if (paymentMethod != null) requestData['paymentMethod'] = paymentMethod;
      if (paymentIntentId != null) {
        requestData['paymentIntentId'] = paymentIntentId;
      }
      if (stripeToken != null) requestData['stripeToken'] = stripeToken;

      final response = await _apiClient.post(
        '/bookings/$bookingId/process-payment',
        data: requestData,
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final booking = Booking.fromJson(data);
        log('Payment processed successfully');
        return booking;
      } else {
        log('Failed to process payment. Status: ${response.statusCode}');

        // Parse payment error message
        try {
          final errorData = json.decode(response.body);
          final message = errorData['message'] ?? 'Payment failed';
          throw Exception(message);
        } catch (e) {
          throw Exception('Payment failed. Please try again.');
        }
      }
    } catch (e) {
      log('Error processing payment: $e');

      // Handle specific payment error cases
      if (e.toString().contains('400')) {
        throw Exception('Invalid payment details');
      } else if (e.toString().contains('402')) {
        throw Exception('Payment was declined');
      } else if (e.toString().contains('409')) {
        throw Exception('Booking payment has already been processed');
      }

      rethrow;
    }
  }

  // Cancel booking
  Future<void> cancelBooking(int bookingId) async {
    try {
      log('Cancelling booking ID: $bookingId');

      final response = await _apiClient.post(
        '/bookings/$bookingId/cancel',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        log('Booking cancelled successfully');
      } else {
        log('Failed to cancel booking. Status: ${response.statusCode}');

        // Parse cancellation error message
        try {
          final errorData = json.decode(response.body);
          final message = errorData['message'] ?? 'Failed to cancel booking';
          throw Exception(message);
        } catch (e) {
          throw Exception('Failed to cancel booking');
        }
      }
    } catch (e) {
      log('Error cancelling booking: $e');

      // Handle specific cancellation error cases
      if (e.toString().contains('400')) {
        throw Exception('Booking cannot be cancelled');
      } else if (e.toString().contains('404')) {
        throw Exception('Booking not found');
      } else if (e.toString().contains('409')) {
        throw Exception(
          'Booking has already been cancelled or is too close to start date',
        );
      }

      rethrow;
    }
  }

  // Helper method to format date for API
  String formatDateForApi(DateTime date) {
    return date.toUtc().toIso8601String();
  }

  // Helper method to validate booking dates
  bool isValidBookingDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return date.isAfter(tomorrow) || date.isAtSameMomentAs(tomorrow);
  }
}
