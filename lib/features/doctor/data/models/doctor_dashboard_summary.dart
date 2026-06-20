class DoctorDashboardSummary {
  final int totalAppointments;
  final int totalFollowUps;
  final int emergencyCases;
  final int pendingReports;
  final int referredCases;
  final String aiBriefing;

  DoctorDashboardSummary({
    required this.totalAppointments,
    required this.totalFollowUps,
    required this.emergencyCases,
    required this.pendingReports,
    required this.referredCases,
    required this.aiBriefing,
  });

  factory DoctorDashboardSummary.fromJson(Map<String, dynamic> json) {
    return DoctorDashboardSummary(
      totalAppointments: json['totalAppointments'] as int? ?? 0,
      totalFollowUps: json['totalFollowUps'] as int? ?? 0,
      emergencyCases: json['emergencyCases'] as int? ?? 0,
      pendingReports: json['pendingReports'] as int? ?? 0,
      referredCases: json['referredCases'] as int? ?? 0,
      aiBriefing: json['aiBriefing'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAppointments': totalAppointments,
      'totalFollowUps': totalFollowUps,
      'emergencyCases': emergencyCases,
      'pendingReports': pendingReports,
      'referredCases': referredCases,
      'aiBriefing': aiBriefing,
    };
  }
}
