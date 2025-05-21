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
      bookingDate: DateTime.parse(json['bookingDate'] as String).toLocal(),
      rentalStartDate:
          DateTime.parse(json['rentalStartDate'] as String).toLocal(),
      rentalEndDate: DateTime.parse(json['rentalEndDate'] as String).toLocal(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      paymentStatus: json['paymentStatus'] as String,
      paymentDate:
          json['paymentDate'] != null
              ? DateTime.parse(json['paymentDate'] as String).toLocal()
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
      'bookingDate': bookingDate.toUtc().toIso8601String(),
      'rentalStartDate': rentalStartDate.toUtc().toIso8601String(),
      'rentalEndDate': rentalEndDate.toUtc().toIso8601String(),
      'totalAmount': totalAmount,
      'status': status,
      'notes': notes,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'paymentDate': paymentDate?.toUtc().toIso8601String(),
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
      case 'declined':
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
      'rentalStartDate': rentalStartDate.toUtc().toIso8601String(),
      'rentalEndDate': rentalEndDate.toUtc().toIso8601String(),
      'notes': notes,
    };
  }
}

class QuickBookingDto {
  final int carId;
  final DateTime rentalStartDate;
  final DateTime rentalEndDate;
  final String? notes;
  final bool initiatePaymentImmediately;

  QuickBookingDto({
    required this.carId,
    required this.rentalStartDate,
    required this.rentalEndDate,
    this.notes,
    this.initiatePaymentImmediately = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'carId': carId,
      'rentalStartDate': rentalStartDate.toUtc().toIso8601String(),
      'rentalEndDate': rentalEndDate.toUtc().toIso8601String(),
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
    // Handle potential missing date fields with fallbacks
    DateTime parseDate(String key, {DateTime? defaultValue}) {
      try {
        if (json[key] != null) {
          return DateTime.parse(json[key] as String).toLocal();
        }
      } catch (e) {
        print('Error parsing date for key $key: $e');
      }
      return defaultValue ?? DateTime.now();
    }

    // Use safe parsing for numeric values
    double parseDouble(String key, {double defaultValue = 0.0}) {
      try {
        if (json[key] != null) {
          return (json[key] as num).toDouble();
        }
      } catch (e) {
        print('Error parsing double for key $key: $e');
      }
      return defaultValue;
    }

    int parseInt(String key, {int defaultValue = 0}) {
      try {
        if (json[key] != null) {
          return (json[key] as num).toInt();
        }
      } catch (e) {
        print('Error parsing int for key $key: $e');
      }
      return defaultValue;
    }

    // Use now + 1 day as default rental end date if missing
    final startDate = parseDate(
      'rentalStartDate',
      defaultValue: DateTime.now(),
    );
    final endDate = parseDate(
      'rentalEndDate',
      defaultValue: startDate.add(const Duration(days: 1)),
    );

    // Calculate total days if missing
    int totalDays = parseInt('totalDays');
    if (totalDays <= 0) {
      totalDays = endDate.difference(startDate).inDays;
      if (totalDays <= 0) totalDays = 1; // Ensure minimum of 1 day
    }

    return CarPaymentInfo(
      bookingId: parseInt('bookingId'),
      carId: parseInt('carId'),
      carName: json['carName'] as String? ?? 'Car Rental',
      carImageUrl: json['carImageUrl'] as String?,
      rentalStartDate: startDate,
      rentalEndDate: endDate,
      totalDays: totalDays,
      dailyRate: parseDouble('dailyRate'),
      totalAmount: parseDouble('totalAmount'),
      paymentStatus: json['paymentStatus'] as String? ?? 'Pending',
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
      'rentalStartDate': rentalStartDate.toUtc().toIso8601String(),
      'rentalEndDate': rentalEndDate.toUtc().toIso8601String(),
      'totalDays': totalDays,
      'dailyRate': dailyRate,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'clientSecret': clientSecret,
    };
  }

  // Helper getters with improved fallbacks
  String get formattedTotalAmount => '\$${totalAmount.toStringAsFixed(2)}';
  String get formattedDailyRate => '\$${dailyRate.toStringAsFixed(2)}';
  String get rentalPeriod => _formatDateRange(rentalStartDate, rentalEndDate);

  // Format date range in a user-friendly way
  String _formatDateRange(DateTime start, DateTime end) {
    final startMonth = _getMonthName(start.month);
    final endMonth = _getMonthName(end.month);

    if (start.year == end.year) {
      if (start.month == end.month) {
        return '${start.day} - ${end.day} $endMonth ${end.year}';
      } else {
        return '${start.day} $startMonth - ${end.day} $endMonth ${end.year}';
      }
    } else {
      return '${start.day} $startMonth ${start.year} - ${end.day} $endMonth ${end.year}';
    }
  }

  // Helper to get month name from month number
  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
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
      data['rentalStartDate'] = rentalStartDate!.toUtc().toIso8601String();
    }
    if (rentalEndDate != null) {
      data['rentalEndDate'] = rentalEndDate!.toUtc().toIso8601String();
    }
    if (notes != null) {
      data['notes'] = notes;
    }

    return data;
  }
}

// CarAvailabilityResponse is now defined in lib/models/car_availability_response.dart
