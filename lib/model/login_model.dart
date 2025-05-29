class LoginResponse {
  final String token;
  final Doctor doctor;

  LoginResponse({required this.token, required this.doctor});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      doctor: Doctor.fromJson(json['data']),
    );
  }
}

class Doctor {
  final String id;
  final String name;
  final String email;/*
  final List<String> education;
  final List<String> experience;*/
  final String contactNumber;
  final String address;
  /*final String status;
  final bool isVerified;
  final List<Availability> availability;*/

  Doctor({
    required this.id,
    required this.name,
    required this.email,/*
    required this.education,
    required this.experience,*/
    required this.contactNumber,
    required this.address,
    /*required this.status,
    required this.isVerified,
    required this.availability,*/
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      /*education: List<String>.from(json['education']),
      experience: List<String>.from(json['experience']),*/
      contactNumber: json['contactNumber'],
      address: json['address'],
      /*status: json['status'],
      isVerified: json['isVerified'],
      availability: (json['availability'] as List)
          .map((e) => Availability.fromJson(e))
          .toList(),*/
    );
  }
}

class Availability {
  final String day;
  final List<Slot> slots;

  Availability({required this.day, required this.slots});

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      day: json['day'],
      slots: (json['slots'] as List).map((s) => Slot.fromJson(s)).toList(),
    );
  }
}

class Slot {
  final String start;
  final String end;

  Slot({required this.start, required this.end});

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      start: json['start'],
      end: json['end'],
    );
  }
}
