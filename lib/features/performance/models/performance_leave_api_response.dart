import 'employee_performance_response_model.dart';

class PerformanceLeaveSummaryApiData {
  final int approvedDaysInPeriod;
  final int pendingRequests;
  final int annualAllowance;
  final int annualTaken;
  final int annualBalance;

  PerformanceLeaveSummaryApiData({
    this.approvedDaysInPeriod = 0,
    this.pendingRequests = 0,
    this.annualAllowance = 0,
    this.annualTaken = 0,
    this.annualBalance = 0,
  });

  factory PerformanceLeaveSummaryApiData.fromJson(Map<String, dynamic> json) {
    return PerformanceLeaveSummaryApiData(
      approvedDaysInPeriod: int.tryParse(json['approved_days_in_period']?.toString() ?? '0') ?? 0,
      pendingRequests: int.tryParse(json['pending_requests']?.toString() ?? '0') ?? 0,
      annualAllowance: int.tryParse(json['annual_allowance']?.toString() ?? '0') ?? 0,
      annualTaken: int.tryParse(json['annual_taken']?.toString() ?? '0') ?? 0,
      annualBalance: int.tryParse(json['annual_balance']?.toString() ?? '0') ?? 0,
    );
  }
}

class PerformanceLeaveBalanceApiData {
  final dynamic leaveTypeId;
  final String name;
  final String code;
  final int annualAllowance;
  final int taken;
  final int balance;

  PerformanceLeaveBalanceApiData({
    this.leaveTypeId,
    this.name = '',
    this.code = '',
    this.annualAllowance = 0,
    this.taken = 0,
    this.balance = 0,
  });

  factory PerformanceLeaveBalanceApiData.fromJson(Map<String, dynamic> json) {
    return PerformanceLeaveBalanceApiData(
      leaveTypeId: json['leave_type_id'],
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      annualAllowance: int.tryParse(json['annual_allowance']?.toString() ?? '0') ?? 0,
      taken: int.tryParse(json['taken']?.toString() ?? '0') ?? 0,
      balance: int.tryParse(json['balance']?.toString() ?? '0') ?? 0,
    );
  }
}

class PerformanceLeaveApiResponse {
  final bool status;
  final String message;
  final PerformanceLeaveSummaryApiData? summary;
  final List<PerformanceLeaveBalanceApiData> balances;
  final List<PerformanceLeaveDetailModel> requests;

  PerformanceLeaveApiResponse({
    required this.status,
    required this.message,
    this.summary,
    this.balances = const [],
    this.requests = const [],
  });

  factory PerformanceLeaveApiResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : {};
    
    PerformanceLeaveSummaryApiData? summaryData;
    if (data['summary'] is Map<String, dynamic>) {
      summaryData = PerformanceLeaveSummaryApiData.fromJson(data['summary'] as Map<String, dynamic>);
    }

    final balancesList = (data['balances'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map((e) => PerformanceLeaveBalanceApiData.fromJson(e))
            .toList() ??
        [];

    final requestsList = (data['requests'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map((e) => PerformanceLeaveDetailModel.fromJson(e))
            .toList() ??
        [];

    return PerformanceLeaveApiResponse(
      status: json['status'] == true || json['status'] == 1 || json['status']?.toString().toLowerCase() == 'true',
      message: json['message']?.toString() ?? '',
      summary: summaryData,
      balances: balancesList,
      requests: requestsList,
    );
  }
}
