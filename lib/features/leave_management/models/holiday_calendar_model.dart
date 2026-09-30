class HolidayCalendarResponse {
  final bool status;
  final String? message;
  final int year;
  final HolidaySummary? summary;
  final List<HolidayMonth> months;
  final List<HolidayItemModel> data;

  HolidayCalendarResponse({
    required this.status,
    this.message,
    required this.year,
    this.summary,
    required this.months,
    required this.data,
  });

  factory HolidayCalendarResponse.fromJson(Map<String, dynamic> json) {
    return HolidayCalendarResponse(
      status: json['status'] == true,
      message: json['message']?.toString(),
      year: json['year'] is int
          ? json['year']
          : int.tryParse(json['year']?.toString() ?? '') ?? DateTime.now().year,
      summary: json['summary'] is Map<String, dynamic>
          ? HolidaySummary.fromJson(json['summary'])
          : null,
      months: json['months'] is List
          ? (json['months'] as List)
              .whereType<Map>()
              .map((m) => HolidayMonth.fromJson(Map<String, dynamic>.from(m)))
              .toList()
          : [],
      data: json['data'] is List
          ? (json['data'] as List)
              .whereType<Map>()
              .map((d) => HolidayItemModel.fromJson(Map<String, dynamic>.from(d)))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'year': year,
        if (summary != null) 'summary': summary!.toJson(),
        'months': months.map((m) => m.toJson()).toList(),
        'data': data.map((d) => d.toJson()).toList(),
      };
}

class HolidaySummary {
  final int total;
  final int national;
  final int restricted;
  final int optional;

  HolidaySummary({
    required this.total,
    required this.national,
    required this.restricted,
    required this.optional,
  });

  factory HolidaySummary.fromJson(Map<String, dynamic> json) {
    return HolidaySummary(
      total: _parseInt(json['total']),
      national: _parseInt(json['national']),
      restricted: _parseInt(json['restricted']),
      optional: _parseInt(json['optional']),
    );
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'national': national,
        'restricted': restricted,
        'optional': optional,
      };

  static int _parseInt(dynamic val) {
    if (val is int) return val;
    if (val != null) return int.tryParse(val.toString()) ?? 0;
    return 0;
  }
}

class HolidayMonth {
  final String month;
  final int count;
  final List<HolidayItemModel> holidays;

  HolidayMonth({
    required this.month,
    required this.count,
    required this.holidays,
  });

  factory HolidayMonth.fromJson(Map<String, dynamic> json) {
    return HolidayMonth(
      month: json['month']?.toString() ?? '',
      count: json['count'] is int
          ? json['count']
          : int.tryParse(json['count']?.toString() ?? '') ?? 0,
      holidays: json['holidays'] is List
          ? (json['holidays'] as List)
              .whereType<Map>()
              .map((h) => HolidayItemModel.fromJson(Map<String, dynamic>.from(h)))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'month': month,
        'count': count,
        'holidays': holidays.map((h) => h.toJson()).toList(),
      };
}

class HolidayItemModel {
  final int id;
  final String name;
  final String date;
  final String? day;
  final String? dayName;
  final String type;
  final String? location;
  final bool repeatEveryYear;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  HolidayItemModel({
    required this.id,
    required this.name,
    required this.date,
    this.day,
    this.dayName,
    required this.type,
    this.location,
    this.repeatEveryYear = false,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory HolidayItemModel.fromJson(Map<String, dynamic> json) {
    return HolidayItemModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      day: json['day']?.toString(),
      dayName: json['day_name']?.toString(),
      type: json['type']?.toString() ?? 'National',
      location: json['location']?.toString(),
      repeatEveryYear: json['repeat_every_year'] == true ||
          json['repeat_every_year'] == 1 ||
          json['repeat_every_year']?.toString() == 'true',
      description: json['description']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date,
        'day': day,
        'day_name': dayName,
        'type': type,
        'location': location,
        'repeat_every_year': repeatEveryYear,
        'description': description,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  /// Returns a clean display string like "26 Jan, Mon" or "03 Mar, Tue"
  String get formattedDisplayDate {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        final dayNum = parts[2].padLeft(2, '0');
        final monthNum = int.tryParse(parts[1]) ?? 1;
        const monthNames = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        final monthStr = (monthNum >= 1 && monthNum <= 12)
            ? monthNames[monthNum - 1]
            : parts[1];
        final dayStr = (day != null && day!.isNotEmpty) ? ', $day' : '';
        return '$dayNum $monthStr$dayStr';
      }
    } catch (_) {}
    return date;
  }
}
