import 'dart:convert';
import 'dart:developer';
import '../models/house_models.dart';
import '../utils/api_client.dart';

class HouseService {
  final ApiClient _apiClient = ApiClient();

  // Get houses with filtering and pagination
  Future<PaginatedHouses> getHouses({HouseFilterRequest? filter}) async {
    try {
      log('Fetching houses');

      final queryParams = filter?.toQueryParams() ?? {};

      final response = await _apiClient.get(
        '/houses',
        queryParams: queryParams,
        requiresAuth: false, // Public endpoint
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final houses = PaginatedHouses.fromJson(data);
        log('Successfully fetched ${houses.items.length} houses');
        return houses;
      } else {
        log('Failed to fetch houses. Status: ${response.statusCode}');
        throw Exception('Failed to fetch houses');
      }
    } catch (e) {
      log('Error fetching houses: $e');
      rethrow;
    }
  }

  // Get house by ID
  Future<House> getHouseById(int id) async {
    try {
      log('Fetching house with ID: $id');

      final response = await _apiClient.get('/houses/$id', requiresAuth: false);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final house = House.fromJson(data);
        log('Successfully fetched house: ${house.name}');
        return house;
      } else if (response.statusCode == 404) {
        throw Exception('House not found');
      } else {
        log('Failed to fetch house. Status: ${response.statusCode}');
        throw Exception('Failed to fetch house');
      }
    } catch (e) {
      log('Error fetching house: $e');
      rethrow;
    }
  }

  // Get house reviews
  Future<List<HouseReview>> getHouseReviews(
    int houseId, {
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    try {
      log('Fetching reviews for house ID: $houseId');

      final queryParams = {
        'pageIndex': pageIndex.toString(),
        'pageSize': pageSize.toString(),
      };

      final response = await _apiClient.get(
        '/houses/$houseId/reviews',
        queryParams: queryParams,
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final reviews =
            (data['items'] as List<dynamic>)
                .map(
                  (item) => HouseReview.fromJson(item as Map<String, dynamic>),
                )
                .toList();
        log('Successfully fetched ${reviews.length} reviews');
        return reviews;
      } else {
        log('Failed to fetch reviews. Status: ${response.statusCode}');
        throw Exception('Failed to fetch reviews');
      }
    } catch (e) {
      log('Error fetching reviews: $e');
      rethrow;
    }
  }

  // Add house review
  Future<HouseReview> addReview(AddHouseReviewRequest request) async {
    try {
      log('Adding review for house ID: ${request.houseId}');

      final response = await _apiClient.post(
        '/houses/reviews',
        data: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final review = HouseReview.fromJson(data);
        log('Successfully added review');
        return review;
      } else {
        log('Failed to add review. Status: ${response.statusCode}');
        throw Exception('Failed to add review');
      }
    } catch (e) {
      log('Error adding review: $e');
      rethrow;
    }
  }

  // Check house availability
  Future<HouseAvailabilityResponse> checkAvailability({
    required int houseId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int guestCount,
  }) async {
    try {
      log('Checking availability for house ID: $houseId');

      final request = CheckHouseAvailabilityRequest(
        houseId: houseId,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        guestCount: guestCount,
      );

      final response = await _apiClient.post(
        '/houses/check-availability',
        data: request.toJson(),
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final availability = HouseAvailabilityResponse.fromJson(data);
        log('Availability checked: ${availability.isAvailable}');
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

  // Create house booking
  Future<HouseBooking> createBooking({
    required int houseId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int guestCount,
    String? notes,
    String? discountCode,
  }) async {
    try {
      log('Creating house booking for house ID: $houseId');

      final request = CreateHouseBookingRequest(
        houseId: houseId,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        guestCount: guestCount,
        notes: notes,
        discountCode: discountCode,
      );

      final response = await _apiClient.post(
        '/house-bookings',
        data: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final booking = HouseBooking.fromJson(data);
        log('House booking created successfully: ${booking.id}');
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
      log('Error creating house booking: $e');

      // Handle specific error cases
      if (e.toString().contains('401')) {
        throw Exception('Please log in to book a house');
      } else if (e.toString().contains('400')) {
        throw Exception(
          'Invalid booking details. Please check your information.',
        );
      } else if (e.toString().contains('409')) {
        throw Exception('House is no longer available for the selected dates');
      }

      rethrow;
    }
  }

  // Get user house bookings
  Future<List<HouseBooking>> getUserBookings() async {
    try {
      log('Fetching user house bookings');

      final response = await _apiClient.get(
        '/house-bookings',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<HouseBooking> bookings = [];

        if (data['items'] != null) {
          bookings =
              (data['items'] as List<dynamic>)
                  .map(
                    (item) =>
                        HouseBooking.fromJson(item as Map<String, dynamic>),
                  )
                  .toList();
        } else if (data is List) {
          bookings =
              data
                  .map(
                    (item) =>
                        HouseBooking.fromJson(item as Map<String, dynamic>),
                  )
                  .toList();
        }

        log('Successfully fetched ${bookings.length} house bookings');
        return bookings;
      } else {
        log('Failed to fetch bookings. Status: ${response.statusCode}');
        throw Exception('Failed to fetch house bookings');
      }
    } catch (e) {
      log('Error fetching house bookings: $e');

      if (e.toString().contains('401')) {
        throw Exception('Please log in to view your bookings');
      }

      rethrow;
    }
  }

  // Get house booking by ID
  Future<HouseBooking> getBookingById(int bookingId) async {
    try {
      log('Fetching house booking with ID: $bookingId');

      final response = await _apiClient.get(
        '/house-bookings/$bookingId',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final booking = HouseBooking.fromJson(data);
        log('Successfully fetched house booking: ${booking.id}');
        return booking;
      } else if (response.statusCode == 404) {
        throw Exception('Booking not found');
      } else {
        log('Failed to fetch booking. Status: ${response.statusCode}');
        throw Exception('Failed to fetch booking');
      }
    } catch (e) {
      log('Error fetching house booking: $e');
      rethrow;
    }
  }

  // Cancel booking
  Future<void> cancelBooking(int bookingId) async {
    try {
      log('Cancelling house booking ID: $bookingId');

      final response = await _apiClient.post(
        '/house-bookings/$bookingId/cancel',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        log('House booking cancelled successfully');
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
      log('Error cancelling house booking: $e');

      // Handle specific cancellation error cases
      if (e.toString().contains('400')) {
        throw Exception('Booking cannot be cancelled');
      } else if (e.toString().contains('404')) {
        throw Exception('Booking not found');
      } else if (e.toString().contains('409')) {
        throw Exception(
          'Booking has already been cancelled or is too close to check-in date',
        );
      }

      rethrow;
    }
  }

  // Get popular property types
  Future<List<String>> getPropertyTypes() async {
    try {
      // In a real implementation, you would have an API endpoint for this
      // For now, we'll return a predefined list
      return [
        'House',
        'Apartment',
        'Villa',
        'Cottage',
        'Cabin',
        'Chalet',
        'Bungalow',
        'Farmhouse',
      ];
    } catch (e) {
      log('Error fetching property types: $e');
      rethrow;
    }
  }

  // Get popular destinations (cities/countries)
  Future<List<String>> getPopularDestinations() async {
    try {
      // In a real implementation, you would have an API endpoint for this
      // For now, we'll return a predefined list
      return [
        'Santorini, Greece',
        'Paris, France',
        'Bali, Indonesia',
        'New York, USA',
        'Rome, Italy',
        'Tokyo, Japan',
        'Barcelona, Spain',
        'London, UK',
      ];
    } catch (e) {
      log('Error fetching popular destinations: $e');
      rethrow;
    }
  }

  // Helper method to format date for API
  String formatDateForApi(DateTime date) {
    return date.toUtc().toIso8601String();
  }

  // Helper method to validate booking dates
  bool isValidBookingDates(DateTime checkIn, DateTime checkOut) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return checkIn.isAfter(tomorrow) && checkOut.isAfter(checkIn);
  }

  // Calculate stay duration
  int calculateNights(DateTime checkIn, DateTime checkOut) {
    return checkOut.difference(checkIn).inDays;
  }
}
