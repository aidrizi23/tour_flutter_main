import 'dart:convert';
import 'dart:developer';
import '../models/discount_models.dart';
import '../utils/api_client.dart';

class DiscountService {
  final ApiClient _apiClient = ApiClient();

  // Get all discounts with filtering and pagination
  Future<PaginatedDiscounts> getDiscounts({
    DiscountFilterRequest? filter,
  }) async {
    try {
      log('Fetching discounts');

      final queryParams = filter?.toQueryParams() ?? {};

      final response = await _apiClient.get(
        '/discounts',
        queryParams: queryParams,
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final discounts = PaginatedDiscounts.fromJson(data);
        log('Successfully fetched ${discounts.items.length} discounts');
        return discounts;
      } else {
        log('Failed to fetch discounts. Status: ${response.statusCode}');
        throw Exception('Failed to fetch discounts');
      }
    } catch (e) {
      log('Error fetching discounts: $e');
      rethrow;
    }
  }

  // Get discount by ID
  Future<Discount> getDiscountById(int discountId) async {
    try {
      log('Fetching discount with ID: $discountId');

      final response = await _apiClient.get(
        '/discounts/$discountId',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final discount = Discount.fromJson(data);
        log('Successfully fetched discount: ${discount.code}');
        return discount;
      } else if (response.statusCode == 404) {
        throw Exception('Discount not found');
      } else {
        log('Failed to fetch discount. Status: ${response.statusCode}');
        throw Exception('Failed to fetch discount');
      }
    } catch (e) {
      log('Error fetching discount: $e');
      rethrow;
    }
  }

  // Get discount by code
  Future<Discount> getDiscountByCode(String code) async {
    try {
      log('Fetching discount with code: $code');

      final response = await _apiClient.get(
        '/discounts/code/$code',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final discount = Discount.fromJson(data);
        log('Successfully fetched discount: ${discount.name}');
        return discount;
      } else if (response.statusCode == 404) {
        throw Exception('Discount code not found');
      } else {
        log('Failed to fetch discount. Status: ${response.statusCode}');
        throw Exception('Invalid discount code');
      }
    } catch (e) {
      log('Error fetching discount by code: $e');
      rethrow;
    }
  }

  // Create new discount (Admin only)
  Future<Discount> createDiscount(CreateDiscountRequest request) async {
    try {
      log('Creating new discount: ${request.code}');

      final response = await _apiClient.post(
        '/discounts',
        data: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        final discount = Discount.fromJson(data);
        log('Successfully created discount: ${discount.code}');
        return discount;
      } else {
        log('Failed to create discount. Status: ${response.statusCode}');

        // Parse error message if available
        try {
          final errorData = json.decode(response.body);
          String message = errorData['message'] ?? 'Failed to create discount';

          // Handle specific validation errors
          if (errorData['errors'] != null) {
            final errors = errorData['errors'] as Map<String, dynamic>;
            if (errors['Code'] != null) {
              throw Exception('Discount code already exists');
            }
          }

          throw Exception(message);
        } catch (e) {
          if (e.toString().contains('already exists')) rethrow;
          throw Exception('Failed to create discount');
        }
      }
    } catch (e) {
      log('Error creating discount: $e');

      // Handle specific error cases
      if (e.toString().contains('401')) {
        throw Exception('Unauthorized. Please log in as admin.');
      } else if (e.toString().contains('403')) {
        throw Exception('Access denied. Admin privileges required.');
      } else if (e.toString().contains('400')) {
        throw Exception('Invalid discount data. Please check your input.');
      }

      rethrow;
    }
  }

  // Update discount (Admin only)
  Future<Discount> updateDiscount(
    int discountId,
    UpdateDiscountRequest request,
  ) async {
    try {
      log('Updating discount with ID: $discountId');

      final response = await _apiClient.put(
        '/discounts/$discountId',
        data: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final discount = Discount.fromJson(data);
        log('Successfully updated discount: ${discount.code}');
        return discount;
      } else {
        log('Failed to update discount. Status: ${response.statusCode}');

        // Parse error message if available
        try {
          final errorData = json.decode(response.body);
          final message = errorData['message'] ?? 'Failed to update discount';
          throw Exception(message);
        } catch (e) {
          throw Exception('Failed to update discount');
        }
      }
    } catch (e) {
      log('Error updating discount: $e');

      // Handle specific error cases
      if (e.toString().contains('401')) {
        throw Exception('Unauthorized. Please log in as admin.');
      } else if (e.toString().contains('403')) {
        throw Exception('Access denied. Admin privileges required.');
      } else if (e.toString().contains('404')) {
        throw Exception('Discount not found');
      }

      rethrow;
    }
  }

  // Delete discount (Admin only)
  Future<void> deleteDiscount(int discountId) async {
    try {
      log('Deleting discount with ID: $discountId');

      final response = await _apiClient.delete(
        '/discounts/$discountId',
        requiresAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        log('Successfully deleted discount');
      } else {
        log('Failed to delete discount. Status: ${response.statusCode}');

        // Parse error message if available
        try {
          final errorData = json.decode(response.body);
          final message = errorData['message'] ?? 'Failed to delete discount';
          throw Exception(message);
        } catch (e) {
          throw Exception('Failed to delete discount');
        }
      }
    } catch (e) {
      log('Error deleting discount: $e');

      // Handle specific error cases
      if (e.toString().contains('401')) {
        throw Exception('Unauthorized. Please log in as admin.');
      } else if (e.toString().contains('403')) {
        throw Exception('Access denied. Admin privileges required.');
      } else if (e.toString().contains('404')) {
        throw Exception('Discount not found');
      } else if (e.toString().contains('409')) {
        throw Exception('Cannot delete discount. It may be in use.');
      }

      rethrow;
    }
  }

  // Toggle discount status (Admin only)
  Future<Discount> toggleDiscountStatus(int discountId) async {
    try {
      log('Toggling discount status for ID: $discountId');

      final response = await _apiClient.post(
        '/discounts/$discountId/toggle-status',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final discount = Discount.fromJson(data);
        log('Successfully toggled discount status: ${discount.isActive}');
        return discount;
      } else {
        log('Failed to toggle discount status. Status: ${response.statusCode}');
        throw Exception('Failed to toggle discount status');
      }
    } catch (e) {
      log('Error toggling discount status: $e');
      rethrow;
    }
  }

  // Validate discount code for a specific amount
  Future<Map<String, dynamic>> validateDiscount({
    required String code,
    required double amount,
    String? applicationType, // 'tour' or 'car'
  }) async {
    try {
      log('Validating discount code: $code for amount: $amount');

      final requestData = {
        'code': code,
        'amount': amount,
        if (applicationType != null) 'applicationType': applicationType,
      };

      final response = await _apiClient.post(
        '/discounts/validate',
        data: requestData,
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log('Successfully validated discount code');
        return {
          'isValid': data['isValid'] as bool,
          'discountAmount': (data['discountAmount'] as num?)?.toDouble() ?? 0.0,
          'finalAmount': (data['finalAmount'] as num?)?.toDouble() ?? amount,
          'message': data['message'] as String?,
        };
      } else {
        log('Failed to validate discount. Status: ${response.statusCode}');

        final data = json.decode(response.body);
        return {
          'isValid': false,
          'discountAmount': 0.0,
          'finalAmount': amount,
          'message': data['message'] ?? 'Invalid discount code',
        };
      }
    } catch (e) {
      log('Error validating discount: $e');
      return {
        'isValid': false,
        'discountAmount': 0.0,
        'finalAmount': amount,
        'message': 'Error validating discount code',
      };
    }
  }

  // Get discount statistics (Admin only)
  Future<Map<String, dynamic>> getDiscountStatistics() async {
    try {
      log('Fetching discount statistics');

      final response = await _apiClient.get(
        '/discounts/statistics',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log('Successfully fetched discount statistics');
        return data;
      } else {
        log('Failed to fetch statistics. Status: ${response.statusCode}');
        throw Exception('Failed to fetch discount statistics');
      }
    } catch (e) {
      log('Error fetching discount statistics: $e');
      rethrow;
    }
  }

  // Get available categories for discounts
  Future<List<String>> getDiscountCategories() async {
    try {
      log('Fetching discount categories');

      final response = await _apiClient.get(
        '/discounts/categories',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        final categories = data.map((e) => e as String).toList();
        log('Successfully fetched ${categories.length} categories');
        return categories;
      } else {
        log('Failed to fetch categories. Status: ${response.statusCode}');
        // Return default categories if API call fails
        return ['Tour', 'Car Rental', 'All'];
      }
    } catch (e) {
      log('Error fetching categories: $e');
      // Return default categories if error occurs
      return ['Tour', 'Car Rental', 'All'];
    }
  }

  // Helper method to format date for API
  String formatDateForApi(DateTime date) {
    return date.toUtc().toIso8601String();
  }

  // Helper method to validate discount data before submission
  bool validateDiscountData(CreateDiscountRequest request) {
    // Code validation
    if (request.code.isEmpty || request.code.length < 3) {
      throw Exception('Discount code must be at least 3 characters long');
    }

    // Name validation
    if (request.name.isEmpty) {
      throw Exception('Discount name is required');
    }

    // Value validation
    if (request.value <= 0) {
      throw Exception('Discount value must be greater than 0');
    }

    if (request.type == DiscountType.percentage && request.value > 100) {
      throw Exception('Percentage discount cannot be more than 100%');
    }

    // Date validation
    if (request.startDate.isAfter(request.endDate)) {
      throw Exception('Start date must be before end date');
    }

    // Usage limit validation
    if (request.usageLimit != null && request.usageLimit! <= 0) {
      throw Exception('Usage limit must be greater than 0');
    }

    // Minimum amount validation
    if (request.minimumAmount != null && request.minimumAmount! < 0) {
      throw Exception('Minimum amount cannot be negative');
    }

    return true;
  }
}
