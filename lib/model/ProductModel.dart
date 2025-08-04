class ProductModel {
  final String id;
  final String title;
  final String? sku;
  final String? image;
  final String? variantId;
  final String productId;
  final String compareAtPrice;
  final double price;
  final bool available;

  ProductModel({
    required this.id,
    required this.title,
    this.sku,
    this.image,
    this.variantId,
    required this.productId,
    required this.compareAtPrice,
    required this.price,
    required this.available,
  });

  factory ProductModel.fromShopifyJson(Map<String, dynamic> json) {
    final variant = json['variants']['edges'].isNotEmpty
        ? json['variants']['edges'][0]['node']
        : null;

    final variantId = variant?["id"];

    final price = double.tryParse(variant?['price']['amount'] ?? '0') ?? 0.0;
    final compareAtPrice = variant?['compareAtPrice']?['amount']?.toString() ?? price.toString();
    final productId = json['id'];

    return ProductModel(
      id: json['id'],
      title: json['title'],
      sku: variant?['sku'],
      image: json['images']['edges'].isNotEmpty
          ? json['images']['edges'][0]['node']['src']
          : null,
      variantId: variantId,
      productId: productId,
      compareAtPrice: compareAtPrice,
      price: price,
      available: variant?['availableForSale'] ?? false,
    );
  }
}