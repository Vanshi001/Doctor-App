class PrescriptionRequestModel {
  final List<PrescriptionItem> prescriptions;

  PrescriptionRequestModel({required this.prescriptions});

  Map<String, dynamic> toJson() {
    return {'prescriptions': prescriptions.map((p) => p.toJson()).toList()};
  }
}

class PrescriptionItem {
  final String medicineName;
  final String notes;

  PrescriptionItem({required this.medicineName, required this.notes});

  Map<String, dynamic> toJson() {
    return {'medicineName': medicineName, 'notes': notes};
  }
}
