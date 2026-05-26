import '../../role_permissions/models/role_permission_models.dart';

class AssetModel {
  final String id;
  final String name;
  final String category; // Laptop, Mobile, Accessories, Others
  final String type; // IT Equipment, Mobile Phone, Headphone, Monitor
  final String brand;
  final String model;
  final String serialNumber;
  final DateTime purchaseDate;
  final double purchaseCost;
  final String? imageUrl;
  
  // Mutable state fields for state tracking
  String status; // Assigned, Available, Maintenance
  AppUser? assignedTo;
  DateTime? assignedDate;
  DateTime? expectedReturnDate;
  String? notes;
  
  final List<AssetHistoryLog> history;
  final List<AssetMaintenanceLog> maintenanceList;
  final List<String> files;

  AssetModel({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    required this.brand,
    required this.model,
    required this.serialNumber,
    required this.purchaseDate,
    required this.purchaseCost,
    this.imageUrl,
    required this.status,
    this.assignedTo,
    this.assignedDate,
    this.expectedReturnDate,
    this.notes,
    required this.history,
    required this.maintenanceList,
    required this.files,
  });

  AssetModel copyWith({
    String? id,
    String? name,
    String? category,
    String? type,
    String? brand,
    String? model,
    String? serialNumber,
    DateTime? purchaseDate,
    double? purchaseCost,
    String? imageUrl,
    String? status,
    AppUser? assignedTo,
    DateTime? assignedDate,
    DateTime? expectedReturnDate,
    String? notes,
    List<AssetHistoryLog>? history,
    List<AssetMaintenanceLog>? maintenanceList,
    List<String>? files,
  }) {
    return AssetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchaseCost: purchaseCost ?? this.purchaseCost,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedDate: assignedDate ?? this.assignedDate,
      expectedReturnDate: expectedReturnDate ?? this.expectedReturnDate,
      notes: notes ?? this.notes,
      history: history ?? List.from(this.history),
      maintenanceList: maintenanceList ?? List.from(this.maintenanceList),
      files: files ?? List.from(this.files),
    );
  }
}

class AssetHistoryLog {
  final String id;
  final String title;
  final DateTime timestamp;
  final String type; // assigned, returned, maintenance, added

  AssetHistoryLog({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.type,
  });
}

class AssetMaintenanceLog {
  final String id;
  final String issue;
  final DateTime dateScheduled;
  final String status; // Scheduled, Completed

  AssetMaintenanceLog({
    required this.id,
    required this.issue,
    required this.dateScheduled,
    required this.status,
  });
}
