class AppValidators {
  // Regex patterns
  static final RegExp _mobileRegex = RegExp(r'^[0-9]{10}$');
  static final RegExp _emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static final RegExp _pincodeRegex = RegExp(r'^[0-9]{6}$');
  static final RegExp _ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');

  /// Clean phone number by removing country code, spaces, dashes, etc.
  static String cleanPhoneNumber(String? value) {
    if (value == null) return '';
    String cleaned = value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.startsWith('+91')) {
      cleaned = cleaned.substring(3);
    } else if (cleaned.startsWith('91') && cleaned.length == 12) {
      cleaned = cleaned.substring(2);
    } else if (cleaned.startsWith('0') && cleaned.length == 11) {
      cleaned = cleaned.substring(1);
    }
    return cleaned;
  }

  /// Check if mobile number is exactly 10 digits
  static bool isValidMobile(String? value) {
    if (value == null) return false;
    final cleaned = cleanPhoneNumber(value);
    return cleaned.length == 10 && _mobileRegex.hasMatch(cleaned);
  }

  /// Check if email is valid format
  static bool isValidEmail(String? value) {
    if (value == null) return false;
    final trimmed = value.trim();
    return trimmed.isNotEmpty && _emailRegex.hasMatch(trimmed);
  }

  /// Check if pincode is valid 6 digits
  static bool isValidPincode(String? value) {
    if (value == null) return false;
    final trimmed = value.trim();
    return trimmed.length == 6 && _pincodeRegex.hasMatch(trimmed);
  }

  /// Check if IFSC is valid
  static bool isValidIfsc(String? value) {
    if (value == null) return false;
    final trimmed = value.trim().toUpperCase();
    return trimmed.length == 11 && _ifscRegex.hasMatch(trimmed);
  }

  /// Validate if field is not empty
  static String? validateEmpty(
    String? value, {
    String fieldName = "Field",
    String? customMessage,
  }) {
    final trimmed = value?.trim() ?? "";
    if (trimmed.isEmpty) {
      return customMessage ?? "$fieldName is required";
    }
    return null;
  }

  /// Validate mobile number (strictly 10 digits)
  static String? validateMobile(
    String? value, {
    int length = 10,
    String? customMessage,
  }) {
    final trimmed = value?.trim() ?? "";
    if (trimmed.isEmpty) {
      return "Mobile number is required";
    }
    final cleaned = cleanPhoneNumber(trimmed);
    if (cleaned.length != length || !RegExp(r'^[0-9]{' + length.toString() + r'}$').hasMatch(cleaned)) {
      return customMessage ?? "Enter a valid $length-digit mobile number";
    }
    return null;
  }

  /// Validate optional mobile number (if entered, must be 10 digits)
  static String? validateOptionalMobile(
    String? value, {
    int length = 10,
    String? customMessage,
  }) {
    final trimmed = value?.trim() ?? "";
    if (trimmed.isEmpty) return null;
    final cleaned = cleanPhoneNumber(trimmed);
    if (cleaned.length != length || !RegExp(r'^[0-9]{' + length.toString() + r'}$').hasMatch(cleaned)) {
      return customMessage ?? "Enter a valid $length-digit mobile number";
    }
    return null;
  }

  /// Validate email
  static String? validateEmail(
    String? value, {
    String? customMessage,
  }) {
    final trimmed = value?.trim() ?? "";
    if (trimmed.isEmpty) {
      return "Email is required";
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return customMessage ?? "Enter a valid email address";
    }
    return null;
  }

  /// Validate optional email (if entered, must be valid)
  static String? validateOptionalEmail(
    String? value, {
    String? customMessage,
  }) {
    final trimmed = value?.trim() ?? "";
    if (trimmed.isEmpty) return null;
    if (!_emailRegex.hasMatch(trimmed)) {
      return customMessage ?? "Enter a valid email address";
    }
    return null;
  }

  /// Validate pincode (6 digits)
  static String? validatePincode(
    String? value, {
    String? customMessage,
  }) {
    final trimmed = value?.trim() ?? "";
    if (trimmed.isEmpty) {
      return "Pincode is required";
    }
    if (!isValidPincode(trimmed)) {
      return customMessage ?? "Enter a valid 6-digit pincode";
    }
    return null;
  }
}
