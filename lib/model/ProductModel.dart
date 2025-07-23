class ProductModel {
  final String id;
  final String title;
  final String? sku;
  final String? image;
  final double price;
  final bool available;

  ProductModel({
    required this.id,
    required this.title,
    this.sku,
    this.image,
    required this.price,
    required this.available,
  });

  factory ProductModel.fromShopifyJson(Map<String, dynamic> json) {
    final variant = json['variants']['edges'].isNotEmpty
        ? json['variants']['edges'][0]['node']
        : null;

    return ProductModel(
      id: json['id'],
      title: json['title'],
      sku: variant?['sku'],
      image: json['images']['edges'].isNotEmpty
          ? json['images']['edges'][0]['node']['src']
          : null,
      price: double.tryParse(variant?['price']['amount'] ?? '0') ?? 0.0,
      available: variant?['availableForSale'] ?? false,
    );
  }
}