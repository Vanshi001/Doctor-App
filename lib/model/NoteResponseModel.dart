class NoteResponseModel {
  final bool success;
  final int total;
  final List<NoteData> data;

  NoteResponseModel({
    required this.success,
    required this.total,
    required this.data,
  });

  factory NoteResponseModel.fromJson(Map<String, dynamic> json) {
    return NoteResponseModel(
      success: json['success'] ?? false,
      total: json['total'] ?? 0,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => NoteData.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "total": total,
      "data": data.map((e) => e.toJson()).toList(),
    };
  }
}

class NoteData {
  final String id;
  final String text;

  NoteData({
    required this.id,
    required this.text,
  });

  factory NoteData.fromJson(Map<String, dynamic> json) {
    return NoteData(
      id: json['_id'] ?? '',
      text: json['text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "text": text,
    };
  }
}