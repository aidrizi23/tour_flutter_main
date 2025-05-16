class CreateTourRequest {
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
  final List<CreateTourImage> images;
  final List<CreateTourFeature> features;
  final List<CreateItineraryItem> itineraryItems;

  CreateTourRequest({
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
    this.images = const [],
    this.features = const [],
    this.itineraryItems = const [],
  });

  Map<String, dynamic> toJson() {
    return {
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
      'images': images.map((e) => e.toJson()).toList(),
      'features': features.map((e) => e.toJson()).toList(),
      'itineraryItems': itineraryItems.map((e) => e.toJson()).toList(),
    };
  }
}

class CreateTourImage {
  final String imageUrl;
  final String? caption;
  final int displayOrder;

  CreateTourImage({
    required this.imageUrl,
    this.caption,
    required this.displayOrder,
  });

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'caption': caption,
      'displayOrder': displayOrder,
    };
  }
}

class CreateTourFeature {
  final String name;
  final String? description;

  CreateTourFeature({required this.name, this.description});

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }
}

class CreateItineraryItem {
  final int dayNumber;
  final String title;
  final String description;
  final String? location;
  final String? startTime;
  final String? endTime;
  final String? activityType;

  CreateItineraryItem({
    required this.dayNumber,
    required this.title,
    required this.description,
    this.location,
    this.startTime,
    this.endTime,
    this.activityType,
  });

  Map<String, dynamic> toJson() {
    return {
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
