class FacebookAuthorizationResponseModel {
  final bool status;
  final String message;
  final String? authorizationUrl;
  final dynamic data;

  FacebookAuthorizationResponseModel({
    required this.status,
    required this.message,
    this.authorizationUrl,
    this.data,
  });

  static String? _extractUrl(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return trimmed;
      }
      return null;
    }

    if (value is Map<String, dynamic> || value is Map) {
      final map = value as Map;
      // 1. Direct authorization_url and url keys
      for (final key in [
        'authorization_url',
        'auth_url',
        'oauth_url',
        'redirect_url',
        'url',
        'link'
      ]) {
        if (map.containsKey(key)) {
          final candidate = _extractUrl(map[key]);
          if (candidate != null) return candidate;
        }
      }

      // 2. Documents array (e.g. data.documents[0].url)
      if (map['documents'] is List) {
        for (final item in map['documents']) {
          final candidate = _extractUrl(item);
          if (candidate != null) return candidate;
        }
      }

      // 3. Nested 'data'
      if (map['data'] != null && map['data'] != map) {
        final candidate = _extractUrl(map['data']);
        if (candidate != null) return candidate;
      }

      // 4. Any other key ending with 'url' or 'link'
      for (final entry in map.entries) {
        final k = entry.key.toString().toLowerCase();
        if (k.contains('url') || k.contains('link')) {
          final candidate = _extractUrl(entry.value);
          if (candidate != null) return candidate;
        }
      }
    }

    if (value is List) {
      for (final item in value) {
        final candidate = _extractUrl(item);
        if (candidate != null) return candidate;
      }
    }

    return null;
  }

  factory FacebookAuthorizationResponseModel.fromJson(Map<String, dynamic> json) {
    final authUrl = _extractUrl(json);

    final bool isSuccess = json['status'] == true ||
        json['success'] == true ||
        json['status'] == 200 ||
        (json['message'] != null &&
            json['message'].toString().toLowerCase().contains('success')) ||
        (authUrl != null && authUrl.isNotEmpty);

    return FacebookAuthorizationResponseModel(
      status: isSuccess,
      message: json['message']?.toString() ??
          (isSuccess ? 'Success' : 'Failed to retrieve authorization URL'),
      authorizationUrl: authUrl,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'authorization_url': authorizationUrl,
      'data': data,
    };
  }
}
