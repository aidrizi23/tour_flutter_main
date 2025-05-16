import 'dart:convert';
import 'dart:developer';
import '../models/car_models.dart';
import '../models/car_booking_models.dart';
import '../utils/api_client.dart';

class CarBookingService {
  final ApiClient _apiClient = ApiClient();

  // Check car availability for booking
  Future<CarAvailabilityResponse> checkAvailability({
    required int carId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      log('Checking car availability for booking. Car ID: $carId');

      final queryParams = {
        'carId': carId.toString(),
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };

      final response = await _apiClient.get(
        '/carbookings/check-availability',
        queryParams: queryParams,
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final availability = CarAvailabilityResponse.fromJson(data);
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

  // Create car booking
  Future<CarBooking> createBooking({
    required int carId,
    required DateTime rentalStartDate,
    required DateTime rentalEndDate,
    String? notes,
  }) async {
    try {
      log('Creating car booking for car ID: $carId');

      final request = CreateCarBookingRequest(
        carId: carId,
        rentalStartDate: rentalStartDate,
        rentalEndDate: rentalEndDate,
        notes: notes,
      );

      final response = await _apiClient.post(
        '/carbookings',
        data: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final booking = CarBooking.fromJson(data);
        log('Car booking created successfully: ${booking.id}');
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
      log('Error creating car booking: $e');

      // Handle specific error cases
      if (e.toString().contains('401')) {
        throw Exception('Please log in to book a car');
      } else if (e.toString().contains('400')) {
        throw Exception(
          'Invalid booking details. Please check your information.',
        );
      } else if (e.toString().contains('409')) {
        throw Exception('Car is no longer available for the selected dates');
      }

      rethrow;
    }
  }

  // Quick book car with immediate payment intent
  Future<CarBooking> quickBook({
    required int carId,
    required DateTime rentalStartDate,
    required DateTime rentalEndDate,
    String? notes,
    bool initiatePaymentImmediately = true,
  }) async {
    try {
      log('Creating quick car booking for car ID: $carId');

      final request = QuickCarBookRequest(
        carId: carId,
        rentalStartDate: rentalStartDate,
        rentalEndDate: rentalEndDate,
        notes: notes,
        initiatePaymentImmediately: initiatePaymentImmediately,
      );

      final response = await _apiClient.post(
        '/carbookings/quick-book',
        data: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final booking = CarBooking.fromJson(data);
        log('Quick car booking created successfully: ${booking.id}');
        return booking;
      } else {
        log('Failed to create quick booking. Status: ${response.statusCode}');

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
      log('Error creating quick car booking: $e');

      // Handle specific error cases
      if (e.toString().contains('401')) {
        throw Exception('Please log in to book a car');
      } else if (e.toString().contains('400')) {
        throw Exception(
          'Invalid booking details. Please check your information.',
        );
      } else if (e.toString().contains('409')) {
        throw Exception('Car is no longer available for the selected dates');
      }

      rethrow;
    }
  }

  // Get user car bookings
  Future<List<CarBooking>> getUserBookings() async {
    try {
      log('Fetching user car bookings');

      final response = await _apiClient.get('/carbookings', requiresAuth: true);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        final bookings =
            data
                .map(
                  (item) => CarBooking.fromJson(item as Map<String, dynamic>),
                )
                .toList();
        log('Successfully fetched ${bookings.length} car bookings');
        return bookings;
      } else {
        log('Failed to fetch bookings. Status: ${response.statusCode}');
        throw Exception('Failed to fetch bookings');
      }
    } catch (e) {
      log('Error fetching car bookings: $e');

      if (e.toString().contains('401')) {
        throw Exception('Please log in to view your bookings');
      }

      rethrow;
    }
  }

  // Get car booking by ID
  Future<CarBooking> getBookingById(int bookingId) async {
    try {
      log('Fetching car booking with ID: $bookingId');

      final response = await _apiClient.get(
        '/carbookings/$bookingId',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final booking = CarBooking.fromJson(data);
        log('Successfully fetched car booking: ${booking.id}');
        return booking;
      } else if (response.statusCode == 404) {
        throw Exception('Booking not found');
      } else {
        log('Failed to fetch booking. Status: ${response.statusCode}');
        throw Exception('Failed to fetch booking');
      }
    } catch (e) {
      log('Error fetching car booking: $e');
      rethrow;
    }
  }

  // Get booking payment info
  Future<CarPaymentInfo> getBookingPaymentInfo(int bookingId) async {
    try {
      log('Fetching payment info for car booking ID: $bookingId');

      final response = await _apiClient.get(
        '/carbookings/$bookingId/payment-info',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final paymentInfo = CarPaymentInfo.fromJson(data);
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

  // Update booking metadata
  Future<CarBooking> updateBookingMetadata({
    required int bookingId,
    DateTime? rentalStartDate,
    DateTime? rentalEndDate,
    String? notes,
  }) async {
    try {
      log('Updating car booking metadata for ID: $bookingId');

      final request = UpdateCarBookingMetadataRequest(
        rentalStartDate: rentalStartDate,
        rentalEndDate: rentalEndDate,
        notes: notes,
      );

      final response = await _apiClient.put(
        '/carbookings/$bookingId/metadata',
        data: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log('Successfully updated booking metadata');
        // Note: The API might return different structure, adjust accordingly
        return await getBookingById(bookingId);
      } else {
        log('Failed to update booking. Status: ${response.statusCode}');
        throw Exception('Failed to update booking');
      }
    } catch (e) {
      log('Error updating booking metadata: $e');
      rethrow;
    }
  }

  // Initiate payment
  Future<Map<String, dynamic>> initiatePayment(int bookingId) async {
    try {
      log('Initiating payment for car booking ID: $bookingId');

      final response = await _apiClient.post(
        '/carbookings/$bookingId/initiate-payment',
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
  Future<CarBooking> processPayment({
    required int bookingId,
    String? paymentMethod,
    String? paymentIntentId,
    String? stripeToken,
  }) async {
    try {
      log('Processing payment for car booking ID: $bookingId');

      final requestData = <String, dynamic>{};
      if (paymentMethod != null) requestData['paymentMethod'] = paymentMethod;
      if (paymentIntentId != null) {
        requestData['paymentIntentId'] = paymentIntentId;
      }
      if (stripeToken != null) requestData['stripeToken'] = stripeToken;

      final response = await _apiClient.post(
        '/carbookings/$bookingId/process-payment',
        data: requestData,
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final booking = CarBooking.fromJson(data);
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
      log('Cancelling car booking ID: $bookingId');

      final response = await _apiClient.post(
        '/carbookings/$bookingId/cancel',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        log('Car booking cancelled successfully');
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
      log('Error cancelling car booking: $e');

      // Handle specific cancellation error cases
      if (e.toString().contains('400')) {
        throw Exception('Booking cannot be cancelled');
      } else if (e.toString().contains('404')) {
        throw Exception('Booking not found');
      } else if (e.toString().contains('409')) {
        throw Exception(
          'Booking has already been cancelled or is too close to rental date',
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
    final today = DateTime(now.year, now.month, now.day);
    return date.isAfter(today) || date.isAtSameMomentAs(today);
  }
}
