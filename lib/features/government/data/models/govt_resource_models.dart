class RegionalResource {
  final String division;
  final int activeWorkforce;
  final int ventilatorCount;
  final int oxygenReserves; // in Litres
  final int totalBeds;
  final int occupiedBeds;
  final String workforceGap; // 'Low', 'Moderate', 'High'

  const RegionalResource({
    required this.division,
    required this.activeWorkforce,
    required this.ventilatorCount,
    required this.oxygenReserves,
    required this.totalBeds,
    required this.occupiedBeds,
    required this.workforceGap,
  });

  RegionalResource copyWith({
    String? division,
    int? activeWorkforce,
    int? ventilatorCount,
    int? oxygenReserves,
    int? totalBeds,
    int? occupiedBeds,
    String? workforceGap,
  }) {
    return RegionalResource(
      division: division ?? this.division,
      activeWorkforce: activeWorkforce ?? this.activeWorkforce,
      ventilatorCount: ventilatorCount ?? this.ventilatorCount,
      oxygenReserves: oxygenReserves ?? this.oxygenReserves,
      totalBeds: totalBeds ?? this.totalBeds,
      occupiedBeds: occupiedBeds ?? this.occupiedBeds,
      workforceGap: workforceGap ?? this.workforceGap,
    );
  }
}
