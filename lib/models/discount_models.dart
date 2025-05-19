import 'package:flutter/material.dart';

class Discount {
  final int id;
  final String code;
  final String name;
  final String? description;
  final DiscountType type;
  final double value;
  final double? minimumAmount;
  final int? usageLimit;
  final int usageCount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final List<String>? applicableCategories;
  final DateTime createdAt;
  final DateTime updatedAt;

  Discount({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.type,
    required this.value,
    this.minimumAmount,
    this.usageLimit,
    required this.usageCount,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.applicableCategories,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: DiscountType.fromString(json['type'] as String),
      value: (json['value'] as num).toDouble(),
      minimumAmount: (json['minimumAmount'] as num?)?.toDouble(),
      usageLimit: json['usageLimit'] as int?,
      usageCount: json['usageCount'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool,
      applicableCategories:
          (json['applicableCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'type': type.value,
      'value': value,
      'minimumAmount': minimumAmount,
      'usageLimit': usageLimit,
      'usageCount': usageCount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'applicableCategories': applicableCategories,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isNotStarted => DateTime.now().isBefore(startDate);
  bool get isUsageLimitReached =>
      usageLimit != null && usageCount >= usageLimit!;
  bool get isCurrentlyValid =>
      isActive && !isExpired && !isNotStarted && !isUsageLimitReached;

  String get statusText {
    if (!isActive) return 'Inactive';
    if (isExpired) return 'Expired';
    if (isNotStarted) return 'Not started';
    if (isUsageLimitReached) return 'Usage limit reached';
    return 'Active';
  }

  Color get statusColor {
    if (!isActive) return Colors.grey;
    if (isExpired) return Colors.red;
    if (isNotStarted) return Colors.orange;
    if (isUsageLimitReached) return Colors.purple;
    return Colors.green;
  }

  IconData get statusIcon {
    if (!isActive) return Icons.pause_circle;
    if (isExpired) return Icons.event_busy;
    if (isNotStarted) return Icons.schedule;
    if (isUsageLimitReached) return Icons.block;
    return Icons.check_circle;
  }

  String get formattedValue {
    if (type == DiscountType.percentage) {
      return '${value.toStringAsFixed(0)}%';
    } else {
      return '\$${value.toStringAsFixed(2)}';
    }
  }

  String get usageText {
    if (usageLimit != null) {
      return '$usageCount / $usageLimit uses';
    } else {
      return '$usageCount uses';
    }
  }

  double calculateDiscountAmount(double amount) {
    if (type == DiscountType.percentage) {
      return amount * (value / 100);
    } else {
      return value;
    }
  }

  double applyDiscount(double amount) {
    final discountAmount = calculateDiscountAmount(amount);
    return (amount - discountAmount).clamp(0, amount);
  }
}

enum DiscountType {
  percentage('percentage'),
  fixedAmount('fixed');

  const DiscountType(this.value);
  final String value;

  static DiscountType fromString(String value) {
    return DiscountType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => DiscountType.percentage,
    );
  }

  String get displayName {
    switch (this) {
      case DiscountType.percentage:
        return 'Percentage';
      case DiscountType.fixedAmount:
        return 'Fixed Amount';
    }
  }

  IconData get icon {
    switch (this) {
      case DiscountType.percentage:
        return Icons.percent;
      case DiscountType.fixedAmount:
        return Icons.attach_money;
    }
  }
}

class CreateDiscountRequest {
  final String code;
  final String name;
  final String? description;
  final DiscountType type;
  final double value;
  final double? minimumAmount;
  final int? usageLimit;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final List<String>? applicableCategories;

  CreateDiscountRequest({
    required this.code,
    required this.name,
    this.description,
    required this.type,
    required this.value,
    this.minimumAmount,
    this.usageLimit,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.applicableCategories,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'type': type.value,
      'value': value,
      'minimumAmount': minimumAmount,
      'usageLimit': usageLimit,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'applicableCategories': applicableCategories,
    };
  }
}

class UpdateDiscountRequest {
  final String? name;
  final String? description;
  final double? value;
  final double? minimumAmount;
  final int? usageLimit;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isActive;
  final List<String>? applicableCategories;

  UpdateDiscountRequest({
    this.name,
    this.description,
    this.value,
    this.minimumAmount,
    this.usageLimit,
    this.startDate,
    this.endDate,
    this.isActive,
    this.applicableCategories,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (value != null) data['value'] = value;
    if (minimumAmount != null) data['minimumAmount'] = minimumAmount;
    if (usageLimit != null) data['usageLimit'] = usageLimit;
    if (startDate != null) data['startDate'] = startDate!.toIso8601String();
    if (endDate != null) data['endDate'] = endDate!.toIso8601String();
    if (isActive != null) data['isActive'] = isActive;
    if (applicableCategories != null) {
      data['applicableCategories'] = applicableCategories;
    }
    return data;
  }
}

class PaginatedDiscounts {
  final List<Discount> items;
  final int pageIndex;
  final int totalPages;
  final int totalCount;
  final bool hasPreviousPage;
  final bool hasNextPage;

  PaginatedDiscounts({
    required this.items,
    required this.pageIndex,
    required this.totalPages,
    required this.totalCount,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory PaginatedDiscounts.fromJson(Map<String, dynamic> json) {
    return PaginatedDiscounts(
      items:
          (json['items'] as List<dynamic>)
              .map((e) => Discount.fromJson(e as Map<String, dynamic>))
              .toList(),
      pageIndex: json['pageIndex'] as int,
      totalPages: json['totalPages'] as int,
      totalCount: json['totalCount'] as int,
      hasPreviousPage: json['hasPreviousPage'] as bool,
      hasNextPage: json['hasNextPage'] as bool,
    );
  }
}

class DiscountFilterRequest {
  final String? searchTerm;
  final DiscountType? type;
  final bool? isActive;
  final bool? showExpired;
  final List<String>? categories;
  final int? pageIndex;
  final int? pageSize;
  final String? sortBy;
  final bool? ascending;

  DiscountFilterRequest({
    this.searchTerm,
    this.type,
    this.isActive,
    this.showExpired,
    this.categories,
    this.pageIndex,
    this.pageSize,
    this.sortBy,
    this.ascending,
  });

  Map<String, String> toQueryParams() {
    final Map<String, String> params = {};

    if (searchTerm != null && searchTerm!.isNotEmpty) {
      params['searchTerm'] = searchTerm!;
    }
    if (type != null) params['type'] = type!.value;
    if (isActive != null) params['isActive'] = isActive.toString();
    if (showExpired != null) params['showExpired'] = showExpired.toString();
    if (pageIndex != null) params['pageIndex'] = pageIndex.toString();
    if (pageSize != null) params['pageSize'] = pageSize.toString();
    if (sortBy != null) params['sortBy'] = sortBy!;
    if (ascending != null) params['ascending'] = ascending.toString();

    return params;
  }
}
