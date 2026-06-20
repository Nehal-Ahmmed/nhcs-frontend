class GovtDashboardStats {
  final int totalRegisteredCitizens;
  final int totalRegisteredDoctors;
  final int totalLicensedHospitals;
  final int activeDiseaseOutbreaks;
  final double nationalBedOccupancyRate;
  final List<NationalAlert> alerts;
  final List<OutbreakStat> outbreaks;

  const GovtDashboardStats({
    required this.totalRegisteredCitizens,
    required this.totalRegisteredDoctors,
    required this.totalLicensedHospitals,
    required this.activeDiseaseOutbreaks,
    required this.nationalBedOccupancyRate,
    required this.alerts,
    required this.outbreaks,
  });

  GovtDashboardStats copyWith({
    int? totalRegisteredCitizens,
    int? totalRegisteredDoctors,
    int? totalLicensedHospitals,
    int? activeDiseaseOutbreaks,
    double? nationalBedOccupancyRate,
    List<NationalAlert>? alerts,
    List<OutbreakStat>? outbreaks,
  }) {
    return GovtDashboardStats(
      totalRegisteredCitizens: totalRegisteredCitizens ?? this.totalRegisteredCitizens,
      totalRegisteredDoctors: totalRegisteredDoctors ?? this.totalRegisteredDoctors,
      totalLicensedHospitals: totalLicensedHospitals ?? this.totalLicensedHospitals,
      activeDiseaseOutbreaks: activeDiseaseOutbreaks ?? this.activeDiseaseOutbreaks,
      nationalBedOccupancyRate: nationalBedOccupancyRate ?? this.nationalBedOccupancyRate,
      alerts: alerts ?? this.alerts,
      outbreaks: outbreaks ?? this.outbreaks,
    );
  }
}

class NationalAlert {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final String type; // 'danger', 'warning', 'info'
  final String division;

  const NationalAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.type,
    required this.division,
  });

  NationalAlert copyWith({
    String? id,
    String? title,
    String? description,
    String? timeAgo,
    String? type,
    String? division,
  }) {
    return NationalAlert(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timeAgo: timeAgo ?? this.timeAgo,
      type: type ?? this.type,
      division: division ?? this.division,
    );
  }
}

class OutbreakStat {
  final String id;
  final String diseaseName;
  final int activeCases;
  final int weeklyNewCases;
  final String riskLevel; // 'High', 'Moderate', 'Low'
  final String trend; // 'Rising', 'Stable', 'Falling'
  final String affectedAreas;

  const OutbreakStat({
    required this.id,
    required this.diseaseName,
    required this.activeCases,
    required this.weeklyNewCases,
    required this.riskLevel,
    required this.trend,
    required this.affectedAreas,
  });

  OutbreakStat copyWith({
    String? id,
    String? diseaseName,
    int? activeCases,
    int? weeklyNewCases,
    String? riskLevel,
    String? trend,
    String? affectedAreas,
  }) {
    return OutbreakStat(
      id: id ?? this.id,
      diseaseName: diseaseName ?? this.diseaseName,
      activeCases: activeCases ?? this.activeCases,
      weeklyNewCases: weeklyNewCases ?? this.weeklyNewCases,
      riskLevel: riskLevel ?? this.riskLevel,
      trend: trend ?? this.trend,
      affectedAreas: affectedAreas ?? this.affectedAreas,
    );
  }
}
