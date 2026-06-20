class BedAllocation {
  final String id;
  final String ward; // 'General Ward (Male)', 'General Ward (Female)', 'ICU'
  final String number;
  final String status; // 'Occupied', 'Available', 'Maintenance'
  final String? patient;
  final String? healthId;
  final String? doctor;
  final int? days;

  BedAllocation({
    required this.id,
    required this.ward,
    required this.number,
    required this.status,
    this.patient,
    this.healthId,
    this.doctor,
    this.days,
  });

  BedAllocation copyWith({
    String? id,
    String? ward,
    String? number,
    String? status,
    String? patient,
    String? healthId,
    String? doctor,
    int? days,
    bool clearPatientData = false,
  }) {
    return BedAllocation(
      id: id ?? this.id,
      ward: ward ?? this.ward,
      number: number ?? this.number,
      status: status ?? this.status,
      patient: clearPatientData ? null : (patient ?? this.patient),
      healthId: clearPatientData ? null : (healthId ?? this.healthId),
      doctor: clearPatientData ? null : (doctor ?? this.doctor),
      days: clearPatientData ? null : (days ?? this.days),
    );
  }
}
