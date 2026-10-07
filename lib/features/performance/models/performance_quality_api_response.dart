class PerformanceQualityCriteriaApiData {
  final num? deliverableAccuracy;
  final num? deadlineAdherence;
  final num? defectPrevention;
  final num? collaboration;

  PerformanceQualityCriteriaApiData({
    this.deliverableAccuracy,
    this.deadlineAdherence,
    this.defectPrevention,
    this.collaboration,
  });

  factory PerformanceQualityCriteriaApiData.fromJson(Map<String, dynamic> json) {
    return PerformanceQualityCriteriaApiData(
      deliverableAccuracy: json['deliverable_accuracy'] is num
          ? (json['deliverable_accuracy'] as num)
          : (num.tryParse(json['deliverable_accuracy']?.toString() ?? '')),
      deadlineAdherence: json['deadline_adherence'] is num
          ? (json['deadline_adherence'] as num)
          : (num.tryParse(json['deadline_adherence']?.toString() ?? '')),
      defectPrevention: json['defect_prevention'] is num
          ? (json['defect_prevention'] as num)
          : (num.tryParse(json['defect_prevention']?.toString() ?? '')),
      collaboration: json['collaboration'] is num
          ? (json['collaboration'] as num)
          : (num.tryParse(json['collaboration']?.toString() ?? '')),
    );
  }
}

class PerformanceQualitySummaryApiData {
  final num? overallPercent;
  final int reviewCount;
  final PerformanceQualityCriteriaApiData? criteria;

  PerformanceQualitySummaryApiData({
    this.overallPercent,
    this.reviewCount = 0,
    this.criteria,
  });

  factory PerformanceQualitySummaryApiData.fromJson(Map<String, dynamic> json) {
    return PerformanceQualitySummaryApiData(
      overallPercent: json['overall_percent'] is num
          ? (json['overall_percent'] as num)
          : (num.tryParse(json['overall_percent']?.toString() ?? '')),
      reviewCount: int.tryParse(json['review_count']?.toString() ?? '0') ?? 0,
      criteria: json['criteria'] is Map<String, dynamic>
          ? PerformanceQualityCriteriaApiData.fromJson(json['criteria'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PerformanceQualityReviewItemApiData {
  final dynamic id;
  final String author;
  final String date;
  final String comment;
  final num? overallRating;
  final PerformanceQualityCriteriaApiData? criteria;

  PerformanceQualityReviewItemApiData({
    this.id,
    this.author = '',
    this.date = '',
    this.comment = '',
    this.overallRating,
    this.criteria,
  });

  factory PerformanceQualityReviewItemApiData.fromJson(Map<String, dynamic> json) {
    return PerformanceQualityReviewItemApiData(
      id: json['id'],
      author: json['author']?.toString() ?? json['reviewer']?.toString() ?? json['reviewer_name']?.toString() ?? '',
      date: json['date']?.toString() ?? json['created_at']?.toString() ?? '',
      comment: json['comment']?.toString() ?? json['feedback']?.toString() ?? json['notes']?.toString() ?? '',
      overallRating: json['overall_rating'] is num
          ? (json['overall_rating'] as num)
          : (num.tryParse(json['overall_rating']?.toString() ?? '')),
      criteria: json['criteria'] is Map<String, dynamic>
          ? PerformanceQualityCriteriaApiData.fromJson(json['criteria'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PerformanceQualityApiResponse {
  final bool status;
  final String message;
  final PerformanceQualitySummaryApiData? summary;
  final List<PerformanceQualityReviewItemApiData> reviews;

  PerformanceQualityApiResponse({
    required this.status,
    required this.message,
    this.summary,
    this.reviews = const [],
  });

  factory PerformanceQualityApiResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : {};

    PerformanceQualitySummaryApiData? summaryData;
    if (data['summary'] is Map<String, dynamic>) {
      summaryData = PerformanceQualitySummaryApiData.fromJson(data['summary'] as Map<String, dynamic>);
    }

    final reviewsList = (data['reviews'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map((e) => PerformanceQualityReviewItemApiData.fromJson(e))
            .toList() ??
        [];

    return PerformanceQualityApiResponse(
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status']?.toString().toLowerCase() == 'true',
      message: json['message']?.toString() ?? '',
      summary: summaryData,
      reviews: reviewsList,
    );
  }
}
