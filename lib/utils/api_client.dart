import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'http://192.168.0.7:5076/api';
  static const Duration defaultTimeoutDuration = Duration(seconds: 30);

  // Headers for all requests
  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Add authorization header
  Future<Map<String, String>> _getHeaders({bool requiresAuth = false}) async {
    Map<String, String> headers = Map.from(_defaultHeaders);

    if (requiresAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requiresAuth = false,
    int timeoutSeconds = 30,
  }) async {
    try {
      // Build URL with query parameters
      Uri uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final headers = await _getHeaders(requiresAuth: requiresAuth);

      log('GET Request: ${uri.toString()}');
      log('Headers: ${headers.keys.join(', ')}');

      final response = await http
          .get(uri, headers: headers)
          .timeout(Duration(seconds: timeoutSeconds));

      log('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');

      return response;
    } catch (e) {
      log('GET Request Error: $e');
      rethrow;
    }
  }

  // POST request
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? data,
    bool requiresAuth = false,
    int timeoutSeconds = 30,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final body = data != null ? json.encode(data) : null;

      log('POST Request: ${uri.toString()}');
      log('Headers: ${headers.keys.join(', ')}');
      log('Body: $body');

      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(Duration(seconds: timeoutSeconds));

      log('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');

      return response;
    } catch (e) {
      log('POST Request Error: $e');
      rethrow;
    }
  }

  // PUT request
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? data,
    bool requiresAuth = false,
    int timeoutSeconds = 30,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final body = data != null ? json.encode(data) : null;

      log('PUT Request: ${uri.toString()}');
      log('Headers: ${headers.keys.join(', ')}');
      log('Body: $body');

      final response = await http
          .put(uri, headers: headers, body: body)
          .timeout(Duration(seconds: timeoutSeconds));

      log('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');

      return response;
    } catch (e) {
      log('PUT Request Error: $e');
      rethrow;
    }
  }

  // DELETE request
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requiresAuth = false,
    int timeoutSeconds = 30,
  }) async {
    try {
      // Build URL with query parameters
      Uri uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final headers = await _getHeaders(requiresAuth: requiresAuth);

      log('DELETE Request: ${uri.toString()}');
      log('Headers: ${headers.keys.join(', ')}');

      final response = await http
          .delete(uri, headers: headers)
          .timeout(Duration(seconds: timeoutSeconds));

      log('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');

      return response;
    } catch (e) {
      log('DELETE Request Error: $e');
      rethrow;
    }
  }

  // PATCH request
  Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? data,
    bool requiresAuth = false,
    int timeoutSeconds = 30,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final body = data != null ? json.encode(data) : null;

      log('PATCH Request: ${uri.toString()}');
      log('Headers: ${headers.keys.join(', ')}');
      log('Body: $body');

      final response = await http
          .patch(uri, headers: headers, body: body)
          .timeout(Duration(seconds: timeoutSeconds));

      log('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');

      return response;
    } catch (e) {
      log('PATCH Request Error: $e');
      rethrow;
    }
  }

  // Car-specific convenience methods

  // Get cars with optional filtering and pagination
  Future<http.Response> getCars({
    Map<String, String>? queryParams,
    bool requiresAuth = false,
  }) async {
    return await get(
      'cars',
      queryParams: queryParams,
      requiresAuth: requiresAuth,
    );
  }

  // Advanced car search
  Future<http.Response> searchCars({
    required Map<String, dynamic> searchCriteria,
    Map<String, String>? queryParams,
    bool requiresAuth = false,
  }) async {
    return await post(
      'cars/search${queryParams != null ? '?${Uri(queryParameters: queryParams).query}' : ''}',
      data: searchCriteria,
      requiresAuth: requiresAuth,
    );
  }

  // Get specific car by ID
  Future<http.Response> getCarById(
    int carId, {
    bool requiresAuth = false,
  }) async {
    return await get('cars/$carId', requiresAuth: requiresAuth);
  }

  // Check car availability
  Future<http.Response> checkCarAvailability({
    required Map<String, dynamic> availabilityData,
    bool requiresAuth = false,
  }) async {
    return await post(
      'cars/check-availability',
      data: availabilityData,
      requiresAuth: requiresAuth,
    );
  }

  // Get car reviews
  Future<http.Response> getCarReviews(
    int carId, {
    Map<String, String>? queryParams,
    bool requiresAuth = false,
  }) async {
    return await get(
      'cars/$carId/reviews',
      queryParams: queryParams,
      requiresAuth: requiresAuth,
    );
  }

  // Add car review
  Future<http.Response> addCarReview({
    required Map<String, dynamic> reviewData,
    bool requiresAuth = true,
  }) async {
    return await post(
      'cars/reviews',
      data: reviewData,
      requiresAuth: requiresAuth,
    );
  }

  // Car booking methods

  // Get user car bookings
  Future<http.Response> getCarBookings({bool requiresAuth = true}) async {
    return await get('carbookings', requiresAuth: requiresAuth);
  }

  // Get specific car booking
  Future<http.Response> getCarBookingById(
    int bookingId, {
    bool requiresAuth = true,
  }) async {
    return await get('carbookings/$bookingId', requiresAuth: requiresAuth);
  }

  // Create car booking
  Future<http.Response> createCarBooking({
    required Map<String, dynamic> bookingData,
    bool requiresAuth = true,
  }) async {
    return await post(
      'carbookings',
      data: bookingData,
      requiresAuth: requiresAuth,
    );
  }

  // Quick book car with immediate payment
  Future<http.Response> quickBookCar({
    required Map<String, dynamic> bookingData,
    bool requiresAuth = true,
  }) async {
    return await post(
      'carbookings/quick-book',
      data: bookingData,
      requiresAuth: requiresAuth,
    );
  }

  // Get booking payment info
  Future<http.Response> getCarBookingPaymentInfo(
    int bookingId, {
    bool requiresAuth = true,
  }) async {
    return await get(
      'carbookings/$bookingId/payment-info',
      requiresAuth: requiresAuth,
    );
  }

  // Update booking metadata
  Future<http.Response> updateCarBookingMetadata(
    int bookingId, {
    required Map<String, dynamic> updateData,
    bool requiresAuth = true,
  }) async {
    return await put(
      'carbookings/$bookingId/metadata',
      data: updateData,
      requiresAuth: requiresAuth,
    );
  }

  // Initiate car booking payment
  Future<http.Response> initiateCarBookingPayment(
    int bookingId, {
    bool requiresAuth = true,
  }) async {
    return await post(
      'carbookings/$bookingId/initiate-payment',
      requiresAuth: requiresAuth,
    );
  }

  // Process car booking payment
  Future<http.Response> processCarBookingPayment(
    int bookingId, {
    required Map<String, dynamic> paymentData,
    bool requiresAuth = true,
  }) async {
    return await post(
      'carbookings/$bookingId/process-payment',
      data: paymentData,
      requiresAuth: requiresAuth,
    );
  }

  // Cancel car booking
  Future<http.Response> cancelCarBooking(
    int bookingId, {
    bool requiresAuth = true,
  }) async {
    return await post(
      'carbookings/$bookingId/cancel',
      requiresAuth: requiresAuth,
    );
  }

  // Handle API errors
  Exception _handleError(http.Response response) {
    String message;

    try {
      final body = json.decode(response.body);
      message = body['message'] ?? body['title'] ?? 'An error occurred';
    } catch (e) {
      message = 'Failed to parse error response';
    }

    switch (response.statusCode) {
      case 400:
        return Exception('Bad Request: $message');
      case 401:
        return Exception('Unauthorized: Please log in again');
      case 403:
        return Exception('Forbidden: You don\'t have permission');
      case 404:
        return Exception('Not Found: $message');
      case 422:
        return Exception('Validation Error: $message');
      case 500:
        return Exception('Server Error: Please try again later');
      default:
        return Exception('Error ${response.statusCode}: $message');
    }
  }

  // Check if response is successful
  bool isSuccess(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  // Parse response body
  Map<String, dynamic> parseResponse(http.Response response) {
    if (!isSuccess(response)) {
      throw _handleError(response);
    }

    try {
      final responseBody = response.body;
      if (responseBody.isEmpty) {
        return {};
      }
      return json.decode(responseBody) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to parse response: $e');
    }
  }

  // Generic request method with retry logic
  Future<http.Response> request(
    String method,
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? queryParams,
    bool requiresAuth = false,
    int maxRetries = 3,
    int timeoutSeconds = 30,
  }) async {
    Exception? lastException;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        http.Response response;

        switch (method.toUpperCase()) {
          case 'GET':
            response = await get(
              endpoint,
              queryParams: queryParams,
              requiresAuth: requiresAuth,
              timeoutSeconds: timeoutSeconds,
            );
            break;
          case 'POST':
            response = await post(
              endpoint,
              data: data,
              requiresAuth: requiresAuth,
              timeoutSeconds: timeoutSeconds,
            );
            break;
          case 'PUT':
            response = await put(
              endpoint,
              data: data,
              requiresAuth: requiresAuth,
              timeoutSeconds: timeoutSeconds,
            );
            break;
          case 'DELETE':
            response = await delete(
              endpoint,
              queryParams: queryParams,
              requiresAuth: requiresAuth,
              timeoutSeconds: timeoutSeconds,
            );
            break;
          case 'PATCH':
            response = await patch(
              endpoint,
              data: data,
              requiresAuth: requiresAuth,
              timeoutSeconds: timeoutSeconds,
            );
            break;
          default:
            throw Exception('Unsupported HTTP method: $method');
        }

        return response;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        log('Request attempt ${attempt + 1} failed: $e');

        if (attempt < maxRetries - 1) {
          // Wait before retrying, with exponential backoff
          await Future.delayed(Duration(seconds: (attempt + 1) * 2));
        }
      }
    }

    throw lastException!;
  }
}
