class HospitalDashboardStats {
  final int activePatients;
  final double bedOccupancyRate;
  final int totalBeds;
  final int occupiedBeds;
  final int onDutyStaff;
  final int onDutyDoctors;
  final int onDutyNurses;
  final int emergencyIntake;
  final int criticalCases;
  final List<OperationalAlert> alerts;
  final List<DepartmentLoad> departmentLoads;

  HospitalDashboardStats({
    required this.activePatients,
    required this.bedOccupancyRate,
    required this.totalBeds,
    required this.occupiedBeds,
    required this.onDutyStaff,
    required this.onDutyDoctors,
    required this.onDutyNurses,
    required this.emergencyIntake,
    required this.criticalCases,
    required this.alerts,
    required this.departmentLoads,
  });

  HospitalDashboardStats copyWith({
    int? activePatients,
    double? bedOccupancyRate,
    int? totalBeds,
    int? occupiedBeds,
    int? onDutyStaff,
    int? onDutyDoctors,
    int? onDutyNurses,
    int? emergencyIntake,
    int? criticalCases,
    List<OperationalAlert>? alerts,
    List<DepartmentLoad>? departmentLoads,
  }) {
    return HospitalDashboardStats(
      activePatients: activePatients ?? this.activePatients,
      bedOccupancyRate: bedOccupancyRate ?? this.bedOccupancyRate,
      totalBeds: totalBeds ?? this.totalBeds,
      occupiedBeds: occupiedBeds ?? this.occupiedBeds,
      onDutyStaff: onDutyStaff ?? this.onDutyStaff,
      onDutyDoctors: onDutyDoctors ?? this.onDutyDoctors,
      onDutyNurses: onDutyNurses ?? this.onDutyNurses,
      emergencyIntake: emergencyIntake ?? this.emergencyIntake,
      criticalCases: criticalCases ?? this.criticalCases,
      alerts: alerts ?? this.alerts,
      departmentLoads: departmentLoads ?? this.departmentLoads,
    );
  }
}

class OperationalAlert {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final String type; // 'danger', 'warning', 'info'

  OperationalAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.type,
  });
}

class DepartmentLoad {
  final String name;
  final int patients;
  final int staff;
  final String load; // 'Critical', 'High', 'Normal'

  DepartmentLoad({
    required this.name,
    required this.patients,
    required this.staff,
    required this.load,
  });
}
