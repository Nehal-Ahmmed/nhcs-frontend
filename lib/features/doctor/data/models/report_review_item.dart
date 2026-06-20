class ReportReviewItem {
  final String id;
  final String patientName;
  final String healthId;
  final String testName;
  final String category; // Lab, Imaging, ECG
  final DateTime orderedDate;
  final String status; // Pending, Reviewed
  final String trendSummary;
  final String trendStatus; // Worsening, Improving, Stable
  final Map<String, String> results;

  ReportReviewItem({
    required this.id,
    required this.patientName,
    required this.healthId,
    required this.testName,
    required this.category,
    required this.orderedDate,
    required this.status,
    required this.trendSummary,
    required this.trendStatus,
    required this.results,
  });

  factory ReportReviewItem.fromJson(Map<String, dynamic> json) {
    return ReportReviewItem(
      id: json['id'] as String? ?? '',
      patientName: json['patientName'] as String? ?? '',
      healthId: json['healthId'] as String? ?? '',
      testName: json['testName'] as String? ?? '',
      category: json['category'] as String? ?? '',
      orderedDate: json['orderedDate'] != null
          ? DateTime.parse(json['orderedDate'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? 'Pending',
      trendSummary: json['trendSummary'] as String? ?? '',
      trendStatus: json['trendStatus'] as String? ?? 'Stable',
      results: (json['results'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value.toString()),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'healthId': healthId,
      'testName': testName,
      'category': category,
      'orderedDate': orderedDate.toIso8601String(),
      'status': status,
      'trendSummary': trendSummary,
      'trendStatus': trendStatus,
      'results': results,
    };
  }
}
