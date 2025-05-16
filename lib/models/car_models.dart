import 'package:flutter/material.dart';

class CarImage {
  final int id;
  final String imageUrl;
  final String? caption;
  final int displayOrder;

  CarImage({
    required this.id,
    required this.imageUrl,
    this.caption,
    required this.displayOrder,
  });

  factory CarImage.fromJson(Map<String, dynamic> json) {
    return CarImage(
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

class CarFeature {
  final int id;
  final String name;
  final String? description;

  CarFeature({required this.id, required this.name, this.description});

  factory CarFeature.fromJson(Map<String, dynamic> json) {
    return CarFeature(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }
}

class Car {
  final int id;
  final String make;
  final String model;
  final int year;
  final String description;
  final double dailyRate;
  final String category;
  final String transmission;
  final String fuelType;
  final int seats;
  final String? mainImageUrl;
  final bool isAvailable;
  final String location;
  final DateTime createdAt;
  final List<CarImage> images;
  final List<CarFeature> features;
  final double? averageRating;
  final int? reviewCount;

  Car({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.description,
    required this.dailyRate,
    required this.category,
    required this.transmission,
    required this.fuelType,
    required this.seats,
    this.mainImageUrl,
    required this.isAvailable,
    required this.location,
    required this.createdAt,
    required this.images,
    required this.features,
    this.averageRating,
    this.reviewCount,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] as int,
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      description: json['description'] as String,
      dailyRate: (json['dailyRate'] as num).toDouble(),
      category: json['category'] as String,
      transmission: json['transmission'] as String,
      fuelType: json['fuelType'] as String,
      seats: json['seats'] as int,
      mainImageUrl: json['mainImageUrl'] as String?,
      isAvailable: json['isAvailable'] as bool,
      location: json['location'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => CarImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      features:
          (json['features'] as List<dynamic>?)
              ?.map((e) => CarFeature.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'description': description,
      'dailyRate': dailyRate,
      'category': category,
      'transmission': transmission,
      'fuelType': fuelType,
      'seats': seats,
      'mainImageUrl': mainImageUrl,
      'isAvailable': isAvailable,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'images': images.map((e) => e.toJson()).toList(),
      'features': features.map((e) => e.toJson()).toList(),
      'averageRating': averageRating,
      'reviewCount': reviewCount,
    };
  }

  // Helper getters
  String get displayPrice => '\$${dailyRate.toStringAsFixed(2)}';
  String get displayName => '$make $model ($year)';

  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'economy':
        return const Color(0xFF4CAF50);
      case 'compact':
        return const Color(0xFF2196F3);
      case 'suv':
        return const Color(0xFFFF9800);
      case 'luxury':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF757575);
    }
  }

  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'economy':
        return Icons.directions_car;
      case 'compact':
        return Icons.directions_car;
      case 'suv':
      case 'suv-8':
        return Icons.directions_car_filled;
      case 'luxury':
        return Icons.directions_car_rounded;
      default:
        return Icons.directions_car;
    }
  }

  IconData get transmissionIcon {
    switch (transmission.toLowerCase()) {
      case 'automatic':
        return Icons.cached;
      case 'manual':
        return Icons.agriculture;
      default:
        return Icons.settings;
    }
  }

  IconData get fuelIcon {
    switch (fuelType.toLowerCase()) {
      case 'petrol':
      case 'gasoline':
        return Icons.local_gas_station;
      case 'diesel':
        return Icons.local_gas_station_outlined;
      case 'electric':
        return Icons.electric_car;
      case 'hybrid':
        return Icons.battery_charging_full;
      default:
        return Icons.local_gas_station;
    }
  }
}

class PaginatedCars {
  final List<Car> items;
  final int pageIndex;
  final int totalPages;
  final int totalCount;
  final bool hasPreviousPage;
  final bool hasNextPage;

  PaginatedCars({
    required this.items,
    required this.pageIndex,
    required this.totalPages,
    required this.totalCount,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory PaginatedCars.fromJson(Map<String, dynamic> json) {
    return PaginatedCars(
      items:
          (json['items'] as List<dynamic>)
              .map((e) => Car.fromJson(e as Map<String, dynamic>))
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

// Filter classes for car search
class CarFilterRequest {
  final String? searchTerm;
  final String? make;
  final String? model;
  final int? minYear;
  final int? maxYear;
  final String? category;
  final String? transmission;
  final String? fuelType;
  final int? minSeats;
  final int? maxSeats;
  final double? minDailyRate;
  final double? maxDailyRate;
  final String? location;
  final bool? isAvailable;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? sortBy;
  final bool? ascending;
  final int? pageIndex;
  final int? pageSize;
  final List<String>? requiredFeatures;

  CarFilterRequest({
    this.searchTerm,
    this.make,
    this.model,
    this.minYear,
    this.maxYear,
    this.category,
    this.transmission,
    this.fuelType,
    this.minSeats,
    this.maxSeats,
    this.minDailyRate,
    this.maxDailyRate,
    this.location,
    this.isAvailable,
    this.startDate,
    this.endDate,
    this.sortBy,
    this.ascending,
    this.pageIndex,
    this.pageSize,
    this.requiredFeatures,
  });

  Map<String, String> toQueryParams() {
    final Map<String, String> params = {};

    if (searchTerm != null && searchTerm!.isNotEmpty) {
      params['searchTerm'] = searchTerm!;
    }
    if (make != null && make!.isNotEmpty) params['make'] = make!;
    if (model != null && model!.isNotEmpty) params['model'] = model!;
    if (minYear != null) params['minYear'] = minYear.toString();
    if (maxYear != null) params['maxYear'] = maxYear.toString();
    if (category != null && category!.isNotEmpty) {
      params['category'] = category!;
    }
    if (transmission != null && transmission!.isNotEmpty) {
      params['transmission'] = transmission!;
    }
    if (fuelType != null && fuelType!.isNotEmpty) {
      params['fuelType'] = fuelType!;
    }
    if (minSeats != null) params['minSeats'] = minSeats.toString();
    if (maxSeats != null) params['maxSeats'] = maxSeats.toString();
    if (minDailyRate != null) params['minDailyRate'] = minDailyRate.toString();
    if (maxDailyRate != null) params['maxDailyRate'] = maxDailyRate.toString();
    if (location != null && location!.isNotEmpty) {
      params['location'] = location!;
    }
    if (isAvailable != null) params['isAvailable'] = isAvailable.toString();
    if (startDate != null) params['startDate'] = startDate!.toIso8601String();
    if (endDate != null) params['endDate'] = endDate!.toIso8601String();
    if (sortBy != null && sortBy!.isNotEmpty) params['sortBy'] = sortBy!;
    if (ascending != null) params['ascending'] = ascending.toString();
    if (pageIndex != null) params['pageIndex'] = pageIndex.toString();
    if (pageSize != null) params['pageSize'] = pageSize.toString();

    return params;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (searchTerm != null && searchTerm!.isNotEmpty) {
      data['searchTerm'] = searchTerm!;
    }
    if (make != null && make!.isNotEmpty) data['make'] = make!;
    if (model != null && model!.isNotEmpty) data['model'] = model!;
    if (minYear != null) data['minYear'] = minYear!;
    if (maxYear != null) data['maxYear'] = maxYear!;
    if (category != null && category!.isNotEmpty) data['category'] = category!;
    if (transmission != null && transmission!.isNotEmpty) {
      data['transmission'] = transmission!;
    }
    if (fuelType != null && fuelType!.isNotEmpty) data['fuelType'] = fuelType!;
    if (minSeats != null) data['minSeats'] = minSeats!;
    if (maxSeats != null) data['maxSeats'] = maxSeats!;
    if (minDailyRate != null) data['minDailyRate'] = minDailyRate!;
    if (maxDailyRate != null) data['maxDailyRate'] = maxDailyRate!;
    if (location != null && location!.isNotEmpty) data['location'] = location!;
    if (isAvailable != null) data['isAvailable'] = isAvailable!;
    if (startDate != null) data['startDate'] = startDate!.toIso8601String();
    if (endDate != null) data['endDate'] = endDate!.toIso8601String();
    if (sortBy != null && sortBy!.isNotEmpty) data['sortBy'] = sortBy!;
    if (ascending != null) data['ascending'] = ascending!;
    if (pageIndex != null) data['pageIndex'] = pageIndex!;
    if (pageSize != null) data['pageSize'] = pageSize!;
    if (requiredFeatures != null && requiredFeatures!.isNotEmpty) {
      data['requiredFeatures'] = requiredFeatures!;
    }

    return data;
  }
}

// Review models
class CarReview {
  final int id;
  final String comment;
  final int rating;
  final DateTime createdAt;
  final String userName;

  CarReview({
    required this.id,
    required this.comment,
    required this.rating,
    required this.createdAt,
    required this.userName,
  });

  factory CarReview.fromJson(Map<String, dynamic> json) {
    return CarReview(
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

class AddCarReviewRequest {
  final int carId;
  final String comment;
  final int rating;

  AddCarReviewRequest({
    required this.carId,
    required this.comment,
    required this.rating,
  });

  Map<String, dynamic> toJson() {
    return {'carId': carId, 'comment': comment, 'rating': rating};
  }
}

// Availability models
class CarAvailabilityRequest {
  final int carId;
  final DateTime startDate;
  final DateTime endDate;

  CarAvailabilityRequest({
    required this.carId,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'carId': carId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}

class CarAvailabilityResponse {
  final bool isAvailable;
  final double totalPrice;
  final int totalDays;

  CarAvailabilityResponse({
    required this.isAvailable,
    required this.totalPrice,
    required this.totalDays,
  });

  factory CarAvailabilityResponse.fromJson(Map<String, dynamic> json) {
    return CarAvailabilityResponse(
      isAvailable: json['isAvailable'] as bool,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      totalDays: json['totalDays'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isAvailable': isAvailable,
      'totalPrice': totalPrice,
      'totalDays': totalDays,
    };
  }

  // Helper getters
  String get formattedPrice => '\$${totalPrice.toStringAsFixed(2)}';
  String get formattedDuration =>
      '$totalDays ${totalDays == 1 ? 'day' : 'days'}';
  String get statusText =>
      isAvailable ? 'Available' : 'Not available for selected dates';
  Color get statusColor => isAvailable ? Colors.green : Colors.red;
}
