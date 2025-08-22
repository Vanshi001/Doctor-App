// single_appointment_detail_model.dart
class SingleAppointmentDetailModel {
  final bool success;
  final AppointmentDetailData? data;

  SingleAppointmentDetailModel({
    required this.success,
    required this.data,
  });

  factory SingleAppointmentDetailModel.fromJson(Map<String, dynamic> json) {
    return SingleAppointmentDetailModel(
      success: json['success'] as bool,
      data: AppointmentDetailData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
    };
  }
}

class AppointmentDetailData {
  final TimeSlot? timeSlot;
  final String? id;
  final String? customerId;
  final String? profilePicture;
  final String? patientEmail;
  final String? patientFullName;
  final String? appointmentDate;
  final int? patientAge;
  final String? patientGender;
  final List<String>? concerns;
  final String? status;
  final String? bookingId;
  final String? userId;
  final List<dynamic>? prescription;
  final String? createdAt;
  final String? updatedAt;
  final int? v;
  final String? doctorId;
  final CallHistory? callHistory;

  AppointmentDetailData({
    required this.timeSlot,
    required this.id,
    required this.customerId,
    required this.profilePicture,
    required this.patientEmail,
    required this.patientFullName,
    required this.appointmentDate,
    required this.patientAge,
    required this.patientGender,
    required this.concerns,
    required this.status,
    required this.bookingId,
    required this.userId,
    required this.prescription,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.doctorId,
    this.callHistory,
  });

  factory AppointmentDetailData.fromJson(Map<String, dynamic> json) {
    return AppointmentDetailData(
      timeSlot: TimeSlot.fromJson(json['timeSlot'] as Map<String, dynamic>),
      id: json['_id'] as String,
      customerId: json['customerId'] as String,
      profilePicture: json['profilePicture'] as String,
      patientEmail: json['patientEmail'] as String,
      patientFullName: json['patientFullName'] as String,
      appointmentDate: json['appointmentDate'] as String,
      patientAge: json['patientAge'] as int,
      patientGender: json['patientGender'] as String,
      concerns: (json['concerns'] as List).map((e) => e as String).toList(),
      status: json['status'] as String,
      bookingId: json['bookingId'] as String,
      userId: json['userId'] as String,
      prescription: json['prescription'] as List<dynamic>,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      v: json['__v'] as int,
      doctorId: json['doctorId'] as String,
      callHistory: json['callHistory'] != null
          ? CallHistory.fromJson(json['callHistory'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeSlot': timeSlot?.toJson(),
      '_id': id,
      'customerId': customerId,
      'profilePicture': profilePicture,
      'patientEmail': patientEmail,
      'patientFullName': patientFullName,
      'appointmentDate': appointmentDate,
      'patientAge': patientAge,
      'patientGender': patientGender,
      'concerns': concerns,
      'status': status,
      'bookingId': bookingId,
      'userId': userId,
      'prescription': prescription,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
      'doctorId': doctorId,
      'callHistory': callHistory?.toJson(),
    };
  }
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
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}

class CallHistory {
  final String startTime;
  final String endTime;
  final int duration;
  final String id;

  CallHistory({
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.id,
  });

  factory CallHistory.fromJson(Map<String, dynamic> json) {
    return CallHistory(
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      duration: json['duration'] as int,
      id: json['_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'duration': duration,
      '_id': id,
    };
  }
}