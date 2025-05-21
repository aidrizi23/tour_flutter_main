import 'package:flutter/material.dart';

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
    // Safely extract values with proper fallbacks
    bool parseIsAvailable() {
      try {
        if (json.containsKey('isAvailable')) {
          return json['isAvailable'] as bool;
        }
      } catch (e) {
        // If parsing fails, check if there's a string representation to parse
        final availableStr = json['isAvailable']?.toString().toLowerCase();
        if (availableStr == 'true') return true;
        if (availableStr == 'false') return false;
      }
      return false; // Default to false if missing or unparseable
    }

    double parseTotalPrice() {
      try {
        if (json.containsKey('totalPrice')) {
          return (json['totalPrice'] as num).toDouble();
        }
      } catch (e) {
        // Try parsing as string if number conversion fails
        try {
          final priceStr = json['totalPrice']?.toString();
          if (priceStr != null) return double.tryParse(priceStr) ?? 0.0;
        } catch (_) {}
      }
      return 0.0; // Default to 0.0 if missing or unparseable
    }

    int parseTotalDays() {
      try {
        if (json.containsKey('totalDays')) {
          return (json['totalDays'] as num).toInt();
        }
      } catch (e) {
        // Try parsing as string if number conversion fails
        try {
          final daysStr = json['totalDays']?.toString();
          if (daysStr != null) return int.tryParse(daysStr) ?? 1;
        } catch (_) {}
      }
      return 1; // Default to 1 if missing or unparseable
    }

    return CarAvailabilityResponse(
      isAvailable: parseIsAvailable(),
      totalPrice: parseTotalPrice(),
      totalDays: parseTotalDays(),
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
      isAvailable
          ? 'Available for the selected dates'
          : 'Not available for selected dates';

  Color get statusColor => isAvailable ? Colors.green : Colors.red;

  // Create a copy with modified values
  CarAvailabilityResponse copyWith({
    bool? isAvailable,
    double? totalPrice,
    int? totalDays,
  }) {
    return CarAvailabilityResponse(
      isAvailable: isAvailable ?? this.isAvailable,
      totalPrice: totalPrice ?? this.totalPrice,
      totalDays: totalDays ?? this.totalDays,
    );
  }

  // Additional helper methods for validation
  bool get isPriceValid => totalPrice > 0;
  bool get isDurationValid => totalDays > 0;

  // Formatted price per day for display
  String get formattedDailyPrice {
    if (totalDays <= 0) return formattedPrice;
    final dailyPrice = totalPrice / totalDays;
    return '\$${dailyPrice.toStringAsFixed(2)}';
  }
}
