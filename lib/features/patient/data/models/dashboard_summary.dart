class DashboardSummary {
  final int totalVisits;
  final int activeTreatments;
  final int upcomingAppointments;
  final int pendingReports;
  final int activeMedications;

  DashboardSummary({
    required this.totalVisits,
    required this.activeTreatments,
    required this.upcomingAppointments,
    required this.pendingReports,
    required this.activeMedications,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalVisits: json['totalVisits'] as int? ?? 0,
      activeTreatments: json['activeTreatments'] as int? ?? 0,
      upcomingAppointments: json['upcomingAppointments'] as int? ?? 0,
      pendingReports: json['pendingReports'] as int? ?? 0,
      activeMedications: json['activeMedications'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalVisits': totalVisits,
      'activeTreatments': activeTreatments,
      'upcomingAppointments': upcomingAppointments,
      'pendingReports': pendingReports,
      'activeMedications': activeMedications,
    };
  }
}

class AiHealthSummary {
  final String summaryText;
  final DateTime lastUpdated;

  AiHealthSummary({
    required this.summaryText,
    required this.lastUpdated,
  });

  factory AiHealthSummary.fromJson(Map<String, dynamic> json) {
    return AiHealthSummary(
      summaryText: json['summaryText'] as String? ?? '',
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summaryText': summaryText,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
