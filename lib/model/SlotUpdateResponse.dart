class SlotUpdateResponse {
  final bool success;
  final String message;
  final List<SlotDate> data;

  SlotUpdateResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SlotUpdateResponse.fromJson(Map<String, dynamic> json) {
    return SlotUpdateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => SlotDate.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data.map((e) => e.toJson()).toList(),
  };
}

class SlotDate {
  final String dateKey;
  final List<SlotItem> slots;

  SlotDate({
    required this.dateKey,
    required this.slots,
  });

  factory SlotDate.fromJson(Map<String, dynamic> json) {
    return SlotDate(
      dateKey: json['dateKey'] ?? '',
      slots: (json['slots'] as List<dynamic>?)
          ?.map((e) => SlotItem.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'dateKey': dateKey,
    'slots': slots.map((e) => e.toJson()).toList(),
  };
}

class SlotItem {
  final String id;
  final String start;
  final String end;

  SlotItem({
    required this.id,
    required this.start,
    required this.end,
  });

  factory SlotItem.fromJson(Map<String, dynamic> json) {
    return SlotItem(
      id: json['_id'] ?? '',
      start: json['start'] ?? '',
      end: json['end'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'start': start,
    'end': end,
  };
}
