class ReceptionQueueItem {
  final String queueNo;
  final String name;
  final String age;
  final String gender; // 'M', 'F'
  final String dept;
  final String doctor;
  final String status; // 'In Consultation', 'Waiting', 'Completed'

  ReceptionQueueItem({
    required this.queueNo,
    required this.name,
    required this.age,
    required this.gender,
    required this.dept,
    required this.doctor,
    required this.status,
  });

  ReceptionQueueItem copyWith({
    String? queueNo,
    String? name,
    String? age,
    String? gender,
    String? dept,
    String? doctor,
    String? status,
  }) {
    return ReceptionQueueItem(
      queueNo: queueNo ?? this.queueNo,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      dept: dept ?? this.dept,
      doctor: doctor ?? this.doctor,
      status: status ?? this.status,
    );
  }
}
