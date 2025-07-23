import 'dart:convert';

import 'package:Doctor/model/PrescriptionRequestModel.dart';
import 'package:Doctor/model/appointment_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../model/ProductModel.dart';

class IndividualUpcomingScheduleController extends GetxController {
  final medicineNameController = TextEditingController();
  final descriptionController = TextEditingController();

  var medicines = <Map<String, String>>[].obs;

  final List<GlobalKey> itemKeys = [];

  void addMedicine() {
    final name = medicineNameController.text.trim();
    final description = descriptionController.text.trim();

    if (name.isNotEmpty) {
      medicines.add({"medicineName": name, "notes": description});
      medicineNameController.clear();
      descriptionController.clear();
      itemKeys.add(GlobalKey());
    }
  }

  void removeMedicine(int index) {
    medicines.removeAt(index);
    itemKeys.removeAt(index);
  }

  var isLoading = false.obs;

  Future<void> addMedicineApi({required String id, required dynamic prescriptions}) async {
    isLoading.value = true;
    final url = Uri.parse('http://192.168.1.21:5000/api/appointments/$id/prescription');
    print("add medicine url == $url");

    try {
      final prescriptionList = prescriptions is PrescriptionItem ? [prescriptions] : prescriptions as List<PrescriptionItem>;

      final prescriptionRequest = PrescriptionRequestModel(prescriptions: prescriptionList);

      final body = jsonEncode(prescriptionRequest.toJson());

      final response = await http.post(url, headers: {'Content-Type': 'application/json', 'accept': 'application/json'}, body: body);
      print('response.body -- ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Add Medicine responseData: $responseData');
        Get.back();
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'];
        print('errorMessage --$errorMessage');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  final shopifyProducts = <ProductModel>[].obs;
  final selectedProduct = Rx<ProductModel?>(null);
  var searchQuery = ''.obs;

  // final shopByCategoryList = <Map<String, dynamic>>[].obs;
  Future<void> fetchShopifyProducts() async {
    String? cursor;
    final allProducts = <ProductModel>[];

    final url = Uri.parse('https://dermatics-in.myshopify.com/api/2025-04/graphql.json');
    do {
      const String query = '''
query GetProducts(\$cursor: String) {
  products(first: 250, after: \$cursor, query: "status:'active'") {
    edges {
      cursor
      node {
        title
        createdAt
        id
        images(first: 10) {
          edges {
            node {
              src
            }
          }
        }
        description
        featuredImage {
          src
        }
        variants(first: 10) {
          edges {
            node {
              id
              availableForSale
              price {
                amount
                currencyCode
              }
              compareAtPrice {
                amount
                currencyCode
              }
            }
          }
        }
      }
    }
    pageInfo {
      hasPreviousPage
      hasNextPage
    }
  }
}
''';

      final response = await http.post(
        url,
        headers: {
          'X-Shopify-Storefront-Access-Token': '1e5f786dc58ad552b19a218ac59889d5',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'query': query,
          'variables': {'cursor': cursor},
        }),
      );

      // print("Token: [${Constants.shopify_access_token.trim()}]");
      // print("Url: $url");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // ✅ Check for GraphQL errors
        if (jsonData["errors"] != null) {
          print("❌ GraphQL Errors: ${jsonData["errors"]}");
          return;
        }

        // ✅ Check if 'data' and 'products' exist
        if (jsonData["data"] == null || jsonData["data"]["products"] == null) {
          print("❌ No data/products found. Full response:\n${json.encode(jsonData)}");
          return;
        }

        final edges = jsonData['data']['products']['edges'] as List;
        if (edges.isEmpty) break;

        allProducts.addAll(edges.map((e) => ProductModel.fromShopifyJson(e['node'])).toList());

        cursor = edges.last['cursor'];
        final hasNextPage = jsonData['data']['products']['pageInfo']['hasNextPage'];

        if (!hasNextPage) break;

        /*final products = (jsonData['data']['products']['edges'] as List)
            .map((e) => ProductModel.fromShopifyJson(e['node']))
            .toList();

        shopifyProducts.assignAll(products);*/
      } else {
        print("❌ Failed to fetch products: ${response.statusCode} ${response.body}");
        break;
      }
    } while (true);
    shopifyProducts.assignAll(allProducts);
  }

  void selectProduct(ProductModel product) {
    selectedProduct.value = product;
    medicineNameController.text = product.title;
  }

  Future<void> loadProducts() async {
    isLoading(true);
    try {
      await fetchShopifyProducts();
    } catch (e) {
      print('Error loading products: $e');
    } finally {
      isLoading(false);
    }
  }

  final selectedItems = <Map<String, dynamic>>[].obs;
  void addProductToDraft({
    required String variantId,
    required int quantity,
    required double price,
  }) {
    selectedItems.add({
      'variant_id': variantId,
      'quantity': quantity,
      'price': price,
    });
  }
}

class LineItem {
  final String variantId;
  final int quantity;
  final double price;

  LineItem({
    required this.variantId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'variant_id': variantId,
      'quantity': quantity,
      'price': price,
    };
  }
}

class ShopifyProduct {
  final String id;
  final String title;
  final String image;
  final double price;
  final double compareAtPrice;
  final bool availableForSale;
  final String variantId;

  ShopifyProduct({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    required this.compareAtPrice,
    required this.availableForSale,
    required this.variantId,
  });

  factory ShopifyProduct.fromJson(Map<String, dynamic> json) {
    return ShopifyProduct(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      price: json['price'] ?? 0.0,
      compareAtPrice: json['compareAtPrice'] ?? 0.0,
      availableForSale: json['availableForSale'] ?? false,
      variantId: json['variantId'] ?? '',
    );
  }
}
