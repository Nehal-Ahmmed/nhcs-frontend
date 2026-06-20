class LabTestOrder {
  final String id;
  final String patient;
  final String healthId;
  final String test;
  final String doctor;
  final String status; // 'Ordered', 'Sample Collected', 'Processing', 'Verified', 'Published'
  final Map<String, String> results;

  LabTestOrder({
    required this.id,
    required this.patient,
    required this.healthId,
    required this.test,
    required this.doctor,
    required this.status,
    required this.results,
  });

  LabTestOrder copyWith({
    String? id,
    String? patient,
    String? healthId,
    String? test,
    String? doctor,
    String? status,
    Map<String, String>? results,
  }) {
    return LabTestOrder(
      id: id ?? this.id,
      patient: patient ?? this.patient,
      healthId: healthId ?? this.healthId,
      test: test ?? this.test,
      doctor: doctor ?? this.doctor,
      status: status ?? this.status,
      results: results ?? this.results,
    );
  }
}
