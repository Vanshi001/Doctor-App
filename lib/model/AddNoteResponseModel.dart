class AddNoteResponseModel {
  final bool success;
  final List<NoteModel> data;

  AddNoteResponseModel({
    required this.success,
    required this.data,
  });

  factory AddNoteResponseModel.fromJson(Map<String, dynamic> json) {
    return AddNoteResponseModel(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => NoteModel.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "data": data.map((e) => e.toJson()).toList(),
    };
  }
}

class NoteModel {
  final String id;
  final String text;

  NoteModel({
    required this.id,
    required this.text,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
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