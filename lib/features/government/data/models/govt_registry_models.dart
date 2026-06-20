class CitizenProfile {
  final String healthId;
  final String name;
  final int age;
  final String gender;
  final String division;
  final String bloodGroup;
  final String registrationDate;

  const CitizenProfile({
    required this.healthId,
    required this.name,
    required this.age,
    required this.gender,
    required this.division,
    required this.bloodGroup,
    required this.registrationDate,
  });

  CitizenProfile copyWith({
    String? healthId,
    String? name,
    int? age,
    String? gender,
    String? division,
    String? bloodGroup,
    String? registrationDate,
  }) {
    return CitizenProfile(
      healthId: healthId ?? this.healthId,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      division: division ?? this.division,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      registrationDate: registrationDate ?? this.registrationDate,
    );
  }
}

class DoctorProfile {
  final String bmdcId;
  final String name;
  final String specialization;
  final String affiliatedHospital;
  final String status; // 'Active', 'Suspended', 'Pending'
  final String registrationDate;

  const DoctorProfile({
    required this.bmdcId,
    required this.name,
    required this.specialization,
    required this.affiliatedHospital,
    required this.status,
    required this.registrationDate,
  });

  DoctorProfile copyWith({
    String? bmdcId,
    String? name,
    String? specialization,
    String? affiliatedHospital,
    String? status,
    String? registrationDate,
  }) {
    return DoctorProfile(
      bmdcId: bmdcId ?? this.bmdcId,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      affiliatedHospital: affiliatedHospital ?? this.affiliatedHospital,
      status: status ?? this.status,
      registrationDate: registrationDate ?? this.registrationDate,
    );
  }
}

class HospitalProfile {
  final String facilityId;
  final String name;
  final String division;
  final String classification; // 'General', 'Specialized', 'Clinic'
  final int totalBeds;
  final int occupiedBeds;
  final double complianceScore;
  final String status; // 'Licensed', 'Under Review', 'Suspended'

  const HospitalProfile({
    required this.facilityId,
    required this.name,
    required this.division,
    required this.classification,
    required this.totalBeds,
    required this.occupiedBeds,
    required this.complianceScore,
    required this.status,
  });

  HospitalProfile copyWith({
    String? facilityId,
    String? name,
    String? division,
    String? classification,
    int? totalBeds,
    int? occupiedBeds,
    double? complianceScore,
    String? status,
  }) {
    return HospitalProfile(
      facilityId: facilityId ?? this.facilityId,
      name: name ?? this.name,
      division: division ?? this.division,
      classification: classification ?? this.classification,
      totalBeds: totalBeds ?? this.totalBeds,
      occupiedBeds: occupiedBeds ?? this.occupiedBeds,
      complianceScore: complianceScore ?? this.complianceScore,
      status: status ?? this.status,
    );
  }
}
