import 'package:flutter/material.dart';
import 'tour_models.dart';

// Recommended tour model with reason
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

// Package (combination of tours, houses, etc.)
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

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  String get displayPrice => '\$${price.toStringAsFixed(2)}';
  String get durationText => '$duration ${duration == 1 ? 'day' : 'days'}';
  String get dateRange => '${_formatDate(startDate)} - ${_formatDate(endDate)}';

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color getGradientStartColor() {
    // Generate a consistent color based on name and location
    final int hash = name.hashCode + location.hashCode;
    return Color.fromARGB(
      255,
      ((hash & 0xFF0000) >> 16).clamp(20, 180),
      ((hash & 0x00FF00) >> 8).clamp(20, 180),
      (hash & 0x0000FF).clamp(60, 200),
    );
  }

  Color getGradientEndColor() {
    final Color start = getGradientStartColor();
    return Color.fromARGB(
      255,
      (start.red * 0.7).round(),
      (start.green * 0.7).round(),
      (start.blue * 0.7).round(),
    );
  }
}

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

  String get displayPrice => '\$${specialPrice.toStringAsFixed(2)}';
}

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

  String get displayPrice => '\$${specialPrice.toStringAsFixed(2)}';
}

// Flash deal model
class FlashDeal {
  final int id;
  final String type; // "Tour", "House", "Package"
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

  String get displayDiscountedPrice =>
      '\$${discountedPrice.toStringAsFixed(2)}';
  String get displayOriginalPrice => '\$${originalPrice.toStringAsFixed(2)}';
  String get displayDiscount => '$discountPercentage% OFF';

  bool get isExpiringSoon {
    final now = DateTime.now();
    return endsAt.difference(now).inHours < 24;
  }

  String get timeRemaining {
    final now = DateTime.now();
    final difference = endsAt.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours.remainder(24)}h left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes.remainder(60)}m left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m left';
    } else {
      return 'Ending soon!';
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
        return Colors.orange;
    }
  }
}

// Seasonal offer model
class SeasonalOffer {
  final int id;
  final String type; // "Tour", "House", "Package"
  final String name;
  final String description;
  final double price;
  final double? discountAmount;
  final String? imageUrl;
  final String location;
  final String season; // "Summer", "Fall", "Winter", "Spring"
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

  String get displayPrice => '\$${price.toStringAsFixed(2)}';
  String get displayDiscount =>
      discountAmount != null
          ? 'Save \$${discountAmount!.toStringAsFixed(2)}'
          : '';
  bool get hasDiscount => discountAmount != null && discountAmount! > 0;

  Color getSeasonColor() {
    switch (season.toLowerCase()) {
      case 'summer':
        return Colors.orange;
      case 'fall':
        return Colors.amber.shade700;
      case 'winter':
        return Colors.lightBlue;
      case 'spring':
        return Colors.green;
      default:
        return Colors.teal;
    }
  }

  IconData getSeasonIcon() {
    switch (season.toLowerCase()) {
      case 'summer':
        return Icons.wb_sunny_rounded;
      case 'fall':
        return Icons.nature_rounded;
      case 'winter':
        return Icons.ac_unit_rounded;
      case 'spring':
        return Icons.eco_rounded;
      default:
        return Icons.event_rounded;
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
