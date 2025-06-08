import 'dart:convert';
import 'dart:developer';
import '../models/models.dart';
import '../models/create_tour_models.dart';
import '../utils/api_client.dart';

class AdminService {
  final ApiClient _apiClient = ApiClient();

  // ========== TOUR MANAGEMENT ==========
  
  Future<Tour> createTour(CreateTourRequest request) async {
    try {
      log('Creating new tour: ${request.name}');
      
      final response = await _apiClient.post(
        '/admin/tours',
        data: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        final tour = Tour.fromJson(data);
        log('Tour created successfully: ${tour.id}');
        return tour;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create tour');
      }
    } catch (e) {
      log('Error creating tour: $e');
      rethrow;
    }
  }

  Future<Tour> updateTour(int tourId, CreateTourRequest request) async {
    try {
      log('Updating tour: $tourId');
      
      final response = await _apiClient.put(
        '/admin/tours/$tourId',
        data: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tour = Tour.fromJson(data);
        log('Tour updated successfully: ${tour.id}');
        return tour;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update tour');
      }
    } catch (e) {
      log('Error updating tour: $e');
      rethrow;
    }
  }

  Future<void> deleteTour(int tourId) async {
    try {
      log('Deleting tour: $tourId');
      
      final response = await _apiClient.delete(
        '/admin/tours/$tourId',
        requiresAuth: true,
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        log('Tour deleted successfully: $tourId');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete tour');
      }
    } catch (e) {
      log('Error deleting tour: $e');
      rethrow;
    }
  }

  // ========== HOUSE MANAGEMENT ==========
  
  Future<House> createHouse(CreateHouseRequest request) async {
    try {
      log('Creating new house: ${request.name}');
      
      final response = await _apiClient.post(
        '/admin/houses',
        data: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        final house = House.fromJson(data);
        log('House created successfully: ${house.id}');
        return house;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create house');
      }
    } catch (e) {
      log('Error creating house: $e');
      rethrow;
    }
  }

  Future<House> updateHouse(int houseId, CreateHouseRequest request) async {
    try {
      log('Updating house: $houseId');
      
      final response = await _apiClient.put(
        '/admin/houses/$houseId',
        data: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final house = House.fromJson(data);
        log('House updated successfully: ${house.id}');
        return house;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update house');
      }
    } catch (e) {
      log('Error updating house: $e');
      rethrow;
    }
  }

  Future<void> deleteHouse(int houseId) async {
    try {
      log('Deleting house: $houseId');
      
      final response = await _apiClient.delete(
        '/admin/houses/$houseId',
        requiresAuth: true,
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        log('House deleted successfully: $houseId');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete house');
      }
    } catch (e) {
      log('Error deleting house: $e');
      rethrow;
    }
  }

  // ========== CAR MANAGEMENT ==========
  
  Future<Car> createCar(CreateCarRequest request) async {
    try {
      log('Creating new car: ${request.make} ${request.model}');
      
      final response = await _apiClient.post(
        '/admin/cars',
        data: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        final car = Car.fromJson(data);
        log('Car created successfully: ${car.id}');
        return car;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create car');
      }
    } catch (e) {
      log('Error creating car: $e');
      rethrow;
    }
  }

  Future<Car> updateCar(int carId, CreateCarRequest request) async {
    try {
      log('Updating car: $carId');
      
      final response = await _apiClient.put(
        '/admin/cars/$carId',
        data: request.toJson(),
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final car = Car.fromJson(data);
        log('Car updated successfully: ${car.id}');
        return car;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update car');
      }
    } catch (e) {
      log('Error updating car: $e');
      rethrow;
    }
  }

  Future<void> deleteCar(int carId) async {
    try {
      log('Deleting car: $carId');
      
      final response = await _apiClient.delete(
        '/admin/cars/$carId',
        requiresAuth: true,
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        log('Car deleted successfully: $carId');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete car');
      }
    } catch (e) {
      log('Error deleting car: $e');
      rethrow;
    }
  }

  // ========== DASHBOARD ANALYTICS ==========
  
  Future<AdminDashboardStats> getDashboardStats() async {
    try {
      log('Fetching admin dashboard stats');
      
      final response = await _apiClient.get(
        '/admin/dashboard/stats',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final stats = AdminDashboardStats.fromJson(data);
        log('Dashboard stats fetched successfully');
        return stats;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch dashboard stats');
      }
    } catch (e) {
      log('Error fetching dashboard stats: $e');
      rethrow;
    }
  }

  Future<List<RecentBooking>> getRecentBookings({int limit = 10}) async {
    try {
      log('Fetching recent bookings');
      
      final response = await _apiClient.get(
        '/admin/bookings/recent',
        queryParams: {'limit': limit.toString()},
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final bookings = data.map((item) => RecentBooking.fromJson(item)).toList();
        log('Recent bookings fetched successfully: ${bookings.length}');
        return bookings;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch recent bookings');
      }
    } catch (e) {
      log('Error fetching recent bookings: $e');
      rethrow;
    }
  }

  Future<List<UserSummary>> getTopUsers({int limit = 5}) async {
    try {
      log('Fetching top users');
      
      final response = await _apiClient.get(
        '/admin/users/top',
        queryParams: {'limit': limit.toString()},
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final users = data.map((item) => UserSummary.fromJson(item)).toList();
        log('Top users fetched successfully: ${users.length}');
        return users;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch top users');
      }
    } catch (e) {
      log('Error fetching top users: $e');
      rethrow;
    }
  }

  Future<List<RevenueData>> getRevenueData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      log('Fetching revenue data');
      
      final response = await _apiClient.get(
        '/admin/analytics/revenue',
        queryParams: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final revenueData = data.map((item) => RevenueData.fromJson(item)).toList();
        log('Revenue data fetched successfully: ${revenueData.length} data points');
        return revenueData;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch revenue data');
      }
    } catch (e) {
      log('Error fetching revenue data: $e');
      rethrow;
    }
  }

}

// ========== ADMIN DATA MODELS ==========

class AdminDashboardStats {
  final int totalTours;
  final int totalHouses;
  final int totalCars;
  final int totalUsers;
  final int totalBookings;
  final double totalRevenue;
  final double monthlyRevenue;
  final double averageRating;
  final int pendingBookings;
  final int confirmedBookings;
  final int recentSignups;
  final String popularDestination;

  AdminDashboardStats({
    required this.totalTours,
    required this.totalHouses,
    required this.totalCars,
    required this.totalUsers,
    required this.totalBookings,
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.averageRating,
    required this.pendingBookings,
    required this.confirmedBookings,
    required this.recentSignups,
    required this.popularDestination,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      totalTours: json['totalTours'] as int,
      totalHouses: json['totalHouses'] as int,
      totalCars: json['totalCars'] as int,
      totalUsers: json['totalUsers'] as int,
      totalBookings: json['totalBookings'] as int,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      monthlyRevenue: (json['monthlyRevenue'] as num).toDouble(),
      averageRating: (json['averageRating'] as num).toDouble(),
      pendingBookings: json['pendingBookings'] as int,
      confirmedBookings: json['confirmedBookings'] as int,
      recentSignups: json['recentSignups'] as int,
      popularDestination: json['popularDestination'] as String,
    );
  }
}

class RecentBooking {
  final int id;
  final String type;
  final String customerName;
  final String itemName;
  final double amount;
  final String status;
  final DateTime bookingDate;

  RecentBooking({
    required this.id,
    required this.type,
    required this.customerName,
    required this.itemName,
    required this.amount,
    required this.status,
    required this.bookingDate,
  });

  factory RecentBooking.fromJson(Map<String, dynamic> json) {
    return RecentBooking(
      id: json['id'] as int,
      type: json['type'] as String,
      customerName: json['customerName'] as String,
      itemName: json['itemName'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      bookingDate: DateTime.parse(json['bookingDate'] as String),
    );
  }
}

class UserSummary {
  final String id;
  final String name;
  final String email;
  final int totalBookings;
  final double totalSpent;
  final double averageRating;
  final DateTime joinDate;

  UserSummary({
    required this.id,
    required this.name,
    required this.email,
    required this.totalBookings,
    required this.totalSpent,
    required this.averageRating,
    required this.joinDate,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      totalBookings: json['totalBookings'] as int,
      totalSpent: (json['totalSpent'] as num).toDouble(),
      averageRating: (json['averageRating'] as num).toDouble(),
      joinDate: DateTime.parse(json['joinDate'] as String),
    );
  }
}

class RevenueData {
  final DateTime date;
  final double amount;
  final int bookingCount;

  RevenueData({
    required this.date,
    required this.amount,
    required this.bookingCount,
  });

  factory RevenueData.fromJson(Map<String, dynamic> json) {
    return RevenueData(
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      bookingCount: json['bookingCount'] as int,
    );
  }
}

// ========== CREATE REQUEST MODELS ==========

class CreateHouseRequest {
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
  final List<CreateHouseFeatureRequest> features;
  final List<CreateHouseImageRequest> images;

  CreateHouseRequest({
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
    this.isActive = true,
    this.isAvailable = true,
    this.features = const [],
    this.images = const [],
  });

  Map<String, dynamic> toJson() {
    return {
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
      'features': features.map((f) => f.toJson()).toList(),
      'images': images.map((i) => i.toJson()).toList(),
    };
  }
}

class CreateHouseFeatureRequest {
  final String name;
  final String? description;

  CreateHouseFeatureRequest({required this.name, this.description});

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }
}

class CreateHouseImageRequest {
  final String imageUrl;
  final String? caption;
  final int displayOrder;

  CreateHouseImageRequest({
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