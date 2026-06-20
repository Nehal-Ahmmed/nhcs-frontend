class Medicine {
  final String name;
  final String dosage; // e.g. "500mg"
  final String instruction; // e.g. "1 tablet twice daily after meals"
  final String duration; // e.g. "14 days"

  Medicine({
    required this.name,
    required this.dosage,
    required this.instruction,
    required this.duration,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      instruction: json['instruction'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'instruction': instruction,
      'duration': duration,
    };
  }
}

class Prescription {
  final String id;
  final DateTime date;
  final String doctorName;
  final String doctorSpecialization;
  final String hospitalName;
  final String diagnosis;
  final List<Medicine> medicines;
  final String clinicalNotes;
  final String? followUpDate;

  Prescription({
    required this.id,
    required this.date,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.hospitalName,
    required this.diagnosis,
    required this.medicines,
    required this.clinicalNotes,
    this.followUpDate,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] as String? ?? '',
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      doctorName: json['doctorName'] as String? ?? '',
      doctorSpecialization: json['doctorSpecialization'] as String? ?? '',
      hospitalName: json['hospitalName'] as String? ?? '',
      diagnosis: json['diagnosis'] as String? ?? '',
      medicines: (json['medicines'] as List<dynamic>?)
              ?.map((e) => Medicine.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      clinicalNotes: json['clinicalNotes'] as String? ?? '',
      followUpDate: json['followUpDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'doctorName': doctorName,
      'doctorSpecialization': doctorSpecialization,
      'hospitalName': hospitalName,
      'diagnosis': diagnosis,
      'medicines': medicines.map((e) => e.toJson()).toList(),
      'clinicalNotes': clinicalNotes,
      'followUpDate': followUpDate,
    };
  }
}

class LabTestResult {
  final String parameter;
  final String value;
  final String unit;
  final String referenceRange;
  final String status; // Normal, High, Low

  LabTestResult({
    required this.parameter,
    required this.value,
    required this.unit,
    required this.referenceRange,
    required this.status,
  });

  factory LabTestResult.fromJson(Map<String, dynamic> json) {
    return LabTestResult(
      parameter: json['parameter'] as String? ?? '',
      value: json['value'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      referenceRange: json['referenceRange'] as String? ?? '',
      status: json['status'] as String? ?? 'Normal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parameter': parameter,
      'value': value,
      'unit': unit,
      'referenceRange': referenceRange,
      'status': status,
    };
  }
}

class LabReport {
  final String id;
  final String testName;
  final String category; // Haematology, Biochemistry, etc.
  final DateTime date;
  final String hospitalName;
  final String doctorName;
  final String status; // Ordered, Published
  final List<LabTestResult> results;
  final String aiInterpretation;

  LabReport({
    required this.id,
    required this.testName,
    required this.category,
    required this.date,
    required this.hospitalName,
    required this.doctorName,
    required this.status,
    required this.results,
    required this.aiInterpretation,
  });

  factory LabReport.fromJson(Map<String, dynamic> json) {
    return LabReport(
      id: json['id'] as String? ?? '',
      testName: json['testName'] as String? ?? '',
      category: json['category'] as String? ?? '',
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      hospitalName: json['hospitalName'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      status: json['status'] as String? ?? 'Published',
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => LabTestResult.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      aiInterpretation: json['aiInterpretation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'testName': testName,
      'category': category,
      'date': date.toIso8601String(),
      'hospitalName': hospitalName,
      'doctorName': doctorName,
      'status': status,
      'results': results.map((e) => e.toJson()).toList(),
      'aiInterpretation': aiInterpretation,
    };
  }
}

class ImagingReport {
  final String id;
  final String type; // X-Ray, MRI, CT Scan, Ultrasound
  final String bodyPart;
  final DateTime date;
  final String hospitalName;
  final String doctorName;
  final String imageUrl; // Placeholder/mock URL
  final String findings;
  final String impression;

  ImagingReport({
    required this.id,
    required this.type,
    required this.bodyPart,
    required this.date,
    required this.hospitalName,
    required this.doctorName,
    required this.imageUrl,
    required this.findings,
    required this.impression,
  });

  factory ImagingReport.fromJson(Map<String, dynamic> json) {
    return ImagingReport(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      bodyPart: json['bodyPart'] as String? ?? '',
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      hospitalName: json['hospitalName'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      findings: json['findings'] as String? ?? '',
      impression: json['impression'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'bodyPart': bodyPart,
      'date': date.toIso8601String(),
      'hospitalName': hospitalName,
      'doctorName': doctorName,
      'imageUrl': imageUrl,
      'findings': findings,
      'impression': impression,
    };
  }
}
