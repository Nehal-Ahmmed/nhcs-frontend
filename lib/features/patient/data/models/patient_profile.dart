class EmergencyContact {
  final String name;
  final String relationship;
  final String phone;

  EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phone,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] as String? ?? '',
      relationship: json['relationship'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relationship': relationship,
      'phone': phone,
    };
  }
}

class Allergy {
  final String allergen;
  final String severity; // Mild, Moderate, Severe
  final String reaction;

  Allergy({
    required this.allergen,
    required this.severity,
    required this.reaction,
  });

  factory Allergy.fromJson(Map<String, dynamic> json) {
    return Allergy(
      allergen: json['allergen'] as String? ?? '',
      severity: json['severity'] as String? ?? 'Mild',
      reaction: json['reaction'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allergen': allergen,
      'severity': severity,
      'reaction': reaction,
    };
  }
}

class ChronicDisease {
  final String diseaseName;
  final String status; // Active, Managed, Resolved
  final DateTime diagnosedDate;

  ChronicDisease({
    required this.diseaseName,
    required this.status,
    required this.diagnosedDate,
  });

  factory ChronicDisease.fromJson(Map<String, dynamic> json) {
    return ChronicDisease(
      diseaseName: json['diseaseName'] as String? ?? '',
      status: json['status'] as String? ?? 'Active',
      diagnosedDate: json['diagnosedDate'] != null 
          ? DateTime.parse(json['diagnosedDate'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diseaseName': diseaseName,
      'status': status,
      'diagnosedDate': diagnosedDate.toIso8601String(),
    };
  }
}

class VitalSign {
  final String bpSystolic;
  final String bpDiastolic;
  final String bloodGlucose;
  final String heartRate;
  final String weight;
  final DateTime lastUpdated;

  VitalSign({
    required this.bpSystolic,
    required this.bpDiastolic,
    required this.bloodGlucose,
    required this.heartRate,
    required this.weight,
    required this.lastUpdated,
  });

  factory VitalSign.fromJson(Map<String, dynamic> json) {
    return VitalSign(
      bpSystolic: json['bpSystolic'] as String? ?? '',
      bpDiastolic: json['bpDiastolic'] as String? ?? '',
      bloodGlucose: json['bloodGlucose'] as String? ?? '',
      heartRate: json['heartRate'] as String? ?? '',
      weight: json['weight'] as String? ?? '',
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bpSystolic': bpSystolic,
      'bpDiastolic': bpDiastolic,
      'bloodGlucose': bloodGlucose,
      'heartRate': heartRate,
      'weight': weight,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class PatientProfile {
  final String healthId;
  final String name;
  final DateTime dateOfBirth;
  final String gender;
  final String bloodGroup;
  final String nationalId;
  final String phone;
  final String occupation;
  final String maritalStatus;
  final String presentAddress;
  final String permanentAddress;
  final List<EmergencyContact> emergencyContacts;
  final List<Allergy> allergies;
  final List<ChronicDisease> chronicDiseases;
  final VitalSign vitals;

  PatientProfile({
    required this.healthId,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    required this.nationalId,
    required this.phone,
    required this.occupation,
    required this.maritalStatus,
    required this.presentAddress,
    required this.permanentAddress,
    required this.emergencyContacts,
    required this.allergies,
    required this.chronicDiseases,
    required this.vitals,
  });

  PatientProfile copyWith({
    String? name,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodGroup,
    String? phone,
    String? occupation,
    String? maritalStatus,
    String? presentAddress,
    String? permanentAddress,
    List<EmergencyContact>? emergencyContacts,
    List<Allergy>? allergies,
    List<ChronicDisease>? chronicDiseases,
    VitalSign? vitals,
  }) {
    return PatientProfile(
      healthId: healthId,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      nationalId: nationalId,
      phone: phone ?? this.phone,
      occupation: occupation ?? this.occupation,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      presentAddress: presentAddress ?? this.presentAddress,
      permanentAddress: permanentAddress ?? this.permanentAddress,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      allergies: allergies ?? this.allergies,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      vitals: vitals ?? this.vitals,
    );
  }

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      healthId: json['healthId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth'] as String) 
          : DateTime.now(),
      gender: json['gender'] as String? ?? '',
      bloodGroup: json['bloodGroup'] as String? ?? '',
      nationalId: json['nationalId'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      occupation: json['occupation'] as String? ?? '',
      maritalStatus: json['maritalStatus'] as String? ?? '',
      presentAddress: json['presentAddress'] as String? ?? '',
      permanentAddress: json['permanentAddress'] as String? ?? '',
      emergencyContacts: (json['emergencyContacts'] as List<dynamic>?)
              ?.map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => Allergy.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      chronicDiseases: (json['chronicDiseases'] as List<dynamic>?)
              ?.map((e) => ChronicDisease.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      vitals: json['vitals'] != null 
          ? VitalSign.fromJson(json['vitals'] as Map<String, dynamic>)
          : VitalSign(bpSystolic: '', bpDiastolic: '', bloodGlucose: '', heartRate: '', weight: '', lastUpdated: DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'healthId': healthId,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'bloodGroup': bloodGroup,
      'nationalId': nationalId,
      'phone': phone,
      'occupation': occupation,
      'maritalStatus': maritalStatus,
      'presentAddress': presentAddress,
      'permanentAddress': permanentAddress,
      'emergencyContacts': emergencyContacts.map((e) => e.toJson()).toList(),
      'allergies': allergies.map((e) => e.toJson()).toList(),
      'chronicDiseases': chronicDiseases.map((e) => e.toJson()).toList(),
      'vitals': vitals.toJson(),
    };
  }
}
