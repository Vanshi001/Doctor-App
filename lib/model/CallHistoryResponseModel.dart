import 'dart:convert';

class CallHistoryResponseModel {
  final bool success;
  final CallHistoryData data;

  CallHistoryResponseModel({
    required this.success,
    required this.data,
  });

  factory CallHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    return CallHistoryResponseModel(
      success: json['success'] ?? false,
      data: CallHistoryData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }

  static CallHistoryResponseModel fromJsonString(String jsonString) {
    final jsonMap = json.decode(jsonString);
    return CallHistoryResponseModel.fromJson(jsonMap);
  }

  String toJsonString() {
    return json.encode(toJson());
  }
}

class CallHistoryData {
  final String id;
  final TimeSlot? timeSlot;
  final String customerId;
  final String profilePicture;
  final String patientEmail;
  final String patientFullName;
  final DateTime appointmentDate;
  final int patientAge;
  final String patientGender;
  final List<String> concerns;
  final String status;
  final String bookingId;
  final String userId;
  final List<dynamic> prescription;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String doctorId;
  final CallHistory? callHistory;

  CallHistoryData({
    required this.id,
    this.timeSlot,
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
    required this.doctorId,
    this.callHistory,
  });

  factory CallHistoryData.fromJson(Map<String, dynamic> json) {
    return CallHistoryData(
      id: json['_id'] ?? '',
      timeSlot: TimeSlot.fromJson(json['timeSlot'] ?? {}),
      customerId: json['customerId'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      patientEmail: json['patientEmail'] ?? '',
      patientFullName: json['patientFullName'] ?? '',
      appointmentDate: DateTime.parse(json['appointmentDate'] ?? DateTime.now().toIso8601String()),
      patientAge: json['patientAge'] ?? 0,
      patientGender: json['patientGender'] ?? '',
      concerns: List<String>.from(json['concerns'] ?? []),
      status: json['status'] ?? '',
      bookingId: json['bookingId'] ?? '',
      userId: json['userId'] ?? '',
      prescription: List<dynamic>.from(json['prescription'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      doctorId: json['doctorId'] ?? '',
      callHistory: json['callHistory'] != null ? CallHistory.fromJson(json['callHistory']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'timeSlot': timeSlot?.toJson(),
      'customerId': customerId,
      'profilePicture': profilePicture,
      'patientEmail': patientEmail,
      'patientFullName': patientFullName,
      'appointmentDate': appointmentDate.toIso8601String(),
      'patientAge': patientAge,
      'patientGender': patientGender,
      'concerns': concerns,
      'status': status,
      'bookingId': bookingId,
      'userId': userId,
      'prescription': prescription,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'doctorId': doctorId,
      'callHistory': callHistory?.toJson(),
    };
  }

  // Helper methods
  bool get hasCallHistory => callHistory != null;
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isCompleted => callHistory != null;
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

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  // Helper method to format time for display
  String get formattedTime {
    return '$startTime - $endTime';
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
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      duration: json['duration'] ?? 0,
      id: json['_id'] ?? '',
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

  // Helper methods
  DateTime get startDateTime => DateTime.parse(startTime);
  DateTime get endDateTime => DateTime.parse(endTime);

  String get formattedDuration {
    final minutes = duration;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else {
      return '${remainingMinutes}m';
    }
  }

  String get formattedCallTime {
    final start = startDateTime;
    return '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
  }
}