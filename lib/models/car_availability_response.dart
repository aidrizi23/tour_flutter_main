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
