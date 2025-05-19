import 'package:flutter/material.dart';
import 'package:tour_flutter_main/models/tour_models.dart';

// Represents a recommended tour with reasoning
class RecommendedTour {
  final Tour tour;
  final String reasonForRecommendation;

  RecommendedTour({required this.tour, required this.reasonForRecommendation});

  factory RecommendedTour.fromJson(Map<String, dynamic> json) {
    return RecommendedTour(
      tour: Tour.fromJson(json),
      reasonForRecommendation:
          json['reasonForRecommendation'] as String? ?? 'Recommended for you',
    );
  }
}

// Travel package model
class TravelPackage {
  final int id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final int? discountPercentage;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final int duration;
  final String? mainImageUrl;
  final int maxPeople;
  final bool isFeatured;
  final List<PackageTour> tours;
  final List<PackageHouse> houses;

  TravelPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    this.discountPercentage,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.duration,
    this.mainImageUrl,
    required this.maxPeople,
    this.isFeatured = false,
    required this.tours,
    required this.houses,
  });

  factory TravelPackage.fromJson(Map<String, dynamic> json) {
    return TravelPackage(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      discountPercentage: json['discountPercentage'] as int?,
      location: json['location'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      duration: json['duration'] as int,
      mainImageUrl: json['mainImageUrl'] as String?,
      maxPeople: json['maxPeople'] as int,
      isFeatured: json['isFeatured'] as bool? ?? false,
      tours:
          (json['tours'] as List<dynamic>?)
              ?.map((e) => PackageTour.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      houses:
          (json['houses'] as List<dynamic>?)
              ?.map((e) => PackageHouse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Helper getters
  bool get hasDiscount =>
      discountPercentage != null &&
      discountPercentage! > 0 &&
      originalPrice != null;
  String get displayPrice => '\$${price.toStringAsFixed(2)}';
  String get dateRange => '${_formatDate(startDate)} - ${_formatDate(endDate)}';
  String get durationText => '$duration ${duration == 1 ? 'day' : 'days'}';

  Color getGradientStartColor() {
    if (isFeatured) return const Color(0xFF1A237E);
    return const Color(0xFF1565C0);
  }

  Color getGradientEndColor() {
    if (isFeatured) return const Color(0xFF3949AB);
    return const Color(0xFF1976D2);
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

// Tour included in a package
class PackageTour {
  final int tourId;
  final String tourName;
  final double specialPrice;
  final DateTime startDate;
  final int durationInDays;
  final String location;
  final String? mainImageUrl;

  PackageTour({
    required this.tourId,
    required this.tourName,
    required this.specialPrice,
    required this.startDate,
    required this.durationInDays,
    required this.location,
    this.mainImageUrl,
  });

  factory PackageTour.fromJson(Map<String, dynamic> json) {
    return PackageTour(
      tourId: json['tourId'] as int,
      tourName: json['tourName'] as String,
      specialPrice: (json['specialPrice'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      durationInDays: json['durationInDays'] as int,
      location: json['location'] as String,
      mainImageUrl: json['mainImageUrl'] as String?,
    );
  }
}

// House included in a package
class PackageHouse {
  final int houseId;
  final String houseName;
  final double specialPrice;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int nights;
  final String location;
  final String? mainImageUrl;

  PackageHouse({
    required this.houseId,
    required this.houseName,
    required this.specialPrice,
    required this.checkInDate,
    required this.checkOutDate,
    required this.nights,
    required this.location,
    this.mainImageUrl,
  });

  factory PackageHouse.fromJson(Map<String, dynamic> json) {
    return PackageHouse(
      houseId: json['houseId'] as int,
      houseName: json['houseName'] as String,
      specialPrice: (json['specialPrice'] as num).toDouble(),
      checkInDate: DateTime.parse(json['checkInDate'] as String),
      checkOutDate: DateTime.parse(json['checkOutDate'] as String),
      nights: json['nights'] as int,
      location: json['location'] as String,
      mainImageUrl: json['mainImageUrl'] as String?,
    );
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

    if (difference.inDays > 0) {
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
    return UserInsights(
      userId: json['userId'] as String,
      mostVisitedDestination: json['mostVisitedDestination'] as String,
      favoriteTourCategory: json['favoriteTourCategory'] as String,
      totalSpent: (json['totalSpent'] as num).toDouble(),
      totalTrips: json['totalTrips'] as int,
      averageTripDuration: json['averageTripDuration'] as int,
      totalSavings: (json['totalSavings'] as num).toDouble(),
    );
  }
}
