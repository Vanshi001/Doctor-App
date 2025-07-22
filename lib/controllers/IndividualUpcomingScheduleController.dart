import 'dart:convert';

import 'package:Doctor/model/PrescriptionRequestModel.dart';
import 'package:Doctor/model/appointment_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

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

  final List<Map<String, dynamic>> shopByCategoryList = [];
  Future<void> fetchShopifyProducts() async {
    final url = Uri.parse('https://dermatics-in.myshopify.com/api/2025-04/graphql.json');

    const String query = '''
query GetProductsByCategory {
  products(first: 20, reverse: true, query: "status:'active'") {
    edges {
      node {
        title
        productType
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
      body: json.encode({'query': query}),
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

      final products = jsonData["data"]["products"]["edges"] as List;
      // prettyPrintJson(jsonData);

      shopByCategoryList.clear();
      for (var edge in products) {
        final node = edge["node"];
        final image = node["images"]["edges"].isNotEmpty ? node["images"]["edges"][0]["node"]["src"] : "";
        final variant = node["variants"]["edges"].isNotEmpty ? node["variants"]["edges"][0]["node"] : null;

        final variantId = variant?["id"];
        final price = variant?["price"]?["amount"];
        final compareAt = variant?["compareAtPrice"]?["amount"];

        final double parsedPrice = price != null ? double.tryParse(price) ?? 0.0 : 0.0;
        final double parsedCompareAt = compareAt != null ? double.tryParse(compareAt) ?? 0.0 : 0.0;

        // print('availableForSale ------------------------- ${variant?['availableForSale']} - ${node["title"]}');

        shopByCategoryList.add({
          "id": node["id"],
          "image": image ?? '',
          "title": node["title"],
          "price": parsedPrice,
          "compareAtPrice": parsedCompareAt,
          "availableForSale": variant?['availableForSale'],
          "variantId": variantId,
        });
      }
    } else {
      print("❌ Failed to fetch products: ${response.statusCode} ${response.body}");
    }
  }

}
