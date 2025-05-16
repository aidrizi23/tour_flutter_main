class CreateCarRequest {
  final String make;
  final String model;
  final int year;
  final String description;
  final double dailyRate;
  final String category;
  final String transmission;
  final String fuelType;
  final int seats;
  final String location;
  final String? mainImageUrl;
  final List<CreateCarFeature> features;
  final List<CreateCarImage> images;

  CreateCarRequest({
    required this.make,
    required this.model,
    required this.year,
    required this.description,
    required this.dailyRate,
    required this.category,
    required this.transmission,
    required this.fuelType,
    required this.seats,
    required this.location,
    this.mainImageUrl,
    this.features = const [],
    this.images = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'description': description,
      'dailyRate': dailyRate,
      'category': category,
      'transmission': transmission,
      'fuelType': fuelType,
      'seats': seats,
      'location': location,
      'mainImageUrl': mainImageUrl,
      'features': features.map((e) => e.toJson()).toList(),
      'images': images.map((e) => e.toJson()).toList(),
    };
  }
}

class CreateCarFeature {
  final String name;
  final String? description;

  CreateCarFeature({required this.name, this.description});

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }
}

class CreateCarImage {
  final String imageUrl;
  final String? caption;
  final int displayOrder;

  CreateCarImage({
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
