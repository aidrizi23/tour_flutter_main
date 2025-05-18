import 'package:flutter/material.dart';

class HouseImage {
  final int id;
  final String imageUrl;
  final String? caption;
  final int displayOrder;

  HouseImage({
    required this.id,
    required this.imageUrl,
    this.caption,
    required this.displayOrder,
  });

  factory HouseImage.fromJson(Map<String, dynamic> json) {
    return HouseImage(
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

class HouseFeature {
  final int id;
  final String name;
  final String? description;

  HouseFeature({required this.id, required this.name, this.description});

  factory HouseFeature.fromJson(Map<String, dynamic> json) {
    return HouseFeature(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }
}

class House {
  final int id;
  final String name;
  final String description;
  final double nightlyRate;
  final String address;
  final String city;
  final String state;
  final String country;
  final String propertyType;
  final int bedrooms;
  final int bathrooms;
  final int maxGuests;
  final double? cleaningFee;
  final String? mainImageUrl;
  final bool isActive;
  final bool isAvailable;
  final DateTime createdAt;
  final List<HouseImage> images;
  final List<HouseFeature> features;
  final double? averageRating;
  final int? reviewCount;

  House({
    required this.id,
    required this.name,
    required this.description,
    required this.nightlyRate,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.propertyType,
    required this.bedrooms,
    required this.bathrooms,
    required this.maxGuests,
    this.cleaningFee,
    this.mainImageUrl,
    required this.isActive,
    required this.isAvailable,
    required this.createdAt,
    required this.images,
    required this.features,
    this.averageRating,
    this.reviewCount,
  });

  factory House.fromJson(Map<String, dynamic> json) {
    return House(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      nightlyRate: (json['nightlyRate'] as num).toDouble(),
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
      propertyType: json['propertyType'] as String,
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      maxGuests: json['maxGuests'] as int,
      cleaningFee: (json['cleaningFee'] as num?)?.toDouble(),
      mainImageUrl: json['mainImageUrl'] as String?,
      isActive: json['isActive'] as bool,
      isAvailable: json['isAvailable'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => HouseImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      features:
          (json['features'] as List<dynamic>?)
              ?.map((e) => HouseFeature.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'nightlyRate': nightlyRate,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'propertyType': propertyType,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'maxGuests': maxGuests,
      'cleaningFee': cleaningFee,
      'mainImageUrl': mainImageUrl,
      'isActive': isActive,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'images': images.map((e) => e.toJson()).toList(),
      'features': features.map((e) => e.toJson()).toList(),
      'averageRating': averageRating,
      'reviewCount': reviewCount,
    };
  }

  // Helper getters
  String get displayPrice => '\$${nightlyRate.toStringAsFixed(2)}/night';
  String get displayLocation => '$city, $country';
  String get displayRooms => '$bedrooms bed · $bathrooms bath';
  double get totalCleaningFee => cleaningFee ?? 0.0;

  String get propertyTypeIcon {
    switch (propertyType.toLowerCase()) {
      case 'house':
        return '🏠';
      case 'apartment':
        return '🏢';
      case 'villa':
        return '🏛️';
      case 'cottage':
        return '🏡';
      default:
        return '🏠';
    }
  }

  Color get propertyTypeColor {
    switch (propertyType.toLowerCase()) {
      case 'house':
        return Colors.blue;
      case 'apartment':
        return Colors.purple;
      case 'villa':
        return Colors.indigo;
      case 'cottage':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData get propertyTypeIconData {
    switch (propertyType.toLowerCase()) {
      case 'house':
        return Icons.house;
      case 'apartment':
        return Icons.apartment;
      case 'villa':
        return Icons.villa;
      case 'cottage':
        return Icons.cottage;
      default:
        return Icons.home;
    }
  }
}

class PaginatedHouses {
  final List<House> items;
  final int pageIndex;
  final int totalPages;
  final int totalCount;
  final bool hasPreviousPage;
  final bool hasNextPage;

  PaginatedHouses({
    required this.items,
    required this.pageIndex,
    required this.totalPages,
    required this.totalCount,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory PaginatedHouses.fromJson(Map<String, dynamic> json) {
    return PaginatedHouses(
      items:
          (json['items'] as List<dynamic>)
              .map((e) => House.fromJson(e as Map<String, dynamic>))
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

class HouseFilterRequest {
  final String? searchTerm;
  final String? city;
  final String? country;
  final String? propertyType;
  final int? minBedrooms;
  final int? maxBedrooms;
  final int? minBathrooms;
  final int? maxBathrooms;
  final int? minGuests;
  final double? minPrice;
  final double? maxPrice;
  final DateTime? availableFrom;
  final DateTime? availableTo;
  final String? sortBy;
  final bool? ascending;
  final int? pageIndex;
  final int? pageSize;

  HouseFilterRequest({
    this.searchTerm,
    this.city,
    this.country,
    this.propertyType,
    this.minBedrooms,
    this.maxBedrooms,
    this.minBathrooms,
    this.maxBathrooms,
    this.minGuests,
    this.minPrice,
    this.maxPrice,
    this.availableFrom,
    this.availableTo,
    this.sortBy,
    this.ascending,
    this.pageIndex,
    this.pageSize,
  });

  Map<String, String> toQueryParams() {
    final Map<String, String> params = {};

    if (searchTerm != null && searchTerm!.isNotEmpty) {
      params['searchTerm'] = searchTerm!;
    }
    if (city != null && city!.isNotEmpty) params['city'] = city!;
    if (country != null && country!.isNotEmpty) params['country'] = country!;
    if (propertyType != null && propertyType!.isNotEmpty) {
      params['propertyType'] = propertyType!;
    }
    if (minBedrooms != null) params['minBedrooms'] = minBedrooms.toString();
    if (maxBedrooms != null) params['maxBedrooms'] = maxBedrooms.toString();
    if (minBathrooms != null) params['minBathrooms'] = minBathrooms.toString();
    if (maxBathrooms != null) params['maxBathrooms'] = maxBathrooms.toString();
    if (minGuests != null) params['minGuests'] = minGuests.toString();
    if (minPrice != null) params['minPrice'] = minPrice.toString();
    if (maxPrice != null) params['maxPrice'] = maxPrice.toString();
    if (availableFrom != null) {
      params['availableFrom'] = availableFrom!.toIso8601String();
    }
    if (availableTo != null) {
      params['availableTo'] = availableTo!.toIso8601String();
    }
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
    if (city != null && city!.isNotEmpty) data['city'] = city!;
    if (country != null && country!.isNotEmpty) data['country'] = country!;
    if (propertyType != null && propertyType!.isNotEmpty) {
      data['propertyType'] = propertyType!;
    }
    if (minBedrooms != null) data['minBedrooms'] = minBedrooms!;
    if (maxBedrooms != null) data['maxBedrooms'] = maxBedrooms!;
    if (minBathrooms != null) data['minBathrooms'] = minBathrooms!;
    if (maxBathrooms != null) data['maxBathrooms'] = maxBathrooms!;
    if (minGuests != null) data['minGuests'] = minGuests!;
    if (minPrice != null) data['minPrice'] = minPrice!;
    if (maxPrice != null) data['maxPrice'] = maxPrice!;
    if (availableFrom != null) {
      data['availableFrom'] = availableFrom!.toIso8601String();
    }
    if (availableTo != null) {
      data['availableTo'] = availableTo!.toIso8601String();
    }
    if (sortBy != null && sortBy!.isNotEmpty) data['sortBy'] = sortBy!;
    if (ascending != null) data['ascending'] = ascending!;
    if (pageIndex != null) data['pageIndex'] = pageIndex!;
    if (pageSize != null) data['pageSize'] = pageSize!;

    return data;
  }
}

class HouseReview {
  final int id;
  final String comment;
  final int rating;
  final DateTime createdAt;
  final String userName;

  HouseReview({
    required this.id,
    required this.comment,
    required this.rating,
    required this.createdAt,
    required this.userName,
  });

  factory HouseReview.fromJson(Map<String, dynamic> json) {
    return HouseReview(
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

class AddHouseReviewRequest {
  final int houseId;
  final String comment;
  final int rating;

  AddHouseReviewRequest({
    required this.houseId,
    required this.comment,
    required this.rating,
  });

  Map<String, dynamic> toJson() {
    return {'houseId': houseId, 'comment': comment, 'rating': rating};
  }
}

class CheckHouseAvailabilityRequest {
  final int houseId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guestCount;

  CheckHouseAvailabilityRequest({
    required this.houseId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guestCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'houseId': houseId,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'guestCount': guestCount,
    };
  }
}

class HouseAvailabilityResponse {
  final bool isAvailable;
  final double totalPrice;
  final double nightlyRate;
  final double? cleaningFee;
  final int nights;
  final int availableRooms;

  HouseAvailabilityResponse({
    required this.isAvailable,
    required this.totalPrice,
    required this.nightlyRate,
    this.cleaningFee,
    required this.nights,
    required this.availableRooms,
  });

  factory HouseAvailabilityResponse.fromJson(Map<String, dynamic> json) {
    return HouseAvailabilityResponse(
      isAvailable: json['isAvailable'] as bool,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      nightlyRate: (json['nightlyRate'] as num).toDouble(),
      cleaningFee: (json['cleaningFee'] as num?)?.toDouble(),
      nights: json['nights'] as int,
      availableRooms: json['availableRooms'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isAvailable': isAvailable,
      'totalPrice': totalPrice,
      'nightlyRate': nightlyRate,
      'cleaningFee': cleaningFee,
      'nights': nights,
      'availableRooms': availableRooms,
    };
  }

  String get formattedTotalPrice => '\$${totalPrice.toStringAsFixed(2)}';
  String get formattedNightlyRate =>
      '\$${nightlyRate.toStringAsFixed(2)}/night';
  String get formattedCleaningFee =>
      cleaningFee != null ? '\$${cleaningFee!.toStringAsFixed(2)}' : 'N/A';
  String get formattedNights => '$nights ${nights == 1 ? 'night' : 'nights'}';
}

class CreateHouseBookingRequest {
  final int houseId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guestCount;
  final String? notes;
  final String? discountCode;

  CreateHouseBookingRequest({
    required this.houseId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guestCount,
    this.notes,
    this.discountCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'houseId': houseId,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'guestCount': guestCount,
      'notes': notes,
      'discountCode': discountCode,
    };
  }
}

class HouseBooking {
  final int id;
  final int houseId;
  final String houseName;
  final String? mainImageUrl;
  final String? city;
  final String? country;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guestCount;
  final DateTime bookingDate;
  final double totalAmount;
  final String status;
  final String? notes;
  final String? paymentMethod;
  final String paymentStatus;
  final DateTime? paymentDate;
  final String? transactionId;
  final String? discountCode;

  HouseBooking({
    required this.id,
    required this.houseId,
    required this.houseName,
    this.mainImageUrl,
    this.city,
    this.country,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guestCount,
    required this.bookingDate,
    required this.totalAmount,
    required this.status,
    this.notes,
    this.paymentMethod,
    required this.paymentStatus,
    this.paymentDate,
    this.transactionId,
    this.discountCode,
  });

  factory HouseBooking.fromJson(Map<String, dynamic> json) {
    return HouseBooking(
      id: json['id'] as int,
      houseId: json['houseId'] as int,
      houseName: json['houseName'] as String,
      mainImageUrl: json['mainImageUrl'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      checkInDate: DateTime.parse(json['checkInDate'] as String),
      checkOutDate: DateTime.parse(json['checkOutDate'] as String),
      guestCount: json['guestCount'] as int,
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      paymentStatus: json['paymentStatus'] as String,
      paymentDate:
          json['paymentDate'] != null
              ? DateTime.parse(json['paymentDate'] as String)
              : null,
      transactionId: json['transactionId'] as String?,
      discountCode: json['discountCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'houseId': houseId,
      'houseName': houseName,
      'mainImageUrl': mainImageUrl,
      'city': city,
      'country': country,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'guestCount': guestCount,
      'bookingDate': bookingDate.toIso8601String(),
      'totalAmount': totalAmount,
      'status': status,
      'notes': notes,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'paymentDate': paymentDate?.toIso8601String(),
      'transactionId': transactionId,
      'discountCode': discountCode,
    };
  }

  // Helper getters
  String get location =>
      (city != null && country != null) ? '$city, $country' : '';

  String get displayTotalAmount => '\$${totalAmount.toStringAsFixed(2)}';

  int get stayDuration => checkOutDate.difference(checkInDate).inDays;

  String get displayDuration =>
      '$stayDuration ${stayDuration == 1 ? 'night' : 'nights'}';

  String get displayDates =>
      '${checkInDate.day}/${checkInDate.month}/${checkInDate.year} - '
      '${checkOutDate.day}/${checkOutDate.month}/${checkOutDate.year}';

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Color get paymentStatusColor {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'unpaid':
        return Colors.red;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
