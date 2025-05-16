import 'package:flutter/material.dart';

class CarBooking {
  final int id;
  final int carId;
  final String carName;
  final DateTime bookingDate;
  final DateTime rentalStartDate;
  final DateTime rentalEndDate;
  final double totalAmount;
  final String status;
  final String? notes;
  final String? paymentMethod;
  final String paymentStatus;
  final DateTime? paymentDate;
  final String? transactionId;
  final CarPaymentInfo? paymentInfo;

  CarBooking({
    required this.id,
    required this.carId,
    required this.carName,
    required this.bookingDate,
    required this.rentalStartDate,
    required this.rentalEndDate,
    required this.totalAmount,
    required this.status,
    this.notes,
    this.paymentMethod,
    required this.paymentStatus,
    this.paymentDate,
    this.transactionId,
    this.paymentInfo,
  });

  factory CarBooking.fromJson(Map<String, dynamic> json) {
    return CarBooking(
      id: json['id'] as int,
      carId: json['carId'] as int,
      carName: json['carName'] as String,
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      rentalStartDate: DateTime.parse(json['rentalStartDate'] as String),
      rentalEndDate: DateTime.parse(json['rentalEndDate'] as String),
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
      paymentInfo:
          json['paymentInfo'] != null
              ? CarPaymentInfo.fromJson(
                json['paymentInfo'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carId': carId,
      'carName': carName,
      'bookingDate': bookingDate.toIso8601String(),
      'rentalStartDate': rentalStartDate.toIso8601String(),
      'rentalEndDate': rentalEndDate.toIso8601String(),
      'totalAmount': totalAmount,
      'status': status,
      'notes': notes,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'paymentDate': paymentDate?.toIso8601String(),
      'transactionId': transactionId,
      'paymentInfo': paymentInfo?.toJson(),
    };
  }

  // Helper getters
  String get formattedAmount => '\$${totalAmount.toStringAsFixed(2)}';
  int get rentalDays => rentalEndDate.difference(rentalStartDate).inDays;

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color get paymentStatusColor {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
      case 'succeeded':
        return Colors.green;
      case 'pending':
      case 'processing':
        return Colors.orange;
      case 'failed':
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
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}

class CreateCarBookingRequest {
  final int carId;
  final DateTime rentalStartDate;
  final DateTime rentalEndDate;
  final String? notes;

  CreateCarBookingRequest({
    required this.carId,
    required this.rentalStartDate,
    required this.rentalEndDate,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'carId': carId,
      'rentalStartDate': rentalStartDate.toIso8601String(),
      'rentalEndDate': rentalEndDate.toIso8601String(),
      'notes': notes,
    };
  }
}

class QuickCarBookRequest {
  final int carId;
  final DateTime rentalStartDate;
  final DateTime rentalEndDate;
  final String? notes;
  final bool initiatePaymentImmediately;

  QuickCarBookRequest({
    required this.carId,
    required this.rentalStartDate,
    required this.rentalEndDate,
    this.notes,
    this.initiatePaymentImmediately = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'carId': carId,
      'rentalStartDate': rentalStartDate.toIso8601String(),
      'rentalEndDate': rentalEndDate.toIso8601String(),
      'notes': notes,
      'initiatePaymentImmediately': initiatePaymentImmediately,
    };
  }
}

class CarPaymentInfo {
  final int bookingId;
  final int carId;
  final String carName;
  final String? carImageUrl;
  final DateTime rentalStartDate;
  final DateTime rentalEndDate;
  final int totalDays;
  final double dailyRate;
  final double totalAmount;
  final String paymentStatus;
  final String? paymentMethod;
  final String? transactionId;
  final String? clientSecret;

  CarPaymentInfo({
    required this.bookingId,
    required this.carId,
    required this.carName,
    this.carImageUrl,
    required this.rentalStartDate,
    required this.rentalEndDate,
    required this.totalDays,
    required this.dailyRate,
    required this.totalAmount,
    required this.paymentStatus,
    this.paymentMethod,
    this.transactionId,
    this.clientSecret,
  });

  factory CarPaymentInfo.fromJson(Map<String, dynamic> json) {
    return CarPaymentInfo(
      bookingId: json['bookingId'] as int,
      carId: json['carId'] as int,
      carName: json['carName'] as String,
      carImageUrl: json['carImageUrl'] as String?,
      rentalStartDate: DateTime.parse(json['rentalStartDate'] as String),
      rentalEndDate: DateTime.parse(json['rentalEndDate'] as String),
      totalDays: json['totalDays'] as int,
      dailyRate: (json['dailyRate'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paymentStatus: json['paymentStatus'] as String,
      paymentMethod: json['paymentMethod'] as String?,
      transactionId: json['transactionId'] as String?,
      clientSecret: json['clientSecret'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'carId': carId,
      'carName': carName,
      'carImageUrl': carImageUrl,
      'rentalStartDate': rentalStartDate.toIso8601String(),
      'rentalEndDate': rentalEndDate.toIso8601String(),
      'totalDays': totalDays,
      'dailyRate': dailyRate,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'clientSecret': clientSecret,
    };
  }

  // Helper getters
  String get formattedTotalAmount => '\$${totalAmount.toStringAsFixed(2)}';
  String get formattedDailyRate => '\$${dailyRate.toStringAsFixed(2)}';
  String get rentalPeriod =>
      '${rentalStartDate.day}/${rentalStartDate.month} - ${rentalEndDate.day}/${rentalEndDate.month}';
}

class UpdateCarBookingMetadataRequest {
  final DateTime? rentalStartDate;
  final DateTime? rentalEndDate;
  final String? notes;

  UpdateCarBookingMetadataRequest({
    this.rentalStartDate,
    this.rentalEndDate,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (rentalStartDate != null) {
      data['rentalStartDate'] = rentalStartDate!.toIso8601String();
    }
    if (rentalEndDate != null) {
      data['rentalEndDate'] = rentalEndDate!.toIso8601String();
    }
    if (notes != null) {
      data['notes'] = notes;
    }

    return data;
  }
}
