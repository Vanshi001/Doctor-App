import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../model/PrescriptionRequestModel.dart';
import '../model/ProductModel.dart';
import '../widgets/Constants.dart';

class AddPendingMedicineController extends GetxController {

  final medicineNameController = TextEditingController();
  final descriptionController = TextEditingController();
  String? variantId;
  String? productId;
  String? compareAtPrice;
  String? price;
  String? image;

  var medicines = <Map<String, String>>[].obs;

  final List<GlobalKey> itemKeys = [];

  void addMedicine() {
    final name = medicineNameController.text.trim();
    final description = descriptionController.text.trim();

    if (name.isNotEmpty && description.isNotEmpty) {
      medicines.add({
        "medicineName": name,
        "notes": description,
        "variantId": variantId.toString(),
        "productId": productId.toString(),
        "compareAtPrice": compareAtPrice.toString(),
        "price": price.toString(),
        "image": image.toString(),
      });
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
    final url = Uri.parse('${Constants.baseUrl}appointments/$id/prescription');
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

        // await _addPrescriptionsToDraft(prescriptionList);

        // Submit draft order with medicines
        // await _submitDraftOrder();
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

  void selectProduct(ProductModel product) {
    selectedProduct.value = product;
    medicineNameController.text = product.title;
    variantId = product.variantId;
    productId = product.productId;
    compareAtPrice = product.compareAtPrice;
    price = product.price.toString();
    image = product.image;
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

}