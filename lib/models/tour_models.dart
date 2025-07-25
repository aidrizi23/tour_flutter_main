import 'package:flutter/material.dart';
import '../widgets/unified_filter_system.dart';

class TourImage {
  final int id;
  final String imageUrl;
  final String? caption;
  final int displayOrder;

  TourImage({
    required this.id,
    required this.imageUrl,
    this.caption,
    required this.displayOrder,
  });

  factory TourImage.fromJson(Map<String, dynamic> json) {
    return TourImage(
      id: json['id'] as int,
      imageUrl: json['imageUrl'] as String,
      caption: json['caption'] as String?,
      displayOrder: json['displayOrder'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'caption': caption,
      'displayOrder': displayOrder,
    };
  }
}

class TourFeature {
  final int id;
  final String name;
  final String? description;

  TourFeature({required this.id, required this.name, this.description});

  factory TourFeature.fromJson(Map<String, dynamic> json) {
    return TourFeature(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }
}

class ItineraryItem {
  final int id;
  final int dayNumber;
  final String title;
  final String description;
  final String? location;
  final String? startTime;
  final String? endTime;
  final String? activityType;

  ItineraryItem({
    required this.id,
    required this.dayNumber,
    required this.title,
    required this.description,
    this.location,
    this.startTime,
    this.endTime,
    this.activityType,
  });

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      id: json['id'] as int,
      dayNumber: json['dayNumber'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      activityType: json['activityType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dayNumber': dayNumber,
      'title': title,
      'description': description,
      'location': location,
      'startTime': startTime,
      'endTime': endTime,
      'activityType': activityType,
    };
  }
}

class Tour {
  final int id;
  final String name;
  final String description;
  final double price;
  final int durationInDays;
  final String location;
  final String difficultyLevel;
  final String activityType;
  final String category;
  final int maxGroupSize;
  final String? mainImageUrl;
  final bool isActive;
  final DateTime createdAt;
  final List<TourImage> images;
  final List<TourFeature> features;
  final List<ItineraryItem> itineraryItems;
  final double? averageRating;
  final int? reviewCount;
  final double? discountedPrice;
  final int? discountPercentage;

  Tour({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationInDays,
    required this.location,
    required this.difficultyLevel,
    required this.activityType,
    required this.category,
    required this.maxGroupSize,
    this.mainImageUrl,
    required this.isActive,
    required this.createdAt,
    required this.images,
    required this.features,
    required this.itineraryItems,
    this.averageRating,
    this.reviewCount,
    this.discountedPrice,
    this.discountPercentage,
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      durationInDays: json['durationInDays'] as int,
      location: json['location'] as String,
      difficultyLevel: json['difficultyLevel'] as String,
      activityType: json['activityType'] as String,
      category: json['category'] as String,
      maxGroupSize: json['maxGroupSize'] as int,
      mainImageUrl: json['mainImageUrl'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => TourImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      features:
          (json['features'] as List<dynamic>?)
              ?.map((e) => TourFeature.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      itineraryItems:
          (json['itineraryItems'] as List<dynamic>?)
              ?.map((e) => ItineraryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
      discountedPrice: (json['discountedPrice'] as num?)?.toDouble(),
      discountPercentage: json['discountPercentage'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'durationInDays': durationInDays,
      'location': location,
      'difficultyLevel': difficultyLevel,
      'activityType': activityType,
      'category': category,
      'maxGroupSize': maxGroupSize,
      'mainImageUrl': mainImageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'images': images.map((e) => e.toJson()).toList(),
      'features': features.map((e) => e.toJson()).toList(),
      'itineraryItems': itineraryItems.map((e) => e.toJson()).toList(),
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'discountedPrice': discountedPrice,
      'discountPercentage': discountPercentage,
    };
  }

  // Helper getters
  bool get hasDiscount => discountedPrice != null && discountedPrice! < price;
  String get displayPrice =>
      hasDiscount
          ? '\$${discountedPrice!.toStringAsFixed(2)}'
          : '\$${price.toStringAsFixed(2)}';
  String get originalPrice => '\$${price.toStringAsFixed(2)}';
  String get durationText =>
      '$durationInDays ${durationInDays == 1 ? 'day' : 'days'}';

  Color get difficultyColor {
    switch (difficultyLevel.toLowerCase()) {
      case 'easy':
        return const Color(0xFF4CAF50);
      case 'moderate':
        return const Color(0xFFFF9800);
      case 'challenging':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF757575);
    }
  }

  IconData get activityIcon {
    switch (activityType.toLowerCase()) {
      case 'outdoor':
        return Icons.terrain;
      case 'indoor':
        return Icons.domain;
      case 'mixed':
        return Icons.dashboard;
      default:
        return Icons.explore;
    }
  }
}

class PaginatedTours {
  final List<Tour> items;
  final int pageIndex;
  final int totalPages;
  final int totalCount;
  final bool hasPreviousPage;
  final bool hasNextPage;

  PaginatedTours({
    required this.items,
    required this.pageIndex,
    required this.totalPages,
    required this.totalCount,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory PaginatedTours.fromJson(Map<String, dynamic> json) {
    return PaginatedTours(
      items:
          (json['items'] as List<dynamic>)
              .map((e) => Tour.fromJson(e as Map<String, dynamic>))
              .toList(),
      pageIndex: json['pageIndex'] as int,
      totalPages: json['totalPages'] as int,
      totalCount: json['totalCount'] as int,
      hasPreviousPage: json['hasPreviousPage'] as bool,
      hasNextPage: json['hasNextPage'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'pageIndex': pageIndex,
      'totalPages': totalPages,
      'totalCount': totalCount,
      'hasPreviousPage': hasPreviousPage,
      'hasNextPage': hasNextPage,
    };
  }
}

// Filter classes for tour search
class TourFilterRequest extends BaseFilterRequest {
  final String? category;
  final String? difficultyLevel;
  final String? activityType;
  final int? minDuration;
  final int? maxDuration;

  TourFilterRequest({
    super.searchTerm,
    super.location,
    this.category,
    this.difficultyLevel,
    this.activityType,
    super.minPrice,
    super.maxPrice,
    this.minDuration,
    this.maxDuration,
    super.sortBy = 'name',
    super.ascending = true,
    super.pageIndex = 0,
    super.pageSize = 20,
  });

  Map<String, String> toQueryParams() {
    final Map<String, String> params = {};

    if (searchTerm != null && searchTerm!.isNotEmpty) {
      params['searchTerm'] = searchTerm!;
    }
    if (location != null && location!.isNotEmpty) {
      params['location'] = location!;
    }
    if (category != null && category!.isNotEmpty) {
      params['category'] = category!;
    }
    if (difficultyLevel != null && difficultyLevel!.isNotEmpty) {
      params['difficultyLevel'] = difficultyLevel!;
    }
    if (activityType != null && activityType!.isNotEmpty) {
      params['activityType'] = activityType!;
    }
    if (minPrice != null) params['minPrice'] = minPrice.toString();
    if (maxPrice != null) params['maxPrice'] = maxPrice.toString();
    if (minDuration != null) params['minDuration'] = minDuration.toString();
    if (maxDuration != null) params['maxDuration'] = maxDuration.toString();
    params['sortBy'] = sortBy;
    params['ascending'] = ascending.toString();
    params['pageIndex'] = pageIndex.toString();
    params['pageSize'] = pageSize.toString();

    return params;
  }
}

// Review models
class TourReview {
  final int id;
  final String comment;
  final int rating;
  final DateTime createdAt;
  final String userName;

  TourReview({
    required this.id,
    required this.comment,
    required this.rating,
    required this.createdAt,
    required this.userName,
  });

  factory TourReview.fromJson(Map<String, dynamic> json) {
    return TourReview(
      id: json['id'] as int,
      comment: json['comment'] as String,
      rating: json['rating'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userName: json['userName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comment': comment,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'userName': userName,
    };
  }
}

class AddReviewRequest {
  final int tourId;
  final String comment;
  final int rating;

  AddReviewRequest({
    required this.tourId,
    required this.comment,
    required this.rating,
  });

  Map<String, dynamic> toJson() {
    return {'tourId': tourId, 'comment': comment, 'rating': rating};
  }
}
