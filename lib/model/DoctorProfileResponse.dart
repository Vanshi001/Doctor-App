class DoctorProfileResponse {
  final bool success;
  final DoctorData? data;

  DoctorProfileResponse({
    required this.success,
    this.data,
  });

  factory DoctorProfileResponse.fromJson(Map<String, dynamic> json) {
    return DoctorProfileResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? DoctorData.fromJson(json['data']) : null,
    );
  }
}

class DoctorData {
  final String id;
  final String name;
  final String email;
  final List<String> education;
  final List<String> experience;
  final String contactNumber;
  final String address;
  final List<Availability> availability;
  final List<String> partnersDetails;
  final String brandNames;
  final String status;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  DoctorData({
    required this.id,
    required this.name,
    required this.email,
    required this.education,
    required this.experience,
    required this.contactNumber,
    required this.address,
    required this.availability,
    required this.partnersDetails,
    required this.brandNames,
    required this.status,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DoctorData.fromJson(Map<String, dynamic> json) {
    return DoctorData(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      education: List<String>.from(json['education'] ?? []), // Handle null
      experience: List<String>.from(json['experience'] ?? []), // Handle null
      contactNumber: json['contactNumber'] ?? '',
      address: json['address'] ?? '',
      availability: (json['availability'] as List?)?.map((item) => Availability.fromJson(item)).toList() ?? [], // Handle null
      partnersDetails: List<String>.from(json['partnersDetails'] ?? []), // Handle null
      brandNames: json['brandNames'] ?? '',
      status: json['status'] ?? '',
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'education': education,
      'experience': experience,
      'contactNumber': contactNumber,
      'address': address,
      'availability': availability.map((item) => item.toJson()).toList(),
      'partnersDetails': partnersDetails,
      'brandNames': brandNames,
      'status': status,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Availability {
  final String day;
  final List<TimeSlot> slots;

  Availability({
    required this.day,
    required this.slots,
  });

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      day: json['day'],
      slots: (json['slots'] as List)
          .map((item) => TimeSlot.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'slots': slots.map((item) => item.toJson()).toList(),
    };
  }
}

class TimeSlot {
  final String start;
  final String end;

  TimeSlot({
    required this.start,
    required this.end,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      start: json['start'],
      end: json['end'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
    };
  }
}