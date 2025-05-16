import 'package:flutter/material.dart';

// Request models
class CheckAvailabilityRequest {
  final int tourId;
  final DateTime startDate;
  final int groupSize;

  CheckAvailabilityRequest({
    required this.tourId,
    required this.startDate,
    required this.groupSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'tourId': tourId,
      'startDate': startDate.toUtc().toIso8601String(),
      'groupSize': groupSize,
    };
  }
}

class QuickBookRequest {
  final int tourId;
  final int numberOfPeople;
  final DateTime tourStartDate;
  final String? notes;
  final bool initiatePaymentImmediately;
  final String? discountCode;

  QuickBookRequest({
    required this.tourId,
    required this.numberOfPeople,
    required this.tourStartDate,
    this.notes,
    this.initiatePaymentImmediately = true,
    this.discountCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'tourId': tourId,
      'numberOfPeople': numberOfPeople,
      'tourStartDate': tourStartDate.toUtc().toIso8601String(),
      'notes': notes,
      'initiatePaymentImmediately': initiatePaymentImmediately,
      'discountCode': discountCode,
    };
  }
}

// Response models
class AvailabilityResponse {
  final bool isAvailable;
  final double totalPrice;
  final int durationInDays;
  final DateTime startDate;
  final DateTime endDate;
  final int availableSpots;

  AvailabilityResponse({
    required this.isAvailable,
    required this.totalPrice,
    required this.durationInDays,
    required this.startDate,
    required this.endDate,
    required this.availableSpots,
  });

  factory AvailabilityResponse.fromJson(Map<String, dynamic> json) {
    return AvailabilityResponse(
      isAvailable: json['isAvailable'] as bool,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      durationInDays: json['durationInDays'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      availableSpots: json['availableSpots'] as int,
    );
  }

  String get formattedPrice => '\$${totalPrice.toStringAsFixed(2)}';
  String get formattedDuration =>
      '$durationInDays ${durationInDays == 1 ? 'day' : 'days'}';

  String get statusText {
    if (!isAvailable) return 'Not Available';
    if (availableSpots <= 5) return 'Only $availableSpots spots left!';
    return 'Available';
  }

  Color get statusColor {
    if (!isAvailable) return Colors.red;
    if (availableSpots <= 5) return Colors.orange;
    return Colors.green;
  }
}

class PaymentInfo {
  final String? clientSecret;
  final dynamic bookingId; // String or int
  final String transactionId; // Or paymentIntentId
  final int numberOfPeople;
  final String formattedPricePerPerson;
  final bool hasDiscount;
  final String formattedOriginalAmount;
  final String? discountCode;
  final String formattedDiscount;
  final String formattedTotal;
  final double? totalAmount; // IMPORTANT: Add this field for reliable calculation
  final String? tourImageUrl;
  final String tourName;
  final String? tourLocation;
  final DateTime tourStartDate;
  final int durationInDays;

  PaymentInfo({
    this.clientSecret,
    required this.bookingId,
    required this.transactionId,
    required this.numberOfPeople,
    required this.formattedPricePerPerson,
    this.hasDiscount = false,
    required this.formattedOriginalAmount,
    this.discountCode,
    required this.formattedDiscount,
    required this.formattedTotal,
    this.totalAmount, // Make sure to populate this
    this.tourImageUrl,
    required this.tourName,
    this.tourLocation,
    required this.tourStartDate,
    required this.durationInDays,
  });
}
  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      bookingId: json['bookingId'] as int,
      tourId: json['tourId'] as int,
      tourName: json['tourName'] as String,
      tourImageUrl: json['tourImageUrl'] as String?,
      tourLocation: json['tourLocation'] as String?,
      numberOfPeople: json['numberOfPeople'] as int,
      tourStartDate: DateTime.parse(json['tourStartDate'] as String),
      durationInDays: json['durationInDays'] as int,
      pricePerPerson: (json['pricePerPerson'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paymentStatus: json['paymentStatus'] as String,
      paymentMethod: json['paymentMethod'] as String?,
      transactionId: json['transactionId'] as String?,
      clientSecret: json['clientSecret'] as String?,
      discountCode: json['discountCode'] as String?,
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      originalAmount: (json['originalAmount'] as num?)?.toDouble(),
    );
  }

  bool get hasDiscount => discountAmount != null && discountAmount! > 0;
  String get formattedTotal => '\$${totalAmount.toStringAsFixed(2)}';
  String get formattedPricePerPerson =>
      '\$${pricePerPerson.toStringAsFixed(2)}';
  String get formattedOriginalAmount =>
      originalAmount != null ? '\$${originalAmount!.toStringAsFixed(2)}' : '';
  String get formattedDiscount =>
      hasDiscount ? '\$${discountAmount!.toStringAsFixed(2)}' : '';
}

class Booking {
  final int id;
  final int tourId;
  final String tourName;
  final int numberOfPeople;
  final DateTime bookingDate;
  final DateTime tourStartDate;
  final double totalAmount;
  final String status;
  final String? notes;
  final String? paymentMethod;
  final String paymentStatus;
  final DateTime? paymentDate;
  final String? transactionId;
  final String? discountCode;
  final PaymentInfo? paymentInfo;

  Booking({
    required this.id,
    required this.tourId,
    required this.tourName,
    required this.numberOfPeople,
    required this.bookingDate,
    required this.tourStartDate,
    required this.totalAmount,
    required this.status,
    this.notes,
    this.paymentMethod,
    required this.paymentStatus,
    this.paymentDate,
    this.transactionId,
    this.discountCode,
    this.paymentInfo,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,
      tourId: json['tourId'] as int,
      tourName: json['tourName'] as String,
      numberOfPeople: json['numberOfPeople'] as int,
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      tourStartDate: DateTime.parse(json['tourStartDate'] as String),
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
      paymentInfo:
          json['paymentInfo'] != null
              ? PaymentInfo.fromJson(
                json['paymentInfo'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  String get formattedTotal => '\$${totalAmount.toStringAsFixed(2)}';
  String get formattedBookingDate =>
      '${bookingDate.day}/${bookingDate.month}/${bookingDate.year}';
  String get formattedTourDate =>
      '${tourStartDate.day}/${tourStartDate.month}/${tourStartDate.year}';

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
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// Enums
enum BookingStatus { pending, confirmed, cancelled }

enum PaymentStatus { pending, paid, failed }

extension BookingStatusExtension on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Failed';
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
    }
  }
}
