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

  factory FacebookAuthorizationResponseModel.fromJson(Map<String, dynamic> json) {
    String? authUrl;
    if (json.containsKey('authorization_url')) {
      authUrl = json['authorization_url']?.toString();
    } else if (json.containsKey('url')) {
      authUrl = json['url']?.toString();
    } else if (json['data'] is Map<String, dynamic>) {
      final dataMap = json['data'] as Map<String, dynamic>;
      authUrl = dataMap['authorization_url']?.toString() ?? dataMap['url']?.toString();
    } else if (json['data'] is String && (json['data'] as String).startsWith('http')) {
      authUrl = json['data'] as String;
    }

    final bool isSuccess = json['status'] == true ||
        json['success'] == true ||
        json['status'] == 200 ||
        (json['message'] != null && json['message'].toString().toLowerCase().contains('success')) ||
        (authUrl != null && authUrl.isNotEmpty);

    return FacebookAuthorizationResponseModel(
      status: isSuccess,
      message: json['message']?.toString() ?? (isSuccess ? 'Success' : 'Failed to retrieve authorization URL'),
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
