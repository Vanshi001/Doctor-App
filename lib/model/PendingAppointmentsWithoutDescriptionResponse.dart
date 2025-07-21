class PendingAppointmentsWithoutDescriptionResponse {
  final bool success;
  final List<WithoutDescriptionAppointment> data;

  PendingAppointmentsWithoutDescriptionResponse({
    required this.success,
    required this.data,
  });

  factory PendingAppointmentsWithoutDescriptionResponse.fromJson(Map<String, dynamic> json) {
    return PendingAppointmentsWithoutDescriptionResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List)
          .map((item) => WithoutDescriptionAppointment.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data.map((item) => item.toJson()).toList(),
  };
}

class WithoutDescriptionAppointment {
  final String id;
  final String? profilePicture;
  final String patientEmail;
  final String patientFullName;
  final DateTime appointmentDate;
  final TimeSlot timeSlot;
  final int patientAge;
  final String patientGender;
  final List<String> concerns;
  final String status;
  final String bookingId;
  final String userId;
  final List<dynamic> prescription; // Empty array in response
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final String doctorId;

  WithoutDescriptionAppointment({
    required this.id,
    this.profilePicture,
    required this.patientEmail,
    required this.patientFullName,
    required this.appointmentDate,
    required this.timeSlot,
    required this.patientAge,
    required this.patientGender,
    required this.concerns,
    required this.status,
    required this.bookingId,
    required this.userId,
    required this.prescription,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.doctorId,
  });

  factory WithoutDescriptionAppointment.fromJson(Map<String, dynamic> json) {
    return WithoutDescriptionAppointment(
      id: json['_id'] ?? '',
      profilePicture: json['profilePicture'],
      patientEmail: json['patientEmail'] ?? '',
      patientFullName: json['patientFullName'] ?? '',
      appointmentDate: DateTime.parse(json['appointmentDate']),
      timeSlot: TimeSlot.fromJson(json['timeSlot']),
      patientAge: json['patientAge'] ?? 0,
      patientGender: json['patientGender'] ?? '',
      concerns: List<String>.from(json['concerns'] ?? []),
      status: json['status'] ?? '',
      bookingId: json['bookingId'] ?? '',
      userId: json['userId'] ?? '',
      prescription: List<dynamic>.from(json['prescription'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      version: json['__v'] ?? 0,
      doctorId: json['doctorId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'profilePicture': profilePicture,
    'patientEmail': patientEmail,
    'patientFullName': patientFullName,
    'appointmentDate': appointmentDate.toIso8601String(),
    'timeSlot': timeSlot.toJson(),
    'patientAge': patientAge,
    'patientGender': patientGender,
    'concerns': concerns,
    'status': status,
    'bookingId': bookingId,
    'userId': userId,
    'prescription': prescription,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    '__v': version,
    'doctorId': doctorId,
  };
}

class TimeSlot {
  final String startTime;
  final String endTime;

  TimeSlot({
    required this.startTime,
    required this.endTime,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'startTime': startTime,
    'endTime': endTime,
  };
}