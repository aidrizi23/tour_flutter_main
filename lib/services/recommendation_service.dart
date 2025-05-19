import 'dart:convert';
import 'dart:developer';
import '../models/recommendation_models.dart';
import '../models/tour_models.dart';
import '../utils/api_client.dart';

class RecommendationService {
  final ApiClient _apiClient = ApiClient();

  // Get personalized tour recommendations
  Future<List<RecommendedTour>> getPersonalizedTourRecommendations({
    int limit = 5,
  }) async {
    try {
      log('Fetching personalized tour recommendations');

      final response = await _apiClient.get(
        '/recommendation/tours/personalized',
        queryParams: {'limit': limit.toString()},
        requiresAuth: true,
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
      } else {
        log(
          'Failed to fetch tour recommendations. Status: ${response.statusCode}',
        );
        throw Exception('Failed to fetch tour recommendations');
      }
    } catch (e) {
      log('Error fetching tour recommendations: $e');
      // Return empty list instead of throwing to handle gracefully in UI
      return [];
    }
  }

  // Get popular destinations
  Future<List<String>> getPopularDestinations({int limit = 10}) async {
    try {
      log('Fetching popular destinations');

      final response = await _apiClient.get(
        '/recommendation/destinations/popular',
        queryParams: {'limit': limit.toString()},
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final destinations = data.map((item) => item as String).toList();

        log('Successfully fetched ${destinations.length} popular destinations');
        return destinations;
      } else {
        log(
          'Failed to fetch popular destinations. Status: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      log('Error fetching popular destinations: $e');
      return [];
    }
  }

  // Get trending packages
  Future<List<TravelPackage>> getTrendingPackages({int limit = 5}) async {
    try {
      log('Fetching trending packages');

      final response = await _apiClient.get(
        '/recommendation/packages/trending',
        queryParams: {'limit': limit.toString()},
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final packages =
            data
                .map(
                  (item) =>
                      TravelPackage.fromJson(item as Map<String, dynamic>),
                )
                .toList();

        log('Successfully fetched ${packages.length} trending packages');
        return packages;
      } else {
        log(
          'Failed to fetch trending packages. Status: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      log('Error fetching trending packages: $e');
      return [];
    }
  }

  // Get similar tours
  Future<List<Tour>> getSimilarTours(int tourId, {int limit = 4}) async {
    try {
      log('Fetching similar tours for tour ID: $tourId');

      final response = await _apiClient.get(
        '/recommendation/tours/$tourId/similar',
        queryParams: {'limit': limit.toString()},
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final tours =
            data
                .map((item) => Tour.fromJson(item as Map<String, dynamic>))
                .toList();

        log('Successfully fetched ${tours.length} similar tours');
        return tours;
      } else {
        log('Failed to fetch similar tours. Status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error fetching similar tours: $e');
      return [];
    }
  }

  // Get similar packages
  Future<List<TravelPackage>> getSimilarPackages(
    int packageId, {
    int limit = 4,
  }) async {
    try {
      log('Fetching similar packages for package ID: $packageId');

      final response = await _apiClient.get(
        '/recommendation/packages/$packageId/similar',
        queryParams: {'limit': limit.toString()},
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final packages =
            data
                .map(
                  (item) =>
                      TravelPackage.fromJson(item as Map<String, dynamic>),
                )
                .toList();

        log('Successfully fetched ${packages.length} similar packages');
        return packages;
      } else {
        log('Failed to fetch similar packages. Status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error fetching similar packages: $e');
      return [];
    }
  }

  // Get user insights
  Future<UserInsights?> getUserInsights() async {
    try {
      log('Fetching user insights');

      final response = await _apiClient.get(
        '/recommendation/user/insights',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final insights = UserInsights.fromJson(data);

        log('Successfully fetched user insights');
        return insights;
      } else {
        log('Failed to fetch user insights. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error fetching user insights: $e');
      return null;
    }
  }

  // Get flash deals
  Future<List<FlashDeal>> getFlashDeals({int limit = 4}) async {
    try {
      log('Fetching flash deals');

      final response = await _apiClient.get(
        '/recommendation/deals/flash',
        queryParams: {'limit': limit.toString()},
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final deals =
            data
                .map((item) => FlashDeal.fromJson(item as Map<String, dynamic>))
                .toList();

        log('Successfully fetched ${deals.length} flash deals');
        return deals;
      } else {
        log('Failed to fetch flash deals. Status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error fetching flash deals: $e');
      return [];
    }
  }

  // Get seasonal offers
  Future<List<SeasonalOffer>> getSeasonalOffers({int limit = 4}) async {
    try {
      log('Fetching seasonal offers');

      final response = await _apiClient.get(
        '/recommendation/offers/seasonal',
        queryParams: {'limit': limit.toString()},
        requiresAuth: false,
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
      } else {
        log('Failed to fetch seasonal offers. Status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error fetching seasonal offers: $e');
      return [];
    }
  }
}
