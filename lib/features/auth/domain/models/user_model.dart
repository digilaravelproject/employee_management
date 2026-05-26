import 'dart:convert';
import '../../../../core/constants/app_constants.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final int? tenantId;
  final String? companyName;
  final String? ownerName;
  final String? gstin;
  final String? address;
  final String? logoUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.tenantId,
    this.companyName,
    this.ownerName,
    this.gstin,
    this.address,
    this.logoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] != null ? int.parse(json['id'].toString()) : 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? '',
      tenantId: json['tenant_id'] != null ? int.parse(json['tenant_id'].toString()) : null,
      companyName: json['company_name'],
      ownerName: json['owner_name'],
      gstin: json['gstin'],
      address: json['address'],
      logoUrl: AppConstants.getFileUrl(json['logo_url']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'tenant_id': tenantId,
      'company_name': companyName,
      'owner_name': ownerName,
      'gstin': gstin,
      'address': address,
      'logo_url': logoUrl,
    };
  }

  // Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // Create from JSON string
  static UserModel? fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      return UserModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      print('Error parsing user from JSON string: $e');
      return null;
    }
  }

  // Copy with method for updating user data
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    int? tenantId,
    String? companyName,
    String? ownerName,
    String? gstin,
    String? address,
    String? logoUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      tenantId: tenantId ?? this.tenantId,
      companyName: companyName ?? this.companyName,
      ownerName: ownerName ?? this.ownerName,
      gstin: gstin ?? this.gstin,
      address: address ?? this.address,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role)';
  }
}
