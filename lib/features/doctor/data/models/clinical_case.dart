class DiagnosisItem {
  final String diseaseName;
  final String status; // Provisional, Confirmed
  final String notes;

  DiagnosisItem({
    required this.diseaseName,
    required this.status,
    required this.notes,
  });

  factory DiagnosisItem.fromJson(Map<String, dynamic> json) {
    return DiagnosisItem(
      diseaseName: json['diseaseName'] as String? ?? '',
      status: json['status'] as String? ?? 'Provisional',
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diseaseName': diseaseName,
      'status': status,
      'notes': notes,
    };
  }
}

class PrescribedMedicine {
  final String medicineName;
  final String dosage; // e.g. 1+0+1, 500mg
  final String duration; // e.g. 7 days, 1 month
  final String instructions; // e.g. Before food, After food

  PrescribedMedicine({
    required this.medicineName,
    required this.dosage,
    required this.duration,
    required this.instructions,
  });

  factory PrescribedMedicine.fromJson(Map<String, dynamic> json) {
    return PrescribedMedicine(
      medicineName: json['medicineName'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicineName': medicineName,
      'dosage': dosage,
      'duration': duration,
      'instructions': instructions,
    };
  }
}

class TreatmentPlan {
  final String patientId;
  final String patientName;
  final List<String> symptoms;
  final List<DiagnosisItem> diagnoses;
  final List<PrescribedMedicine> medicines;
  final List<String> investigations; // Lab/Imaging orders
  final String clinicalNotes;
  final String followUp; // e.g., "In 2 weeks", "2026-07-03"
  final String? referralSpecialist; // e.g., "Cardiologist"
  final DateTime date;

  TreatmentPlan({
    required this.patientId,
    required this.patientName,
    required this.symptoms,
    required this.diagnoses,
    required this.medicines,
    required this.investigations,
    required this.clinicalNotes,
    required this.followUp,
    this.referralSpecialist,
    required this.date,
  });

  factory TreatmentPlan.fromJson(Map<String, dynamic> json) {
    return TreatmentPlan(
      patientId: json['patientId'] as String? ?? '',
      patientName: json['patientName'] as String? ?? '',
      symptoms: (json['symptoms'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      diagnoses: (json['diagnoses'] as List<dynamic>?)
              ?.map((e) => DiagnosisItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      medicines: (json['medicines'] as List<dynamic>?)
              ?.map((e) => PrescribedMedicine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      investigations: (json['investigations'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      clinicalNotes: json['clinicalNotes'] as String? ?? '',
      followUp: json['followUp'] as String? ?? '',
      referralSpecialist: json['referralSpecialist'] as String?,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'symptoms': symptoms,
      'diagnoses': diagnoses.map((e) => e.toJson()).toList(),
      'medicines': medicines.map((e) => e.toJson()).toList(),
      'investigations': investigations,
      'clinicalNotes': clinicalNotes,
      'followUp': followUp,
      'referralSpecialist': referralSpecialist,
      'date': date.toIso8601String(),
    };
  }
}
