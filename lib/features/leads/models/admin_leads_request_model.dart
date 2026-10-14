class AdminLeadsRequestModel {
  final String? assignment;
  final String? source;
  final String? status;
  final int page;
  final int perPage;
  final String? search;

  AdminLeadsRequestModel({
    this.assignment,
    this.source,
    this.status,
    this.page = 1,
    this.perPage = 20,
    this.search,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {
      'page': page,
      'per_page': perPage,
    };

    if (assignment != null &&
        assignment!.trim().isNotEmpty &&
        assignment!.toLowerCase() != 'all') {
      params['assignment'] = assignment!.trim().toLowerCase();
    }

    if (source != null &&
        source!.trim().isNotEmpty &&
        source!.toLowerCase() != 'all') {
      params['source'] = source!.trim().toLowerCase();
    }

    if (status != null &&
        status!.trim().isNotEmpty &&
        status!.toLowerCase() != 'all') {
      params['status'] = status!.trim().toLowerCase();
    }

    if (search != null && search!.trim().isNotEmpty) {
      params['search'] = search!.trim();
    }

    return params;
  }

  Map<String, dynamic> toSearchParams() {
    final Map<String, dynamic> params = {
      'q': search?.trim() ?? '',
      'page': page,
      'per_page': perPage,
    };

    if (assignment != null &&
        assignment!.trim().isNotEmpty &&
        assignment!.toLowerCase() != 'all') {
      params['assignment'] = assignment!.trim().toLowerCase();
    }

    if (source != null &&
        source!.trim().isNotEmpty &&
        source!.toLowerCase() != 'all') {
      params['source'] = source!.trim().toLowerCase();
    }

    if (status != null &&
        status!.trim().isNotEmpty &&
        status!.toLowerCase() != 'all') {
      params['status'] = status!.trim().toLowerCase();
    }

    return params;
  }

  AdminLeadsRequestModel copyWith({
    String? assignment,
    String? source,
    String? status,
    int? page,
    int? perPage,
    String? search,
  }) {
    return AdminLeadsRequestModel(
      assignment: assignment ?? this.assignment,
      source: source ?? this.source,
      status: status ?? this.status,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      search: search ?? this.search,
    );
  }
}

class CreateAdminLeadRequestModel {
  final String fullName;
  final String? companyName;
  final String? email;
  final String mobileNumber;
  final String? designation;
  final String? leadSource;
  final String? leadStatus;
  final dynamic assignTo;
  final String? requirement;
  final String? location;
  final dynamic estimatedValue;
  final String? expectedClosingDate;
  final String? notes;

  CreateAdminLeadRequestModel({
    required this.fullName,
    this.companyName,
    this.email,
    required this.mobileNumber,
    this.designation,
    this.leadSource,
    this.leadStatus,
    this.assignTo,
    this.requirement,
    this.location,
    this.estimatedValue,
    this.expectedClosingDate,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'full_name': fullName.trim(),
      'mobile_number': mobileNumber.trim(),
    };

    if (companyName != null && companyName!.trim().isNotEmpty) {
      data['company_name'] = companyName!.trim();
    }
    if (email != null && email!.trim().isNotEmpty) {
      data['email'] = email!.trim();
    }
    if (designation != null && designation!.trim().isNotEmpty) {
      data['designation'] = designation!.trim();
    }
    if (leadSource != null && leadSource!.trim().isNotEmpty) {
      data['lead_source'] = leadSource!.trim();
    }
    if (leadStatus != null && leadStatus!.trim().isNotEmpty) {
      data['lead_status'] = leadStatus!.trim();
    }
    if (assignTo != null) {
      data['assign_to'] = assignTo;
    }
    if (requirement != null && requirement!.trim().isNotEmpty) {
      data['requirement'] = requirement!.trim();
    }
    if (location != null && location!.trim().isNotEmpty) {
      data['location'] = location!.trim();
    }
    if (estimatedValue != null) {
      data['estimated_value'] = estimatedValue;
    }
    if (expectedClosingDate != null && expectedClosingDate!.trim().isNotEmpty) {
      data['expected_closing_date'] = expectedClosingDate!.trim();
    }
    if (notes != null && notes!.trim().isNotEmpty) {
      data['notes'] = notes!.trim();
    }

    return data;
  }
}

class AssignLeadRequestModel {
  final dynamic employeeId;
  final String? notes;

  AssignLeadRequestModel({
    required this.employeeId,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'employee_id': employeeId,
    };
    if (notes != null && notes!.trim().isNotEmpty) {
      map['notes'] = notes!.trim();
    }
    return map;
  }
}
