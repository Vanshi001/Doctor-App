class AppointmentResponse {
  final bool success;
  final List<Appointment> data;

  AppointmentResponse({required this.success, required this.data});

  factory AppointmentResponse.fromJson(Map<String, dynamic> json) {
    return AppointmentResponse(success: json['success'] ?? false, data: (json['data'] as List).map((e) => Appointment.fromJson(e)).toList());
  }
}

class Appointment {
  final String? id;
  final String? patientEmail;
  final String? patientFullName;
  final String? appointmentDate;
  final TimeSlot? timeSlot;
  final int? patientAge;
  final String? patientGender;
  final List<String>? concerns;
  final String? bookingId;
  final String? userId;
  final String? status;
  final CallHistory? callHistory;
  final List<Prescription>? prescription;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  Appointment({
    this.id,
    this.patientEmail,
    this.patientFullName,
    this.appointmentDate,
    this.timeSlot,
    this.patientAge,
    this.patientGender,
    this.concerns,
    this.bookingId,
    this.userId,
    this.status,
    this.callHistory,
    this.prescription,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['_id'] ?? '',
      patientEmail: json['patientEmail'] ?? '',
      patientFullName: json['patientFullName'] ?? '',
      appointmentDate: json['appointmentDate'] ?? '',
      timeSlot: TimeSlot.fromJson(json['timeSlot'] ?? {}),
      patientAge: json['patientAge'] ?? 0,
      patientGender: json['patientGender'] ?? '',
      concerns: List<String>.from(json['concerns'] ?? []),
      bookingId: json['bookingId'] ?? '',
      userId: json['userId'] ?? '',
      status: json['status'] ?? '',
      callHistory: CallHistory.fromJson(json['callHistory'] ?? {}),
      prescription: (json['prescription'] as List).map((e) => Prescription.fromJson(e)).toList(),
      notes: json['notes'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class TimeSlot {
  final String startTime;
  final String endTime;

  TimeSlot({required this.startTime, required this.endTime});

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(startTime: json['startTime'] ?? '', endTime: json['endTime'] ?? '');
  }
}

class CallHistory {
  final String startTime;
  final String endTime;
  final int duration;

  CallHistory({required this.startTime, required this.endTime, required this.duration});

  factory CallHistory.fromJson(Map<String, dynamic> json) {
    return CallHistory(startTime: json['startTime'] ?? '', endTime: json['endTime'] ?? '', duration: json['duration'] ?? 0);
  }
}

class Prescription {
  final String medicineName;
  final List<String> dosageDays;
  final List<DosageTime> dosageTimes;
  final int totalDosage;
  final String notes;

  Prescription({required this.medicineName, required this.dosageDays, required this.dosageTimes, required this.totalDosage, required this.notes});

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      medicineName: json['medicineName'] ?? '',
      dosageDays: List<String>.from(json['dosageDays'] ?? []),
      dosageTimes: (json['dosageTimes'] as List).map((e) => DosageTime.fromJson(e)).toList(),
      totalDosage: json['totalDosage'] ?? 0,
      notes: json['notes'] ?? '',
    );
  }
}

class DosageTime {
  final String period;
  final String relation;
  final String meal;
  final String quantity;
  final String instructions;

  DosageTime({required this.period, required this.relation, required this.meal, required this.quantity, required this.instructions});

  factory DosageTime.fromJson(Map<String, dynamic> json) {
    return DosageTime(
      period: json['period'] ?? '',
      relation: json['relation'] ?? '',
      meal: json['meal'] ?? '',
      quantity: json['quantity'] ?? '',
      instructions: json['instructions'] ?? '',
    );
  }
}
