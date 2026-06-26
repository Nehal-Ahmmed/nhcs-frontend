class DoctorSpecialist {
  final String id;
  final String name;
  final String specialization;
  final String hospital;
  final double rating;
  final int experienceYears;
  final int consultationFee;
  final String imageUrl;

  DoctorSpecialist({
    required this.id,
    required this.name,
    required this.specialization,
    required this.hospital,
    required this.rating,
    required this.experienceYears,
    required this.consultationFee,
    required this.imageUrl,
  });

  factory DoctorSpecialist.fromJson(Map<String, dynamic> json) {
    return DoctorSpecialist(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? json['fullName'] as String? ?? '',
      specialization: json['specialization'] as String? ?? '',
      hospital: json['hospital'] as String? ?? json['hospitalAffiliation'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      experienceYears: json['experienceYears'] as int? ?? 0,
      consultationFee: json['consultationFee'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'hospital': hospital,
      'rating': rating,
      'experienceYears': experienceYears,
      'consultationFee': consultationFee,
      'imageUrl': imageUrl,
    };
  }
}

class TimeSlot {
  final String id;
  final String time; // e.g. "09:00 AM"
  final bool isAvailable;

  TimeSlot({
    required this.id,
    required this.time,
    required this.isAvailable,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id']?.toString() ?? '',
      time: json['time'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'isAvailable': isAvailable,
    };
  }
}

class Appointment {
  final String id;
  final DoctorSpecialist doctor;
  final DateTime date;
  final String timeSlot;
  final String hospital;
  final String queueNumber;
  final String status; // Upcoming, Past, Cancelled

  Appointment({
    required this.id,
    required this.doctor,
    required this.date,
    required this.timeSlot,
    required this.hospital,
    required this.queueNumber,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String? ?? '',
      doctor: DoctorSpecialist.fromJson(json['doctor'] as Map<String, dynamic>),
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      timeSlot: json['timeSlot'] as String? ?? '',
      hospital: json['hospital'] as String? ?? json['hospitalName'] as String? ?? '',
      queueNumber: json['queueNumber'] as String? ?? '',
      status: json['status'] as String? ?? 'Upcoming',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor': doctor.toJson(),
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'hospital': hospital,
      'queueNumber': queueNumber,
      'status': status,
    };
  }
}
