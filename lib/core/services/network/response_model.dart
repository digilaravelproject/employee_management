class ResponseModel {
  final bool isSuccess;
  final String message;
  final dynamic body;
  final int? statusCode;
  final List<ErrorDetail>? errors;
  final Map<String, dynamic>? json;

  const ResponseModel({
    required this.isSuccess,
    required this.message,
    this.body,
    this.statusCode,
    this.errors,
    this.json,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json, {int? statusCode}) {
    // Check for success in multiple ways
    final res = json['res']?.toString().toLowerCase();
    final successValue = json['success'];
    
    bool success = false;
    if (res == 'success') {
      success = true;
    } else if (successValue is bool) {
      success = successValue;
    } else if (successValue != null) {
      success = successValue.toString().toLowerCase() == 'true';
    } else if (statusCode == 200 || statusCode == 201 || statusCode == 204) {
      // If no explicit success flag, but HTTP status is OK, consider it a success
      success = true;
    }

    // Parse errors - handle both List and Map formats
    List<ErrorDetail>? errors;
    String? firstErrorMessage;
    
    if (json['errors'] is List) {
      errors = (json['errors'] as List)
          .map((e) => ErrorDetail.fromJson(e))
          .toList();
      if (errors.isNotEmpty) {
        firstErrorMessage = errors.first.message;
      }
    } else if (json['errors'] is Map) {
      // Handle Laravel-style validation errors: {field: [messages]}
      final errorsMap = json['errors'] as Map<String, dynamic>;
      errors = [];
      
      errorsMap.forEach((field, messages) {
        if (messages is List && messages.isNotEmpty) {
          // Get first message for this field
          final message = messages.first.toString();
          errors!.add(ErrorDetail(code: field, message: message));
          
          // Store the very first error message
          firstErrorMessage ??= message;
        }
      });
    }

    // Determine body - prefer 'data' key, but fallback to entire json if not present
    dynamic bodyData;
    if (json.containsKey('data')) {
      bodyData = json['data'];
    } else {
      // If no 'data' key, use the entire json (useful for responses with user, token, etc.)
      // Remove success and message keys to avoid duplication
      bodyData = Map<String, dynamic>.from(json);
      bodyData.remove('success');
      bodyData.remove('message');
      bodyData.remove('msg');
      bodyData.remove('res');
      bodyData.remove('errors');
      
      // If body is empty after removing keys, set to entire json
      if (bodyData.isEmpty) {
        bodyData = json;
      }
    }

    // Use first error message if available, otherwise use main message
    final message = firstErrorMessage ?? 
                   json['msg']?.toString() ??
                   json['message']?.toString() ??
                   (success ? 'Success' : 'Something went wrong');

    return ResponseModel(
      isSuccess: success,
      message: message,
      body: bodyData,
      statusCode: statusCode,
      errors: errors,
      json: json,
    );
  }

  /// Convert this model back to JSON
  Map<String, dynamic> toJson() => {
    'isSuccess': isSuccess,
    'message': message,
    'data': body,
    'statusCode': statusCode,
    'errors': errors?.map((e) => e.toJson()).toList(),
  };

  /// Create a copy with updated fields
  ResponseModel copyWith({
    bool? isSuccess,
    String? message,
    dynamic body,
    int? statusCode,
    List<ErrorDetail>? errors,
  }) {
    return ResponseModel(
      isSuccess: isSuccess ?? this.isSuccess,
      message: message ?? this.message,
      body: body ?? this.body,
      statusCode: statusCode ?? this.statusCode,
      errors: errors ?? this.errors,
    );
  }

  /// For easier debugging
  @override
  String toString() {
    return 'ResponseModel(isSuccess: $isSuccess, '
        'message: $message, '
        'statusCode: $statusCode, '
        'errors: $errors, '
        'body: $body)';
  }
}

/// Represents error detail (if any)
class ErrorDetail {
  final String? code;
  final String? message;

  const ErrorDetail({this.code, this.message});

  factory ErrorDetail.fromJson(Map<String, dynamic> json) {
    return ErrorDetail(
      code: json['code']?.toString(),
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
  };

  @override
  String toString() => 'ErrorDetail(code: $code, message: $message)';
}
