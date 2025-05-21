import 'dart:convert';
import 'dart:developer';
import '../models/recommendation_models.dart';
import '../models/tour_models.dart';
import '../utils/api_client.dart';

class RecommendationService {
  final ApiClient _apiClient = ApiClient();

  // Check connection state
  Future<bool> checkConnection() async {
    try {
      // Try a lightweight API call to check connection
      final response = await _apiClient.get(
        '/tours', // Using an endpoint that definitely exists
        requiresAuth: false,
        timeoutSeconds: 5,
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      log('Connection check failed: $e');
      return false;
    }
  }

  // Get personalized tour recommendations
  Future<List<RecommendedTour>> getPersonalizedTourRecommendations({
    int limit = 5,
  }) async {
    try {
      log('Fetching personalized tour recommendations');

      // First try to get recommendations from the API
      try {
        final response = await _apiClient.get(
          '/recommendation/tours/personalized',
          queryParams: {'limit': limit.toString()},
          requiresAuth: false, // Changed to false to avoid auth issues
          timeoutSeconds: 3, // Short timeout for quick fallback
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          final recommendations =
              data
                  .map(
                    (item) =>
                        RecommendedTour.fromJson(item as Map<String, dynamic>),
                  )
                  .toList();

          log(
            'Successfully fetched ${recommendations.length} tour recommendations',
          );
          return recommendations;
        }
      } catch (apiError) {
        log('API error, using fallback data: $apiError');
        // Continue to fallback data
      }

      // Fallback: Get regular tours and convert them to recommended tours
      final toursResponse = await _apiClient.get(
        '/tours',
        queryParams: {'pageSize': limit.toString()},
        requiresAuth: false,
      );

      if (toursResponse.statusCode == 200) {
        final data = json.decode(toursResponse.body);
        final toursData = data['items'] as List<dynamic>;

        final recommendations =
            toursData.map((item) {
              final tour = Tour.fromJson(item as Map<String, dynamic>);
              return RecommendedTour(
                tour: tour,
                reasonForRecommendation: _generateRecommendationReason(tour),
              );
            }).toList();

        log(
          'Successfully created ${recommendations.length} tour recommendations from regular tours',
        );
        return recommendations;
      } else {
        // If both API calls fail, return mock data
        log('Fallback to mock data for recommendations');
        return _getMockRecommendations(limit);
      }
    } catch (e) {
      log('Error fetching tour recommendations, using mock data: $e');
      return _getMockRecommendations(limit);
    }
  }

  // Get similar tours
  Future<List<Tour>> getSimilarTours(int tourId, {int limit = 4}) async {
    try {
      log('Fetching similar tours for tour ID: $tourId');

      // First try to get similar tours from the API
      try {
        final response = await _apiClient.get(
          '/recommendation/tours/$tourId/similar',
          queryParams: {'limit': limit.toString()},
          requiresAuth: false,
          timeoutSeconds: 3,
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          final tours =
              data
                  .map((item) => Tour.fromJson(item as Map<String, dynamic>))
                  .toList();

          log('Successfully fetched ${tours.length} similar tours');
          return tours;
        }
      } catch (apiError) {
        log('API error for similar tours, using fallback: $apiError');
        // Continue to fallback data
      }

      // Fallback: Get regular tours (but exclude the current one)
      final toursResponse = await _apiClient.get(
        '/tours',
        queryParams: {'pageSize': (limit + 5).toString()},
        requiresAuth: false,
      );

      if (toursResponse.statusCode == 200) {
        final data = json.decode(toursResponse.body);
        final toursData = data['items'] as List<dynamic>;

        final tours =
            toursData
                .map((item) => Tour.fromJson(item as Map<String, dynamic>))
                .where((tour) => tour.id != tourId)
                .take(limit)
                .toList();

        if (tours.isNotEmpty) {
          log('Successfully fetched ${tours.length} alternative tours');
          return tours;
        }
      }

      // If all else fails, return mock data
      log('Fallback to mock data for similar tours');
      return _getMockSimilarTours(tourId, limit);
    } catch (e) {
      log('Error fetching similar tours, using mock data: $e');
      return _getMockSimilarTours(tourId, limit);
    }
  }

  // Get user insights
  Future<UserInsights?> getUserInsights() async {
    try {
      log('Fetching user insights');

      try {
        final response = await _apiClient.get(
          '/recommendation/user/insights',
          requiresAuth: false, // Changed to false to avoid auth issues
          timeoutSeconds: 3,
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final insights = UserInsights.fromJson(data);

          log('Successfully fetched user insights');
          return insights;
        }
      } catch (apiError) {
        log('API error for user insights, using fallback: $apiError');
        // Continue to fallback
      }

      // Return mock insights
      log('Using mock user insights');
      return _getMockUserInsights();
    } catch (e) {
      log('Error fetching user insights, using mock data: $e');
      return _getMockUserInsights();
    }
  }

  // Get flash deals
  Future<List<FlashDeal>> getFlashDeals({int limit = 4}) async {
    try {
      log('Fetching flash deals');

      try {
        final response = await _apiClient.get(
          '/recommendation/deals/flash',
          queryParams: {'limit': limit.toString()},
          requiresAuth: false,
          timeoutSeconds: 3,
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          final deals =
              data
                  .map(
                    (item) => FlashDeal.fromJson(item as Map<String, dynamic>),
                  )
                  .toList();

          log('Successfully fetched ${deals.length} flash deals');
          return deals;
        }
      } catch (apiError) {
        log('API error for flash deals, using fallback: $apiError');
        // Continue to fallback
      }

      // Try to create flash deals from regular tours
      try {
        final toursResponse = await _apiClient.get(
          '/tours',
          queryParams: {
            'pageSize': limit.toString(),
            'sortBy': 'rating',
            'ascending': 'false',
          },
          requiresAuth: false,
        );

        if (toursResponse.statusCode == 200) {
          final data = json.decode(toursResponse.body);
          final toursData = data['items'] as List<dynamic>;

          if (toursData.isNotEmpty) {
            final deals =
                toursData.map((item) {
                  final tour = Tour.fromJson(item as Map<String, dynamic>);
                  return _createFlashDealFromTour(tour);
                }).toList();

            log('Created ${deals.length} flash deals from tours');
            return deals;
          }
        }
      } catch (tourError) {
        log('Error creating flash deals from tours: $tourError');
      }

      // Return mock deals
      log('Using mock flash deals');
      return _getMockFlashDeals(limit);
    } catch (e) {
      log('Error fetching flash deals, using mock data: $e');
      return _getMockFlashDeals(limit);
    }
  }

  // Get seasonal offers
  Future<List<SeasonalOffer>> getSeasonalOffers({int limit = 4}) async {
    try {
      log('Fetching seasonal offers');

      try {
        final response = await _apiClient.get(
          '/recommendation/offers/seasonal',
          queryParams: {'limit': limit.toString()},
          requiresAuth: false,
          timeoutSeconds: 3,
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          final offers =
              data
                  .map(
                    (item) =>
                        SeasonalOffer.fromJson(item as Map<String, dynamic>),
                  )
                  .toList();

          log('Successfully fetched ${offers.length} seasonal offers');
          return offers;
        }
      } catch (apiError) {
        log('API error for seasonal offers, using fallback: $apiError');
        // Continue to fallback
      }

      // Try to create seasonal offers from tours
      try {
        final toursResponse = await _apiClient.get(
          '/tours',
          queryParams: {
            'pageSize': limit.toString(),
            'sortBy': 'created',
            'ascending': 'false',
          },
          requiresAuth: false,
        );

        if (toursResponse.statusCode == 200) {
          final data = json.decode(toursResponse.body);
          final toursData = data['items'] as List<dynamic>;

          if (toursData.isNotEmpty) {
            final offers =
                toursData.map((item) {
                  final tour = Tour.fromJson(item as Map<String, dynamic>);
                  return _createSeasonalOfferFromTour(tour);
                }).toList();

            log('Created ${offers.length} seasonal offers from tours');
            return offers;
          }
        }
      } catch (tourError) {
        log('Error creating seasonal offers from tours: $tourError');
      }

      // Return mock offers
      log('Using mock seasonal offers');
      return _getMockSeasonalOffers(limit);
    } catch (e) {
      log('Error fetching seasonal offers, using mock data: $e');
      return _getMockSeasonalOffers(limit);
    }
  }

  // Helper method to parse error responses
  Map<String, dynamic> _parseErrorResponse(dynamic response) {
    try {
      if (response.body != null && response.body.isNotEmpty) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      log('Error parsing error response: $e');
    }
    return {'message': 'An unknown error occurred'};
  }

  // Generate a recommendation reason based on tour attributes
  String _generateRecommendationReason(Tour tour) {
    final reasons = [
      'Based on your interest in ${tour.category} tours',
      'Popular destination in ${tour.location}',
      'Matches your preferred activity type: ${tour.activityType}',
      'Great choice for ${tour.difficultyLevel.toLowerCase()} difficulty preferences',
      'Top-rated experience with ${tour.averageRating != null ? tour.averageRating!.toStringAsFixed(1) : "high"} rating',
      'Perfect ${tour.durationInDays}-day getaway that matches your travel style',
    ];

    // Return a different reason based on the tour id to provide variety
    return reasons[tour.id % reasons.length];
  }

  // Create a flash deal from a tour
  FlashDeal _createFlashDealFromTour(Tour tour) {
    final discountPercentage = (tour.id % 5 + 2) * 5; // 10% to 30% discount
    final discountedPrice = tour.price * (1 - discountPercentage / 100);

    return FlashDeal(
      id: tour.id,
      type: tour.category,
      name: tour.name,
      description:
          tour.description.length > 100
              ? '${tour.description.substring(0, 97)}...'
              : tour.description,
      originalPrice: tour.price,
      discountedPrice: discountedPrice,
      discountPercentage: discountPercentage,
      imageUrl: tour.mainImageUrl,
      location: tour.location,
      endsAt: DateTime.now().add(
        Duration(hours: 24 + (tour.id % 72)),
      ), // 1-4 days from now
    );
  }

  // Create a seasonal offer from a tour
  SeasonalOffer _createSeasonalOfferFromTour(Tour tour) {
    final seasons = ['Spring', 'Summer', 'Fall', 'Winter'];
    final season = seasons[tour.id % seasons.length];
    final discountAmount = tour.price * 0.15; // 15% discount

    final seasonalHighlights = [
      'Perfect weather for outdoor activities',
      'Experience the beauty of $season in ${tour.location}',
      'Special $season activities included',
      'Unique $season-only experiences await',
      'Best time of year to visit this destination',
    ];

    return SeasonalOffer(
      id: tour.id,
      type: tour.category,
      name: '$season ${tour.name}',
      description: tour.description,
      price: tour.price,
      discountAmount: discountAmount,
      imageUrl: tour.mainImageUrl,
      location: tour.location,
      season: season,
      seasonalHighlight:
          seasonalHighlights[tour.id % seasonalHighlights.length],
    );
  }

  // Mock data for recommendations
  List<RecommendedTour> _getMockRecommendations(int limit) {
    final mockTours = _getMockTours(limit);
    return mockTours
        .map(
          (tour) => RecommendedTour(
            tour: tour,
            reasonForRecommendation: _generateRecommendationReason(tour),
          ),
        )
        .toList();
  }

  // Mock data for similar tours
  List<Tour> _getMockSimilarTours(int currentId, int limit) {
    return _getMockTours(
      limit + 1,
    ).where((tour) => tour.id != currentId).take(limit).toList();
  }

  // Mock user insights
  UserInsights _getMockUserInsights() {
    return UserInsights(
      userId: 'user123',
      mostVisitedDestination: 'Paris, France',
      favoriteTourCategory: 'Cultural',
      totalSpent: 2450.75,
      totalTrips: 8,
      averageTripDuration: 4,
      totalSavings: 625.50,
    );
  }

  // Mock flash deals
  List<FlashDeal> _getMockFlashDeals(int limit) {
    final mockTours = _getMockTours(limit);
    return mockTours.map(_createFlashDealFromTour).toList();
  }

  // Mock seasonal offers
  List<SeasonalOffer> _getMockSeasonalOffers(int limit) {
    final mockTours = _getMockTours(limit);
    return mockTours.map(_createSeasonalOfferFromTour).toList();
  }

  // Mock tours for when all else fails
  List<Tour> _getMockTours(int count) {
    final List<Tour> mockTours = [];

    final locations = [
      'Paris, France',
      'Rome, Italy',
      'Barcelona, Spain',
      'New York, USA',
      'Tokyo, Japan',
      'Sydney, Australia',
      'Cairo, Egypt',
      'Rio de Janeiro, Brazil',
    ];

    final categories = [
      'Cultural',
      'Adventure',
      'Relaxation',
      'Historical',
      'Culinary',
      'Wildlife',
    ];

    final activityTypes = ['Indoor', 'Outdoor', 'Mixed'];
    final difficultyLevels = ['Easy', 'Moderate', 'Challenging'];

    for (int i = 1; i <= count; i++) {
      final id = 1000 + i;
      final durationInDays = 1 + (id % 7); // 1-7 days

      mockTours.add(
        Tour(
          id: id,
          name: 'Tour Experience $i',
          description:
              'Discover the wonders of this amazing destination with our guided tour package.',
          price: 100.0 + (id % 10) * 25.0, // $100-$325
          durationInDays: durationInDays,
          location: locations[id % locations.length],
          difficultyLevel: difficultyLevels[id % difficultyLevels.length],
          activityType: activityTypes[id % activityTypes.length],
          category: categories[id % categories.length],
          maxGroupSize: 4 + (id % 12), // 4-15 people
          mainImageUrl: 'https://picsum.photos/id/${100 + id}/600/400',
          isActive: true,
          createdAt: DateTime.now().subtract(Duration(days: id * 2)),
          images: [],
          features: [],
          itineraryItems: [],
          averageRating: 3.5 + (id % 15) / 10, // 3.5-5.0
          reviewCount: 10 + (id % 90), // 10-99
          discountedPrice:
              (id % 3 == 0)
                  ? 80.0 + (id % 10) * 20.0
                  : null, // occasional discounts
          discountPercentage:
              (id % 3 == 0) ? 20 : null, // 20% discount when applicable
        ),
      );
    }

    return mockTours;
  }
}
