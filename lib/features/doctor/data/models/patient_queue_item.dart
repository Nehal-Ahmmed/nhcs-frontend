class PatientQueueItem {
  final String id;
  final String name;
  final int age;
  final String gender;
  final List<String> existingDiseases;
  final String riskIndicator; // Low, Moderate, High, Emergency
  final String visitType; // First Consultation, Follow-up, Emergency, Referral
  final String time;
  final String healthId;

  PatientQueueItem({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.existingDiseases,
    required this.riskIndicator,
    required this.visitType,
    required this.time,
    required this.healthId,
  });

  factory PatientQueueItem.fromJson(Map<String, dynamic> json) {
    return PatientQueueItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      gender: json['gender'] as String? ?? '',
      existingDiseases: (json['existingDiseases'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      riskIndicator: json['riskIndicator'] as String? ?? 'Low',
      visitType: json['visitType'] as String? ?? 'First Consultation',
      time: json['time'] as String? ?? '',
      healthId: json['healthId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'existingDiseases': existingDiseases,
      'riskIndicator': riskIndicator,
      'visitType': visitType,
      'time': time,
      'healthId': healthId,
    };
  }
}
