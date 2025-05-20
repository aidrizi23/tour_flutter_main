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
        '/health',
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
        if (response.statusCode == 401) {
          throw Exception('Authentication required');
        } else if (response.statusCode == 404) {
          throw Exception('No recommendations available at this time');
        } else {
          final errorData = _parseErrorResponse(response);
          throw Exception(
            errorData['message'] ?? 'Failed to fetch recommendations',
          );
        }
      }
    } catch (e) {
      log('Error fetching tour recommendations: $e');
      rethrow;
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
        if (response.statusCode == 404) {
          throw Exception('No similar tours found');
        } else {
          final errorData = _parseErrorResponse(response);
          throw Exception(
            errorData['message'] ?? 'Failed to fetch similar tours',
          );
        }
      }
    } catch (e) {
      log('Error fetching similar tours: $e');
      rethrow;
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

        if (response.statusCode == 401) {
          throw Exception('Authentication required to fetch insights');
        } else if (response.statusCode == 404) {
          throw Exception('No insights available - more travel history needed');
        } else {
          final errorData = _parseErrorResponse(response);
          throw Exception(errorData['message'] ?? 'Failed to fetch insights');
        }
      }
    } catch (e) {
      log('Error fetching user insights: $e');
      rethrow;
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
        final errorData = _parseErrorResponse(response);
        throw Exception(errorData['message'] ?? 'Failed to fetch flash deals');
      }
    } catch (e) {
      log('Error fetching flash deals: $e');
      rethrow;
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
        final errorData = _parseErrorResponse(response);
        throw Exception(
          errorData['message'] ?? 'Failed to fetch seasonal offers',
        );
      }
    } catch (e) {
      log('Error fetching seasonal offers: $e');
      rethrow;
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
}
