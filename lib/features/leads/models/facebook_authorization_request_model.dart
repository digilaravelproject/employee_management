class FacebookAuthorizationRequestModel {
  final String clientId;
  final String clientSecret;
  final String redirectUri;
  final String state;

  FacebookAuthorizationRequestModel({
    required this.clientId,
    required this.clientSecret,
    required this.redirectUri,
    required this.state,
  });

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'client_secret': clientSecret,
      'redirect_uri': redirectUri,
      'state': state,
    };
  }

  factory FacebookAuthorizationRequestModel.fromJson(Map<String, dynamic> json) {
    return FacebookAuthorizationRequestModel(
      clientId: json['client_id']?.toString() ?? '',
      clientSecret: json['client_secret']?.toString() ?? '',
      redirectUri: json['redirect_uri']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
    );
  }
}
