enum HealthEventType {
  consultation,
  labTest,
  imaging,
  surgery,
  admission,
  discharge,
  vaccination,
  prescription,
  followUp,
  emergency
}

class HealthEvent {
  final String id;
  final HealthEventType type;
  final String title;
  final String description;
  final DateTime date;
  final String doctorName;
  final String hospitalName;
  final String? referenceId;

  HealthEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.date,
    required this.doctorName,
    required this.hospitalName,
    this.referenceId,
  });

  factory HealthEvent.fromJson(Map<String, dynamic> json) {
    return HealthEvent(
      id: json['id'] as String? ?? '',
      type: HealthEventType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'consultation'),
        orElse: () => HealthEventType.consultation,
      ),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      doctorName: json['doctorName'] as String? ?? '',
      hospitalName: json['hospitalName'] as String? ?? '',
      referenceId: json['referenceId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'doctorName': doctorName,
      'hospitalName': hospitalName,
      'referenceId': referenceId,
    };
  }
}
