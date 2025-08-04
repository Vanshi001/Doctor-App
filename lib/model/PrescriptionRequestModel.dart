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
  final String productId;
  final String compareAtPrice;
  final String price;
  final String image;

  PrescriptionItem({
    required this.medicineName,
    required this.notes,
    required this.variantId,
    required this.productId,
    required this.compareAtPrice,
    required this.price,
    required this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'medicineName': medicineName,
      'notes': notes,
      'variantId': variantId,
      'productId': productId,
      'compareAtPrice': compareAtPrice,
      'price': price,
      'image': image,
    };
  }
}
