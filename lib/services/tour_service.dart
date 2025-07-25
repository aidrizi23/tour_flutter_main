import 'dart:convert';
import 'dart:developer';
import '../models/tour_models.dart';
import '../models/create_tour_models.dart';
import '../utils/api_client.dart';

class TourService {
  final ApiClient _apiClient = ApiClient();

  // Get tours with filtering and pagination
  Future<PaginatedTours> getTours({TourFilterRequest? filter}) async {
    try {
      log('Fetching tours with filter: ${filter?.toQueryParams()}');

      final queryParams = filter?.toQueryParams() ?? {};

      final response = await _apiClient.get(
        '/tours',
        queryParams: queryParams,
        requiresAuth: false, // Public endpoint
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tours = PaginatedTours.fromJson(data);
        log('Successfully fetched ${tours.items.length} tours');
        return tours;
      } else {
        log('Failed to fetch tours. Status: ${response.statusCode}');
        throw Exception('Failed to fetch tours');
      }
    } catch (e) {
      log('Error fetching tours: $e');
      
      // If it's a connection error, return dummy data for development
      if (e.toString().contains('Connection refused') || 
          e.toString().contains('Network unreachable') ||
          e.toString().contains('SocketException')) {
        log('Connection failed, returning dummy tours data');
        return _createDummyPaginatedTours();
      }
      
      rethrow;
    }
  }

  // Get tour by ID
  Future<Tour> getTourById(int id) async {
    try {
      log('Fetching tour with ID: $id');

      final response = await _apiClient.get('/tours/$id', requiresAuth: false);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tour = Tour.fromJson(data);
        log('Successfully fetched tour: ${tour.name}');
        return tour;
      } else if (response.statusCode == 404) {
        throw Exception('Tour not found');
      } else {
        log('Failed to fetch tour. Status: ${response.statusCode}');
        throw Exception('Failed to fetch tour');
      }
    } catch (e) {
      log('Error fetching tour: $e');
      
      // If it's a connection error, return dummy data for development
      if (e.toString().contains('Connection refused') || 
          e.toString().contains('Network unreachable') ||
          e.toString().contains('SocketException')) {
        log('Connection failed, returning dummy tour data');
        return _createDummyTour(id);
      }
      
      rethrow;
    }
  }

  // Create new tour (Admin only)
  Future<Tour> createTour(CreateTourRequest request) async {
    try {
      log('Creating new tour: ${request.name}');

      final response = await _apiClient.post(
        '/tours',
        data: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        final tour = Tour.fromJson(data);
        log('Successfully created tour: ${tour.name}');
        return tour;
      } else {
        log('Failed to create tour. Status: ${response.statusCode}');

        // Parse error message if available
        try {
          final errorData = json.decode(response.body);
          final message = errorData['message'] ?? 'Failed to create tour';
          throw Exception(message);
        } catch (e) {
          throw Exception('Failed to create tour');
        }
      }
    } catch (e) {
      log('Error creating tour: $e');

      // Handle specific error cases
      if (e.toString().contains('401')) {
        throw Exception('Unauthorized. Please log in as admin.');
      } else if (e.toString().contains('403')) {
        throw Exception('Access denied. Admin privileges required.');
      } else if (e.toString().contains('400')) {
        throw Exception('Invalid tour data. Please check your input.');
      }

      rethrow;
    }
  }

  // Advanced tour search
  Future<PaginatedTours> searchTours({
    required Map<String, dynamic> searchRequest,
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    try {
      log('Performing advanced tour search');

      final queryParams = {
        'pageIndex': pageIndex.toString(),
        'pageSize': pageSize.toString(),
      };

      final response = await _apiClient.post(
        '/tours/search',
        data: searchRequest,
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tours = PaginatedTours.fromJson(data);
        log('Successfully searched tours: ${tours.items.length} results');
        return tours;
      } else {
        log('Failed to search tours. Status: ${response.statusCode}');
        throw Exception('Failed to search tours');
      }
    } catch (e) {
      log('Error searching tours: $e');
      rethrow;
    }
  }

  // Get tour reviews
  Future<List<TourReview>> getTourReviews(
    int tourId, {
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    try {
      log('Fetching reviews for tour ID: $tourId');

      final queryParams = {
        'pageIndex': pageIndex.toString(),
        'pageSize': pageSize.toString(),
      };

      final response = await _apiClient.get(
        '/tours/$tourId/reviews',
        queryParams: queryParams,
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>;
        final reviews =
            items
                .map(
                  (item) => TourReview.fromJson(item as Map<String, dynamic>),
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
      
      // If it's a connection error, return dummy data for development
      if (e.toString().contains('Connection refused') || 
          e.toString().contains('Network unreachable') ||
          e.toString().contains('SocketException')) {
        log('Connection failed, returning dummy reviews data');
        return _createDummyReviews(tourId);
      }
      
      rethrow;
    }
  }

  // Add review (requires auth)
  Future<TourReview> addReview(AddReviewRequest request) async {
    try {
      log('Adding review for tour ID: ${request.tourId}');

      final response = await _apiClient.post(
        '/tours/reviews',
        data: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final review = TourReview.fromJson(data);
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

  // Apply discount to tour
  Future<Tour> applyDiscountToTour(int tourId, String discountCode) async {
    try {
      log('Applying discount code "$discountCode" to tour ID: $tourId');

      final response = await _apiClient.post(
        '/tours/$tourId/apply-discount',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tour = Tour.fromJson(data);
        log('Successfully applied discount');
        return tour;
      } else {
        log('Failed to apply discount. Status: ${response.statusCode}');
        throw Exception('Failed to apply discount');
      }
    } catch (e) {
      log('Error applying discount: $e');
      rethrow;
    }
  }

  // Check tour availability
  Future<Map<String, dynamic>> checkTourAvailability({
    required int tourId,
    required DateTime startDate,
    required int groupSize,
  }) async {
    try {
      log('Checking availability for tour ID: $tourId');

      final requestData = {
        'tourId': tourId,
        'startDate': startDate.toUtc().toIso8601String(),
        'groupSize': groupSize,
      };

      final response = await _apiClient.post(
        '/tours/check-availability',
        data: requestData,
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log('Successfully checked availability: ${data['isAvailable']}');
        return data;
      } else {
        log('Failed to check availability. Status: ${response.statusCode}');
        throw Exception('Failed to check availability');
      }
    } catch (e) {
      log('Error checking availability: $e');
      rethrow;
    }
  }

  // Get all categories (helper method)
  Future<List<String>> getCategories() async {
    // Since the API doesn't have a dedicated categories endpoint,
    // we'll fetch all tours and extract unique categories
    try {
      final tours = await getTours(filter: TourFilterRequest(pageSize: 100));
      final categories =
          tours.items.map((tour) => tour.category).toSet().toList();
      categories.sort();
      return categories;
    } catch (e) {
      log('Error fetching categories: $e');
      return [];
    }
  }

  // Get all locations (helper method)
  Future<List<String>> getLocations() async {
    // Since the API doesn't have a dedicated locations endpoint,
    // we'll fetch all tours and extract unique locations
    try {
      final tours = await getTours(filter: TourFilterRequest(pageSize: 100));
      final locations =
          tours.items.map((tour) => tour.location).toSet().toList();
      locations.sort();
      return locations;
    } catch (e) {
      log('Error fetching locations: $e');
      return [];
    }
  }

  // Dummy data methods for offline development
  PaginatedTours _createDummyPaginatedTours() {
    final dummyTours = [
      _createDummyTour(1),
      _createDummyTour(2),
      _createDummyTour(3),
    ];
    
    return PaginatedTours(
      items: dummyTours,
      pageIndex: 1,
      totalPages: 1,
      totalCount: dummyTours.length,
      hasPreviousPage: false,
      hasNextPage: false,
    );
  }

  Tour _createDummyTour(int id) {
    return Tour(
      id: id,
      name: 'Historic Walking Tour $id',
      description: 'Explore the historic city center and learn about its fascinating past. This comprehensive walking tour covers major landmarks, hidden gems, and local stories.',
      location: 'City Center',
      category: 'Cultural',
      price: 45.0 + (id * 10),
      discountedPrice: null,
      durationInDays: 1,
      difficultyLevel: 'Easy',
      activityType: 'Outdoor',
      maxGroupSize: 15,
      mainImageUrl: 'https://images.unsplash.com/photo-1539650116574-75c0c6d73c6e?w=800&h=600&fit=crop',
      isActive: true,
      averageRating: 4.5 + (id * 0.1),
      reviewCount: 20 + (id * 5),
      createdAt: DateTime.now().subtract(Duration(days: id * 10)),
      images: [
        TourImage(
          id: id * 10 + 1,
          imageUrl: 'https://images.unsplash.com/photo-1539650116574-75c0c6d73c6e?w=800&h=600&fit=crop',
          caption: 'Historic square',
          displayOrder: 1,
        ),
        TourImage(
          id: id * 10 + 2,
          imageUrl: 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=800&h=600&fit=crop',
          caption: 'Old architecture',
          displayOrder: 2,
        ),
      ],
      features: [
        TourFeature(
          id: id * 10 + 1,
          name: 'Professional Guide',
          description: 'Experienced local guide',
        ),
        TourFeature(
          id: id * 10 + 2,
          name: 'Small Group',
          description: 'Maximum 15 people',
        ),
      ],
      itineraryItems: [
        ItineraryItem(
          id: id * 10 + 1,
          dayNumber: 1,
          title: 'Historic Center Exploration',
          description: 'Start at the main square and explore historic buildings',
          startTime: '09:00 AM',
          endTime: '12:00 PM',
          activityType: 'Walking',
        ),
      ],
    );
  }

  List<TourReview> _createDummyReviews(int tourId) {
    return [
      TourReview(
        id: tourId * 100 + 1,
        userName: 'John Smith',
        rating: 5,
        comment: 'Amazing tour! The guide was very knowledgeable and the pace was perfect.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      TourReview(
        id: tourId * 100 + 2,
        userName: 'Sarah Johnson',
        rating: 4,
        comment: 'Great experience, learned a lot about the city history.',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      TourReview(
        id: tourId * 100 + 3,
        userName: 'Mike Davis',
        rating: 5,
        comment: 'Highly recommended! Perfect for history enthusiasts.',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
  }

  // Constants for filtering options
  static const List<String> difficultyLevels = [
    'Easy',
    'Moderate',
    'Challenging',
  ];
  static const List<String> activityTypes = ['Indoor', 'Outdoor', 'Mixed'];
  static const List<String> sortOptions = [
    'name',
    'price',
    'location',
    'duration',
    'rating',
    'created',
  ];
}
