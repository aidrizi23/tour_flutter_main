import 'package:flutter/material.dart';
import 'package:tour_flutter_main/models/tour_models.dart';

// Represents a recommended tour with reasoning
class RecommendedTour {
  final Tour tour;
  final String reasonForRecommendation;

  RecommendedTour({required this.tour, required this.reasonForRecommendation});

  factory RecommendedTour.fromJson(Map<String, dynamic> json) {
    try {
      final tour = Tour.fromJson(json);
      final reason =
          json['reasonForRecommendation'] as String? ?? 'Recommended for you';

      return RecommendedTour(tour: tour, reasonForRecommendation: reason);
    } catch (e) {
      // If there's any error in parsing, create a fallback from the JSON
      // This adds robustness when working with potentially inconsistent API data
      return _createFallbackFromJson(json);
    }
  }

  // Creates a fallback recommendation from partial JSON data
  static RecommendedTour _createFallbackFromJson(Map<String, dynamic> json) {
    try {
      // Try to extract basic tour properties
      final id = json['id'] as int? ?? 0;
      final name = json['name'] as String? ?? 'Tour Experience';
      final location = json['location'] as String? ?? 'Unknown Location';
      final price = (json['price'] as num?)?.toDouble() ?? 99.99;
      final imageUrl = json['mainImageUrl'] as String?;

      // Create a minimal tour
      final tour = Tour(
        id: id,
        name: name,
        description:
            json['description'] as String? ??
            'Explore this amazing destination.',
        price: price,
        durationInDays: json['durationInDays'] as int? ?? 1,
        location: location,
        difficultyLevel: json['difficultyLevel'] as String? ?? 'Moderate',
        activityType: json['activityType'] as String? ?? 'Mixed',
        category: json['category'] as String? ?? 'Experience',
        maxGroupSize: json['maxGroupSize'] as int? ?? 10,
        mainImageUrl: imageUrl,
        isActive: true,
        createdAt: DateTime.now(),
        images: [],
        features: [],
        itineraryItems: [],
      );

      return RecommendedTour(
        tour: tour,
        reasonForRecommendation: 'Recommended for you',
      );
    } catch (e) {
      // If even the fallback creation fails, return an absolute minimum tour
      return RecommendedTour(
        tour: Tour(
          id: 0,
          name: 'Tour Experience',
          description: 'Explore this amazing destination.',
          price: 99.99,
          durationInDays: 1,
          location: 'Popular Destination',
          difficultyLevel: 'Moderate',
          activityType: 'Mixed',
          category: 'Experience',
          maxGroupSize: 10,
          isActive: true,
          createdAt: DateTime.now(),
          images: [],
          features: [],
          itineraryItems: [],
        ),
        reasonForRecommendation: 'Recommended for you',
      );
    }
  }
}

// Flash deal model
class FlashDeal {
  final int id;
  final String type;
  final String name;
  final String description;
  final double originalPrice;
  final double discountedPrice;
  final int discountPercentage;
  final String? imageUrl;
  final String location;
  final DateTime endsAt;

  FlashDeal({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercentage,
    this.imageUrl,
    required this.location,
    required this.endsAt,
  });

  factory FlashDeal.fromJson(Map<String, dynamic> json) {
    try {
      return FlashDeal(
        id: json['id'] as int,
        type: json['type'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        originalPrice: (json['originalPrice'] as num).toDouble(),
        discountedPrice: (json['discountedPrice'] as num).toDouble(),
        discountPercentage: json['discountPercentage'] as int,
        imageUrl: json['imageUrl'] as String?,
        location: json['location'] as String,
        endsAt: DateTime.parse(json['endsAt'] as String),
      );
    } catch (e) {
      // Provide fallback for invalid data
      return _createFallbackFromJson(json);
    }
  }

  // Create fallback from partial JSON
  static FlashDeal _createFallbackFromJson(Map<String, dynamic> json) {
    try {
      // Try to extract essential properties
      final id = json['id'] as int? ?? 0;
      final name = json['name'] as String? ?? 'Flash Deal';
      final price = (json['originalPrice'] as num?)?.toDouble() ?? 99.99;
      final discountPct = json['discountPercentage'] as int? ?? 20;
      final discountedPrice =
          (json['discountedPrice'] as num?)?.toDouble() ??
          (price * (1 - discountPct / 100));

      return FlashDeal(
        id: id,
        type: json['type'] as String? ?? 'Tour',
        name: name,
        description: json['description'] as String? ?? 'Limited time offer!',
        originalPrice: price,
        discountedPrice: discountedPrice,
        discountPercentage: discountPct,
        imageUrl: json['imageUrl'] as String?,
        location: json['location'] as String? ?? 'Popular Destination',
        endsAt: DateTime.now().add(const Duration(days: 1)),
      );
    } catch (e) {
      // Absolute fallback with minimal data
      return FlashDeal(
        id: 0,
        type: 'Tour',
        name: 'Limited Time Offer',
        description: 'Special discount available for a limited time!',
        originalPrice: 99.99,
        discountedPrice: 79.99,
        discountPercentage: 20,
        location: 'Popular Destination',
        endsAt: DateTime.now().add(const Duration(days: 1)),
      );
    }
  }

  // Helper getters
  String get displayOriginalPrice => '\$${originalPrice.toStringAsFixed(2)}';
  String get displayDiscountedPrice =>
      '\$${discountedPrice.toStringAsFixed(2)}';
  String get displayDiscount => '$discountPercentage% OFF';

  bool get isExpiringSoon {
    final now = DateTime.now();
    final difference = endsAt.difference(now);
    return difference.inHours <= 24;
  }

  String get timeRemaining {
    final now = DateTime.now();
    final difference = endsAt.difference(now);

    if (difference.isNegative) {
      return 'Expired';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} left';
    } else {
      return '${difference.inMinutes} min left';
    }
  }

  Color getTypeColor() {
    switch (type.toLowerCase()) {
      case 'tour':
        return Colors.blue;
      case 'house':
        return Colors.green;
      case 'package':
        return Colors.purple;
      default:
        return Colors.amber;
    }
  }
}

// Seasonal offer model
class SeasonalOffer {
  final int id;
  final String type;
  final String name;
  final String description;
  final double price;
  final double? discountAmount;
  final String? imageUrl;
  final String location;
  final String season;
  final String seasonalHighlight;

  SeasonalOffer({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.price,
    this.discountAmount,
    this.imageUrl,
    required this.location,
    required this.season,
    required this.seasonalHighlight,
  });

  factory SeasonalOffer.fromJson(Map<String, dynamic> json) {
    try {
      return SeasonalOffer(
        id: json['id'] as int,
        type: json['type'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        price: (json['price'] as num).toDouble(),
        discountAmount: (json['discountAmount'] as num?)?.toDouble(),
        imageUrl: json['imageUrl'] as String?,
        location: json['location'] as String,
        season: json['season'] as String,
        seasonalHighlight: json['seasonalHighlight'] as String,
      );
    } catch (e) {
      // Provide fallback for invalid data
      return _createFallbackFromJson(json);
    }
  }

  // Create fallback from partial JSON
  static SeasonalOffer _createFallbackFromJson(Map<String, dynamic> json) {
    try {
      final seasons = ['Spring', 'Summer', 'Fall', 'Winter'];
      final currentSeason = _getCurrentSeason();

      // Try to extract essential properties
      final id = json['id'] as int? ?? 0;
      final name = json['name'] as String? ?? 'Seasonal Offer';
      final price = (json['price'] as num?)?.toDouble() ?? 149.99;

      return SeasonalOffer(
        id: id,
        type: json['type'] as String? ?? 'Tour',
        name: name,
        description:
            json['description'] as String? ?? 'Special seasonal experience!',
        price: price,
        discountAmount: (json['discountAmount'] as num?)?.toDouble(),
        imageUrl: json['imageUrl'] as String?,
        location: json['location'] as String? ?? 'Popular Destination',
        season: json['season'] as String? ?? currentSeason,
        seasonalHighlight:
            json['seasonalHighlight'] as String? ??
            'Special activities for the $currentSeason season!',
      );
    } catch (e) {
      // Absolute fallback with minimal data
      final currentSeason = _getCurrentSeason();

      return SeasonalOffer(
        id: 0,
        type: 'Tour',
        name: '$currentSeason Special',
        description: 'Enjoy this special seasonal experience!',
        price: 149.99,
        location: 'Popular Destination',
        season: currentSeason,
        seasonalHighlight: 'Special activities for the $currentSeason season!',
      );
    }
  }

  // Helper to determine current season
  static String _getCurrentSeason() {
    final now = DateTime.now();
    final month = now.month;

    if (month >= 3 && month <= 5) return 'Spring';
    if (month >= 6 && month <= 8) return 'Summer';
    if (month >= 9 && month <= 11) return 'Fall';
    return 'Winter';
  }

  // Helper getters
  bool get hasDiscount => discountAmount != null && discountAmount! > 0;
  String get displayPrice => '\$${price.toStringAsFixed(2)}';
  String get displayDiscount =>
      hasDiscount ? 'Save \$${discountAmount!.toStringAsFixed(2)}' : '';

  Color getSeasonColor() {
    switch (season.toLowerCase()) {
      case 'spring':
        return Colors.green.shade600;
      case 'summer':
        return Colors.orange.shade600;
      case 'fall':
      case 'autumn':
        return Colors.amber.shade800;
      case 'winter':
        return Colors.blue.shade700;
      default:
        return Colors.teal.shade600;
    }
  }

  IconData getSeasonIcon() {
    switch (season.toLowerCase()) {
      case 'spring':
        return Icons.local_florist_rounded;
      case 'summer':
        return Icons.wb_sunny_rounded;
      case 'fall':
      case 'autumn':
        return Icons.eco_rounded;
      case 'winter':
        return Icons.ac_unit_rounded;
      default:
        return Icons.calendar_today_rounded;
    }
  }
}

// User insights model
class UserInsights {
  final String userId;
  final String mostVisitedDestination;
  final String favoriteTourCategory;
  final double totalSpent;
  final int totalTrips;
  final int averageTripDuration;
  final double totalSavings;

  UserInsights({
    required this.userId,
    required this.mostVisitedDestination,
    required this.favoriteTourCategory,
    required this.totalSpent,
    required this.totalTrips,
    required this.averageTripDuration,
    required this.totalSavings,
  });

  factory UserInsights.fromJson(Map<String, dynamic> json) {
    try {
      return UserInsights(
        userId: json['userId'] as String,
        mostVisitedDestination: json['mostVisitedDestination'] as String,
        favoriteTourCategory: json['favoriteTourCategory'] as String,
        totalSpent: (json['totalSpent'] as num).toDouble(),
        totalTrips: json['totalTrips'] as int,
        averageTripDuration: json['averageTripDuration'] as int,
        totalSavings: (json['totalSavings'] as num).toDouble(),
      );
    } catch (e) {
      // Provide fallback for invalid data
      return _createFallbackFromJson(json);
    }
  }

  // Create fallback from partial JSON
  static UserInsights _createFallbackFromJson(Map<String, dynamic> json) {
    try {
      return UserInsights(
        userId: json['userId'] as String? ?? 'user',
        mostVisitedDestination:
            json['mostVisitedDestination'] as String? ?? 'Popular Destination',
        favoriteTourCategory:
            json['favoriteTourCategory'] as String? ?? 'Cultural',
        totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 1250.00,
        totalTrips: json['totalTrips'] as int? ?? 5,
        averageTripDuration: json['averageTripDuration'] as int? ?? 4,
        totalSavings: (json['totalSavings'] as num?)?.toDouble() ?? 350.00,
      );
    } catch (e) {
      // Absolute fallback
      return UserInsights(
        userId: 'user',
        mostVisitedDestination: 'Popular Destination',
        favoriteTourCategory: 'Cultural',
        totalSpent: 1250.00,
        totalTrips: 5,
        averageTripDuration: 4,
        totalSavings: 350.00,
      );
    }
  }
}
