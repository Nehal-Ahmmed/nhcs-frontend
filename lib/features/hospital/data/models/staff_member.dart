class StaffMember {
  final String id;
  final String name;
  final String role; // 'Doctor', 'Nurse', 'Technician'
  final String dept;
  final String status; // 'Active', 'On Leave'
  final Map<String, String> shifts; // e.g., {'Monday': '8 AM - 2 PM', 'Tuesday': 'Emergency Duty'}

  StaffMember({
    required this.id,
    required this.name,
    required this.role,
    required this.dept,
    required this.status,
    required this.shifts,
  });

  StaffMember copyWith({
    String? id,
    String? name,
    String? role,
    String? dept,
    String? status,
    Map<String, String>? shifts,
  }) {
    return StaffMember(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      dept: dept ?? this.dept,
      status: status ?? this.status,
      shifts: shifts ?? this.shifts,
    );
  }
}

class DoctorVerificationRequest {
  final String id;
  final String name;
  final String bmdcNo;
  final String specialization;
  final String date;
  final String status; // 'Pending', 'Approved', 'Rejected'

  DoctorVerificationRequest({
    required this.id,
    required this.name,
    required this.bmdcNo,
    required this.specialization,
    required this.date,
    required this.status,
  });

  DoctorVerificationRequest copyWith({
    String? id,
    String? name,
    String? bmdcNo,
    String? specialization,
    String? date,
    String? status,
  }) {
    return DoctorVerificationRequest(
      id: id ?? this.id,
      name: name ?? this.name,
      bmdcNo: bmdcNo ?? this.bmdcNo,
      specialization: specialization ?? this.specialization,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }
}
