import 'package:flutter/material.dart';

class LeadStatusModel {
  final dynamic id;
  final String name;
  final String? slug;
  final String category;
  final String? categoryLabel;
  final String description;
  final String badgeColor;
  final int? orderPosition;
  final bool isSystem;
  final bool isDefault;
  final int leadsCount;
  final String? createdAt;
  final String? updatedAt;

  LeadStatusModel({
    required this.id,
    required this.name,
    this.slug,
    required this.category,
    this.categoryLabel,
    this.description = '',
    required this.badgeColor,
    this.orderPosition,
    this.isSystem = false,
    this.isDefault = false,
    this.leadsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory LeadStatusModel.fromJson(Map<String, dynamic> json) {
    return LeadStatusModel(
      id: json['id'],
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      category: json['category']?.toString() ?? 'active_lead',
      categoryLabel: json['category_label']?.toString(),
      description: json['description']?.toString() ?? '',
      badgeColor: json['badge_color']?.toString() ?? '#6366F1',
      orderPosition: json['order_position'] is int
          ? json['order_position']
          : int.tryParse(json['order_position']?.toString() ?? ''),
      isSystem: json['is_system'] == true || json['is_system'] == 1,
      leadsCount: json['leads_count'] is int
          ? json['leads_count']
          : int.tryParse(json['leads_count']?.toString() ?? '') ?? 0,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'category': category,
      'category_label': categoryLabel,
      'description': description,
      'badge_color': badgeColor,
      'order_position': orderPosition,
      'is_system': isSystem,
      'leads_count': leadsCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  LeadStatusModel copyWith({
    dynamic id,
    String? name,
    String? slug,
    String? category,
    String? categoryLabel,
    String? description,
    String? badgeColor,
    int? orderPosition,
    bool? isSystem,
    int? leadsCount,
    String? createdAt,
    String? updatedAt,
  }) {
    return LeadStatusModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      category: category ?? this.category,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      description: description ?? this.description,
      badgeColor: badgeColor ?? this.badgeColor,
      orderPosition: orderPosition ?? this.orderPosition,
      isSystem: isSystem ?? this.isSystem,
      leadsCount: leadsCount ?? this.leadsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Color get color {
    return parseHexColor(badgeColor);
  }

  String get colorHex {
    return '0x${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  String get displayCategory {
    if (categoryLabel != null && categoryLabel!.isNotEmpty) {
      return categoryLabel!;
    }
    switch (category.toLowerCase()) {
      case 'active_lead':
        return 'Active Lead (In negotiation)';
      case 'prospecting':
        return 'Prospecting (Initial stage)';
      case 'won':
        return 'Won / Closed Deal';
      case 'disqualified':
        return 'Disqualified / Invalid';
      default:
        return category;
    }
  }

  static Color parseHexColor(String? hexString, {Color defaultColor = const Color(0xFF6366F1)}) {
    if (hexString == null || hexString.isEmpty) return defaultColor;
    try {
      String cleanHex = hexString.replaceAll('#', '').trim();
      if (cleanHex.startsWith('0x') || cleanHex.startsWith('0X')) {
        cleanHex = cleanHex.substring(2);
      }
      if (cleanHex.length == 6) {
        cleanHex = 'FF$cleanHex';
      }
      return Color(int.parse(cleanHex, radix: 16));
    } catch (_) {
      return defaultColor;
    }
  }
}

class CreateLeadStatusRequestModel {
  final String name;
  final String category;
  final String? description;
  final String badgeColor;
  final int? orderPosition;

  CreateLeadStatusRequestModel({
    required this.name,
    required this.category,
    this.description,
    required this.badgeColor,
    this.orderPosition,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'category': category,
      'badge_color': badgeColor.startsWith('#') ? badgeColor : '#$badgeColor',
    };
    if (description != null && description!.trim().isNotEmpty) {
      map['description'] = description!.trim();
    }
    if (orderPosition != null) {
      map['order_position'] = orderPosition;
    }
    return map;
  }
}

class LeadStatusesResponseModel {
  final bool status;
  final String message;
  final int? total;
  final List<LeadStatusModel> data;

  LeadStatusesResponseModel({
    required this.status,
    required this.message,
    this.total,
    required this.data,
  });

  factory LeadStatusesResponseModel.fromJson(Map<String, dynamic> json) {
    List<LeadStatusModel> list = [];
    final rawData = json['data'];
    if (rawData is List) {
      list = rawData.map((e) => LeadStatusModel.fromJson(e as Map<String, dynamic>)).toList();
    } else if (rawData is Map && rawData['data'] is List) {
      list = (rawData['data'] as List)
          .map((e) => LeadStatusModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final totalVal = json['total'] is int
        ? json['total']
        : int.tryParse(json['total']?.toString() ?? '');

    return LeadStatusesResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      total: totalVal ?? list.length,
      data: list,
    );
  }
}

class LeadStatusDetailResponseModel {
  final bool status;
  final String message;
  final LeadStatusModel? data;

  LeadStatusDetailResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory LeadStatusDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return LeadStatusDetailResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? LeadStatusModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
