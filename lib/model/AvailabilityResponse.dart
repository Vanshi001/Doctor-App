class AvailabilityResponse {
  bool? success;
  String? message;
  List<AvailabilityData>? data;
  List<SkippedDate>? skipped;

  AvailabilityResponse({this.success, this.message, this.data, this.skipped});

  factory AvailabilityResponse.fromJson(Map<String, dynamic> json) {
    return AvailabilityResponse(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List?)?.map((e) => AvailabilityData.fromJson(e)).toList(),
      skipped: (json['skipped'] as List?)?.map((e) => SkippedDate.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
      'skipped': skipped?.map((e) => e.toJson()).toList(),
    };
  }
}

class AvailabilityData {
  String? dateKey;
  List<Slot>? slots;
  String? addedAt;

  AvailabilityData({this.dateKey, this.slots, this.addedAt});

  factory AvailabilityData.fromJson(Map<String, dynamic> json) {
    return AvailabilityData(
      dateKey: json['dateKey']?.toString() ?? '', // ✅ Safe conversion
      addedAt: json['addedAt']?.toString() ?? '',
      slots: (json['slots'] as List?)?.map((e) => Slot.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'dateKey': dateKey, 'slots': slots?.map((e) => e.toJson()).toList(), 'addedAt': addedAt};
  }
}

class Slot {
  String? id;
  String? start;
  String? end;

  Slot({this.id, this.start, this.end});

  /*factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(start: json['start'], end: json['end']);
  }

  Map<String, dynamic> toJson() {
    return {'start': start, 'end': end};
  }*/

  Slot copyWith({String? id, String? start, String? end}) =>
      Slot(id: id ?? this.id, start: start ?? this.start, end: end ?? this.end);

  factory Slot.fromJson(Map<String, dynamic> j) {
    return Slot(
      id: j['_id']?.toString() ?? '',        // ✅ Safe conversion
      start: j['start']?.toString() ?? '',  // ✅ Safe conversion
      end: j['end']?.toString() ?? '',      // ✅ Safe conversion
    );
  }

  Map<String, dynamic> toJson() => {'_id': id, 'start': start, 'end': end};
}

class SkippedDate {
  String? dateKey;
  String? reason;

  SkippedDate({this.dateKey, this.reason});

  factory SkippedDate.fromJson(Map<String, dynamic> json) {
    return SkippedDate(dateKey: json['dateKey'], reason: json['reason']);
  }

  Map<String, dynamic> toJson() {
    return {'dateKey': dateKey, 'reason': reason};
  }
}
