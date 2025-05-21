import 'dart:convert';
import 'dart:developer';

import '../models/car_models.dart';
import '../utils/api_client.dart';

class CarService {
  final ApiClient _apiClient = ApiClient();

  // Static lists for filters
  static const List<String> categories = [
    'Economy',
    'Compact',
    'SUV',
    'Luxury',
    'Sports',
    'Sedan',
    'Hatchback',
    'Convertible',
  ];

  static const List<String> transmissionTypes = ['Automatic', 'Manual', 'CVT'];

  static const List<String> fuelTypes = [
    'Petrol',
    'Diesel',
    'Electric',
    'Hybrid',
    'Gas',
  ];

  static const List<String> sortOptions = [
    'make',
    'model',
    'year',
    'price',
    'location',
    'category',
    'seats',
    'created',
    'rating',
  ];

  // Create new car (Admin only)
  Future<Car> createCar(CreateCarRequest request) async {
    try {
      log('Creating new car: ${request.make} ${request.model}');

      final response = await _apiClient.post(
        '/cars',
        data: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        final car = Car.fromJson(data);
        log('Successfully created car: ${car.displayName}');
        return car;
      } else {
        log('Failed to create car. Status: ${response.statusCode}');

        // Parse error message if available
        try {
          final errorData = json.decode(response.body);
          final message = errorData['message'] ?? 'Failed to create car';
          throw Exception(message);
        } catch (e) {
          throw Exception('Failed to create car');
        }
      }
    } catch (e) {
      log('Error creating car: $e');

      // Handle specific error cases
      if (e.toString().contains('401')) {
        throw Exception('Unauthorized. Please log in as admin.');
      } else if (e.toString().contains('403')) {
        throw Exception('Access denied. Admin privileges required.');
      } else if (e.toString().contains('400')) {
        throw Exception('Invalid car data. Please check your input.');
      }

      rethrow;
    }
  }

  // Get cars with filtering and pagination
  Future<PaginatedCars> getCars({CarFilterRequest? filter}) async {
    try {
      log('Fetching cars');

      Map<String, String> queryParams = {};
      if (filter != null) {
        queryParams = filter.toQueryParams();
      }

      final response = await _apiClient.get(
        '/cars',
        queryParams: queryParams,
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cars = PaginatedCars.fromJson(data);
        log('Successfully fetched ${cars.items.length} cars');
        return cars;
      } else {
        log('Failed to fetch cars. Status: ${response.statusCode}');
        throw Exception('Failed to fetch cars');
      }
    } catch (e) {
      log('Error fetching cars: $e');
      rethrow;
    }
  }

  // Advanced car search
  Future<PaginatedCars> searchCars({
    required CarFilterRequest filter,
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    try {
      log('Performing advanced car search');

      final queryParams = {
        'pageIndex': pageIndex.toString(),
        'pageSize': pageSize.toString(),
      };

      final response = await _apiClient.post(
        '/cars/search',
        data: filter.toJson(),
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cars = PaginatedCars.fromJson(data);
        log('Successfully searched cars: ${cars.items.length} found');
        return cars;
      } else {
        log('Failed to search cars. Status: ${response.statusCode}');
        throw Exception('Failed to search cars');
      }
    } catch (e) {
      log('Error searching cars: $e');
      rethrow;
    }
  }

  // Get car by ID
  Future<Car> getCarById(int carId) async {
    try {
      log('Fetching car with ID: $carId');

      final response = await _apiClient.get(
        '/cars/$carId',
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final car = Car.fromJson(data);
        log('Successfully fetched car: ${car.displayName}');
        return car;
      } else if (response.statusCode == 404) {
        throw Exception('Car not found');
      } else {
        log('Failed to fetch car. Status: ${response.statusCode}');
        throw Exception('Failed to fetch car');
      }
    } catch (e) {
      log('Error fetching car: $e');
      rethrow;
    }
  }

  // Get car reviews
  Future<List<CarReview>> getCarReviews(
    int carId, {
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    try {
      log('Fetching reviews for car ID: $carId');

      final queryParams = {
        'pageIndex': pageIndex.toString(),
        'pageSize': pageSize.toString(),
      };

      final response = await _apiClient.get(
        '/cars/$carId/reviews',
        queryParams: queryParams,
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final reviews =
            (data['items'] as List<dynamic>)
                .map((item) => CarReview.fromJson(item as Map<String, dynamic>))
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

  // Add car review
  Future<CarReview> addReview(AddCarReviewRequest request) async {
    try {
      log('Adding review for car ID: ${request.carId}');

      final response = await _apiClient.post(
        '/cars/reviews',
        data: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final review = CarReview.fromJson(data);
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

  // Check car availability
  Future<CarAvailabilityResponse> checkAvailability({
    required int carId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      log('Checking availability for car ID: $carId');

      final request = CarAvailabilityRequest(
        carId: carId,
        startDate: startDate,
        endDate: endDate,
      );

      final response = await _apiClient.post(
        '/cars/check-availability',
        data: request.toJson(),
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final availability = CarAvailabilityResponse.fromJson(data);
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

  // Get available makes
  Future<List<String>> getMakes() async {
    try {
      log('Fetching car makes');

      final response = await _apiClient.getCars();
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cars = PaginatedCars.fromJson(data);
        final makes = cars.items.map((car) => car.make).toSet().toList();
        makes.sort();
        log('Successfully fetched ${makes.length} makes');
        return makes;
      } else {
        log('Failed to fetch makes. Status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error fetching makes: $e');
      return [];
    }
  }

  // Get available locations
  Future<List<String>> getLocations() async {
    try {
      log('Fetching car locations');

      final response = await _apiClient.getCars();
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cars = PaginatedCars.fromJson(data);
        final locations =
            cars.items.map((car) => car.location).toSet().toList();
        locations.sort();
        log('Successfully fetched ${locations.length} locations');
        return locations;
      } else {
        log('Failed to fetch locations. Status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error fetching locations: $e');
      return [];
    }
  }

  // Helper method to format date for API
  String formatDateForApi(DateTime date) {
    return date.toUtc().toIso8601String();
  }

  // Helper method to validate rental dates
  bool isValidRentalDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.isAfter(today) || date.isAtSameMomentAs(today);
  }

  // Helper method to calculate rental duration
  int calculateRentalDays(DateTime startDate, DateTime endDate) {
    return endDate.difference(startDate).inDays;
  }
}

// Create Car Request Model
class CreateCarRequest {
  final String make;
  final String model;
  final int year;
  final String description;
  final double dailyRate;
  final String category;
  final String transmission;
  final String fuelType;
  final int seats;
  final String location;
  final String? mainImageUrl;
  final List<CreateCarFeature> features;
  final List<CreateCarImage> images;

  CreateCarRequest({
    required this.make,
    required this.model,
    required this.year,
    required this.description,
    required this.dailyRate,
    required this.category,
    required this.transmission,
    required this.fuelType,
    required this.seats,
    required this.location,
    this.mainImageUrl,
    this.features = const [],
    this.images = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'description': description,
      'dailyRate': dailyRate,
      'category': category,
      'transmission': transmission,
      'fuelType': fuelType,
      'seats': seats,
      'location': location,
      'mainImageUrl': mainImageUrl,
      'features': features.map((e) => e.toJson()).toList(),
      'images': images.map((e) => e.toJson()).toList(),
    };
  }
}

class CreateCarFeature {
  final String name;
  final String? description;

  CreateCarFeature({required this.name, this.description});

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }
}

class CreateCarImage {
  final String imageUrl;
  final String? caption;
  final int displayOrder;

  CreateCarImage({
    required this.imageUrl,
    this.caption,
    required this.displayOrder,
  });

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'caption': caption,
      'displayOrder': displayOrder,
    };
  }
}
