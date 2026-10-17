import 'dart:convert';

class LeadIntegrationItem {
  final String id;
  final String name;
  final String shortName;
  final String type; // 'meta', 'google'
  bool isConnected;
  String clientId;
  String clientSecret;
  String redirectUri;
  String state;
  int leadsCountToday;
  int totalLeadsCount;
  String lastSyncTime;
  String statusMessage;

  LeadIntegrationItem({
    required this.id,
    required this.name,
    required this.shortName,
    required this.type,
    this.isConnected = false,
    this.clientId = '',
    this.clientSecret = '',
    this.redirectUri = '',
    this.state = '',
    this.leadsCountToday = 0,
    this.totalLeadsCount = 0,
    this.lastSyncTime = 'Never',
    this.statusMessage = 'Not connected',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'type': type,
      'isConnected': isConnected,
      'clientId': clientId,
      'clientSecret': clientSecret,
      'redirectUri': redirectUri,
      'state': state,
      'leadsCountToday': leadsCountToday,
      'totalLeadsCount': totalLeadsCount,
      'lastSyncTime': lastSyncTime,
      'statusMessage': statusMessage,
    };
  }

  factory LeadIntegrationItem.fromMap(Map<String, dynamic> map) {
    return LeadIntegrationItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      shortName: map['shortName'] ?? '',
      type: map['type'] ?? '',
      isConnected: map['isConnected'] ?? false,
      clientId: map['clientId'] ?? '',
      clientSecret: map['clientSecret'] ?? '',
      redirectUri: map['redirectUri'] ?? '',
      state: map['state'] ?? '',
      leadsCountToday: map['leadsCountToday'] ?? 0,
      totalLeadsCount: map['totalLeadsCount'] ?? 0,
      lastSyncTime: map['lastSyncTime'] ?? 'Never',
      statusMessage: map['statusMessage'] ?? 'Not connected',
    );
  }

  String toJson() => json.encode(toMap());

  factory LeadIntegrationItem.fromJson(String source) =>
      LeadIntegrationItem.fromMap(json.decode(source));

  LeadIntegrationItem copyWith({
    bool? isConnected,
    String? clientId,
    String? clientSecret,
    String? redirectUri,
    String? state,
    int? leadsCountToday,
    int? totalLeadsCount,
    String? lastSyncTime,
    String? statusMessage,
  }) {
    return LeadIntegrationItem(
      id: id,
      name: name,
      shortName: shortName,
      type: type,
      isConnected: isConnected ?? this.isConnected,
      clientId: clientId ?? this.clientId,
      clientSecret: clientSecret ?? this.clientSecret,
      redirectUri: redirectUri ?? this.redirectUri,
      state: state ?? this.state,
      leadsCountToday: leadsCountToday ?? this.leadsCountToday,
      totalLeadsCount: totalLeadsCount ?? this.totalLeadsCount,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
