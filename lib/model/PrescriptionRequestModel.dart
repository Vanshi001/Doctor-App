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
  final String variantId;

  PrescriptionItem({required this.medicineName, required this.notes, required this.variantId});

  Map<String, dynamic> toJson() {
    return {'medicineName': medicineName, 'notes': notes, 'variantId': variantId};
  }
}
