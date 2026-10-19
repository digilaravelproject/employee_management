class LeadIntegrationsStatusResponseModel {
  final bool status;
  final String message;
  final LeadIntegrationsData? data;

  LeadIntegrationsStatusResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory LeadIntegrationsStatusResponseModel.fromJson(Map<String, dynamic> json) {
    return LeadIntegrationsStatusResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? LeadIntegrationsData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LeadIntegrationsData {
  final IntegrationPlatformStatus? facebook;
  final IntegrationPlatformStatus? google;

  LeadIntegrationsData({
    this.facebook,
    this.google,
  });

  factory LeadIntegrationsData.fromJson(Map<String, dynamic> json) {
    return LeadIntegrationsData(
      facebook: json['facebook'] != null && json['facebook'] is Map<String, dynamic>
          ? IntegrationPlatformStatus.fromJson(json['facebook'] as Map<String, dynamic>)
          : null,
      google: json['google'] != null && json['google'] is Map<String, dynamic>
          ? IntegrationPlatformStatus.fromJson(json['google'] as Map<String, dynamic>)
          : null,
    );
  }
}

class IntegrationPlatformStatus {
  final bool connected;
  final String status;
  final String? pageId;
  final String? pageName;
  final String? authorizedAt;
  final String? lastSyncedAt;
  final String? lastError;
  final int importedLeadsCount;
  final String? message;

  IntegrationPlatformStatus({
    required this.connected,
    required this.status,
    this.pageId,
    this.pageName,
    this.authorizedAt,
    this.lastSyncedAt,
    this.lastError,
    this.importedLeadsCount = 0,
    this.message,
  });

  factory IntegrationPlatformStatus.fromJson(Map<String, dynamic> json) {
    return IntegrationPlatformStatus(
      connected: json['connected'] == true,
      status: json['status']?.toString() ?? '',
      pageId: json['page_id']?.toString(),
      pageName: json['page_name']?.toString(),
      authorizedAt: json['authorized_at']?.toString(),
      lastSyncedAt: json['last_synced_at']?.toString(),
      lastError: json['last_error']?.toString(),
      importedLeadsCount: json['imported_leads_count'] is int
          ? json['imported_leads_count']
          : (int.tryParse(json['imported_leads_count']?.toString() ?? '0') ?? 0),
      message: json['message']?.toString(),
    );
  }
}
