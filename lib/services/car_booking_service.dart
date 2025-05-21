import 'dart:convert';
import 'dart:developer';

import '../models/car_booking_models.dart';
import '../models/car_availability_response.dart';
import '../utils/api_client.dart';

class CarBookingService {
  final ApiClient _apiClient = ApiClient();

  // Check car availability for booking - FIXED to use proper endpoint with authentication
  Future<CarAvailabilityResponse> checkAvailability({
    required int carId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      log('Checking car availability for booking. Car ID: $carId');

      // Use the booking controller's endpoint with query parameters
      final queryParams = {
        'carId': carId.toString(),
        'startDate': startDate.toUtc().toIso8601String(),
        'endDate': endDate.toUtc().toIso8601String(),
      };

      log('Check availability query params: $queryParams');

      // Key fix: Make sure we're requiring auth for this endpoint
      final response = await _apiClient.get(
        '/carbookings/check-availability',
        queryParams: queryParams,
        requiresAuth: true, // This was likely the issue - needs to be true
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final availability = CarAvailabilityResponse.fromJson(data);
        log('Availability checked successfully: ${availability.isAvailable}');
        return availability;
      } else {
        log(
          'Failed to check availability. Status: ${response.statusCode}, Body: ${response.body}',
        );

        // Try to extract error message if available
        try {
          final errorData = json.decode(response.body);
          final message =
              errorData['message'] ?? 'Failed to check availability';
          throw Exception(message);
        } catch (e) {
          throw Exception(
            'Failed to check availability: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      log('Error checking availability: $e');

      // If we get a 401 error, provide a clearer message
      if (e.toString().contains('401')) {
        throw Exception(
          'Authentication required. Please log in to check car availability.',
        );
      }

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
        rentalStartDate: rentalStartDate.toUtc(), // Convert to UTC
        rentalEndDate: rentalEndDate.toUtc(), // Convert to UTC
        notes: notes,
      );

      final response = await _apiClient.post(
        '/carbookings',
        data: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        final booking = CarBooking.fromJson(data);
        log('Car booking created successfully: ${booking.id}');
        return booking;
      } else {
        log(
          'Failed to create booking. Status: ${response.statusCode}, Body: ${response.body}',
        );

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
  // Quick book car with immediate payment intent - improved with better response handling
  Future<CarBooking> quickBook({
    required int carId,
    required DateTime rentalStartDate,
    required DateTime rentalEndDate,
    String? notes,
    bool initiatePaymentImmediately = true,
  }) async {
    try {
      log('Creating quick car booking for car ID: $carId');

      final request = QuickBookingDto(
        carId: carId,
        rentalStartDate: rentalStartDate.toUtc(), // Convert to UTC
        rentalEndDate: rentalEndDate.toUtc(), // Convert to UTC
        notes: notes,
        initiatePaymentImmediately: initiatePaymentImmediately,
      );

      final response = await _apiClient.post(
        '/carbookings/quick-book',
        data: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        log('Quick car booking created successfully');

        // Create booking object from response
        final booking = CarBooking.fromJson(data);
        log('Booking ID: ${booking.id}');

        // Check if payment info is included in the response
        if (booking.paymentInfo == null) {
          log(
            'Payment info not included in quick booking response, attempting to fetch separately',
          );

          // If payment info is missing but we have a booking ID, try to fetch payment info directly
          if (booking.id > 0) {
            try {
              // Try to fetch payment info
              final paymentInfo = await getBookingPaymentInfo(booking.id);

              // Create a new booking object with the payment info
              return CarBooking(
                id: booking.id,
                carId: booking.carId,
                carName: booking.carName,
                bookingDate: booking.bookingDate,
                rentalStartDate: booking.rentalStartDate,
                rentalEndDate: booking.rentalEndDate,
                totalAmount: booking.totalAmount,
                status: booking.status,
                notes: booking.notes,
                paymentMethod: booking.paymentMethod,
                paymentStatus: booking.paymentStatus,
                paymentDate: booking.paymentDate,
                transactionId: booking.transactionId,
                paymentInfo: paymentInfo,
              );
            } catch (e) {
              log('Failed to fetch payment info separately: $e');
              // Continue with the original booking object without payment info
            }
          }
        }

        return booking;
      } else {
        log(
          'Failed to create quick booking. Status: ${response.statusCode}, Body: ${response.body}',
        );

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
        log(
          'Failed to fetch bookings. Status: ${response.statusCode}, Body: ${response.body}',
        );
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
        log(
          'Failed to fetch booking. Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception('Failed to fetch booking');
      }
    } catch (e) {
      log('Error fetching car booking: $e');
      rethrow;
    }
  }

  // Get booking payment info
  // Get booking payment info - improved with better error handling and retry logic
  Future<CarPaymentInfo> getBookingPaymentInfo(int bookingId) async {
    try {
      log('Fetching payment info for car booking ID: $bookingId');

      // Try up to 3 times with a short delay between attempts
      // This helps with race conditions where the payment info might not be ready yet
      Exception? lastException;
      for (int attempt = 0; attempt < 3; attempt++) {
        try {
          final response = await _apiClient.get(
            '/carbookings/$bookingId/payment-info',
            requiresAuth: true,
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final paymentInfo = CarPaymentInfo.fromJson(data);
            log('Successfully fetched payment info on attempt ${attempt + 1}');

            // Ensure critical fields are available
            if (paymentInfo.carId > 0 && paymentInfo.totalAmount > 0) {
              return paymentInfo;
            } else {
              log(
                'Warning: Payment info missing critical fields, retry attempt ${attempt + 1}',
              );
              throw Exception('Incomplete payment information received');
            }
          } else if (response.statusCode == 404) {
            log('Payment info not found, retry attempt ${attempt + 1}');
            throw Exception('Payment information not found');
          } else {
            log(
              'Failed to fetch payment info. Status: ${response.statusCode}, Body: ${response.body}',
            );
            throw Exception('Failed to fetch payment information');
          }
        } catch (e) {
          lastException = e is Exception ? e : Exception(e.toString());
          log('Attempt ${attempt + 1} to fetch payment info failed: $e');

          if (attempt < 2) {
            // Wait before retrying (increase wait time for each attempt)
            await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
          }
        }
      }

      // If we get here, all attempts failed
      throw lastException ??
          Exception(
            'Failed to fetch payment information after multiple attempts',
          );
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
        rentalStartDate: rentalStartDate?.toUtc(), // Convert to UTC if provided
        rentalEndDate: rentalEndDate?.toUtc(), // Convert to UTC if provided
        notes: notes,
      );

      final response = await _apiClient.put(
        '/carbookings/$bookingId/metadata',
        data: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        // Return updated booking
        return await getBookingById(bookingId);
      } else {
        log(
          'Failed to update booking. Status: ${response.statusCode}, Body: ${response.body}',
        );
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
        log(
          'Failed to initiate payment. Status: ${response.statusCode}, Body: ${response.body}',
        );
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
        log(
          'Failed to process payment. Status: ${response.statusCode}, Body: ${response.body}',
        );

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
        log(
          'Failed to cancel booking. Status: ${response.statusCode}, Body: ${response.body}',
        );

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
}
