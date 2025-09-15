import 'dart:async';
import 'dart:convert';

import 'package:Doctor/model/CallHistoryResponseModel.dart';
import 'package:Doctor/model/PrescriptionRequestModel.dart';
import 'package:Doctor/model/appointment_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/ProductModel.dart';
import '../model/ShopifyService.dart';
import '../model/SingleAppointmentDetailModel.dart';
import '../widgets/Constants.dart';
import 'auth/AuthController.dart';

class IndividualUpcomingScheduleController extends GetxController {
  final medicineNameController = TextEditingController();
  final descriptionController = TextEditingController();
  String? variantId;
  String? productId;
  String? compareAtPrice;
  String? price;
  String? image;

  var medicines = <Map<String, String>>[].obs;

  final List<GlobalKey> itemKeys = [];

  String getInitials(String firstName) {
    if (firstName.isEmpty) return '';
    String firstInitial = firstName.isNotEmpty ? firstName[0] : '';
    return firstInitial.toUpperCase();
  }

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
    print("add medicine url === $url");

    try {
      final prescriptionList = prescriptions is PrescriptionItem ? [prescriptions] : prescriptions as List<PrescriptionItem>;

      final prescriptionRequest = PrescriptionRequestModel(prescriptions: prescriptionList);

      final body = jsonEncode(prescriptionRequest.toJson());

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      print('token =====~~~~ $token');

      final response = await http.post(url, headers: {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': 'Bearer $token'}, body: body);
      // print('response.body -- ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Add Medicine responseData: $responseData');

        // await _addPrescriptionsToDraft(prescriptionList);

        // Submit draft order with medicines
        // await _submitDraftOrder();
        // Get.back();

        // 🚀 No need to close manually, new snackbar overrides old one
        Get.snackbar(
          "Success",
          "Medicine added successfully",
          snackPosition: SnackPosition.BOTTOM,
        );

        if (Get.isDialogOpen == true) {
          Navigator.of(Get.context!).pop(true);
        } else if (Get.isBottomSheetOpen == true) {
          Navigator.of(Get.context!).pop(true);
        } else if (Get.key.currentState?.canPop() ?? false) {
          Navigator.of(Get.context!).pop(true);
        }

      } else {
        print('token =====~~~~ ELSE ----> $token');

        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'];
        print('errorMessage --> $errorMessage');
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

  final selectedItems = <Map<String, dynamic>>[].obs;

  void addProductToDraft({required String variantId, required int quantity, required double price}) {
    selectedItems.add({'variant_id': variantId, 'quantity': quantity, 'price': price});
  }

  final selectedCustomerId = RxString('');
  final selectedDraftItems = <Map<String, dynamic>>[].obs;

  // final isLoading = false.obs;
  final ShopifyService _shopifyService = Get.put(ShopifyService());

  Future<void> submitDraftOrder(/*{String? note}*/) async {
    print('selectedCustomerId -- $selectedCustomerId');
    if (selectedCustomerId.isEmpty) {
      Get.snackbar('Error', 'Please select a customer');
      print('Error ~~ selectedCustomerId is empty');
      return;
    }

    print('selectedDraftItems -- $selectedDraftItems');
    if (selectedDraftItems.isEmpty) {
      Get.snackbar('Error', 'Please add at least one product');
      print('Error ~~ Please add at least one product in draft');
      return;
    }

    isLoading(true);
    try {
      final result = await _shopifyService.createDraftOrder(
        customerId: selectedCustomerId.value,
        lineItems: selectedDraftItems.toList(),
        // note: note,
      );

      print('result -- $result');
      if (result != null) {
        Get.snackbar('Success', 'Draft order created successfully!');
        // clearForm();
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> _addPrescriptionsToDraft(List<PrescriptionItem> prescriptions) async {
    selectedDraftItems.clear(); // Clear existing items

    for (final prescription in prescriptions) {
      // Convert each prescription to draft item format
      final draftItem = {
        // 'product_id': prescription.medicineId, // Assuming medicineId maps to Shopify product ID
        'variant_id': prescription.variantId, // If you have variant ID
        'quantity': 1,
        'title': prescription.medicineName,
        'product_id': prescription.productId,
        'image': prescription.image,
        'price': prescription.price?.toString() ?? '0.00',
        'compareAtPrice': prescription.compareAtPrice?.toString() ?? '0.00',
        // Add any additional fields required by Shopify
        // 'properties': {
        //   'dosage': prescription.dosage,
        //   'frequency': prescription.frequency,
        //   'duration': prescription.duration,
        //   'instructions': prescription.instructions,
        // }
      };

      selectedDraftItems.add(draftItem);
      print('Added to draft: ${prescription.medicineName}');
    }

    print('Total draft items: ${selectedDraftItems.length}');
  }

  // Alternative method if you want to add medicines separately
  //   Future<void> addMedicineToExistingDraft({
  //     required PrescriptionItem prescription,
  //     required String customerId,
  //   }) async {
  //     // Set customer ID if not already set
  //     if (selectedCustomerId.value != customerId) {
  //       selectedCustomerId.value = customerId;
  //     }
  //
  //     // Check if medicine already exists in draft
  //     final existingItemIndex = selectedDraftItems.indexWhere(
  //             (item) => item['product_id'] == prescription.medicineId
  //     );
  //
  //     if (existingItemIndex != -1) {
  //       // Update quantity if item exists
  //       final currentQuantity = int.parse(selectedDraftItems[existingItemIndex]['quantity'].toString());
  //       selectedDraftItems[existingItemIndex]['quantity'] = currentQuantity + (prescription.quantity ?? 1);
  //       print('Updated quantity for ${prescription.medicineName}');
  //     } else {
  //       // Add new item
  //       final draftItem = {
  //         'product_id': prescription.medicineId,
  //         'variant_id': prescription.variantId,
  //         'quantity': prescription.quantity ?? 1,
  //         'title': prescription.medicineName,
  //         'price': prescription.price?.toString() ?? '0.00',
  //         'properties': {
  //           'dosage': prescription.dosage,
  //           'frequency': prescription.frequency,
  //           'duration': prescription.duration,
  //           'instructions': prescription.instructions,
  //         }
  //       };
  //
  //       selectedDraftItems.add(draftItem);
  //       print('Added new medicine to draft: ${prescription.medicineName}');
  //     }
  //   }

  // Method to manually submit draft with current medicines
  Future<void> submitMedicinesDraft() async {
    if (selectedCustomerId.isEmpty) {
      Get.snackbar('Error', 'Customer ID is required');
      return;
    }

    if (selectedDraftItems.isEmpty) {
      Get.snackbar('Error', 'No medicines added to draft');
      return;
    }

    await submitDraftOrder();
  }

  // Clear draft items (call this after successful submission or when needed)
  void clearDraftItems() {
    selectedDraftItems.clear();
    selectedCustomerId.value = '';
    print('Draft items cleared');
  }

  // Updated submitDraftOrder method with better error handling
  Future<void> _submitDraftOrder() async {
    print('selectedCustomerId -- $selectedCustomerId');
    if (selectedCustomerId.isEmpty) {
      Get.snackbar('Error', 'Please select a customer');
      print('Error ~~ selectedCustomerId is empty');
      return;
    }

    print('selectedDraftItems -- $selectedDraftItems');
    if (selectedDraftItems.isEmpty) {
      Get.snackbar('Error', 'Please add at least one product');
      print('Error ~~ Please add at least one product in draft');
      return;
    }

    isLoading(true);
    try {
      final result = await _shopifyService.createDraftOrder(customerId: selectedCustomerId.value, lineItems: selectedDraftItems.toList());

      print('Draft order result -- $result');
      if (result != null) {
        Get.snackbar('Success', 'Draft order created successfully with ${selectedDraftItems.length} medicines!');
        // initializeCart();
        // 2. Then create a cart for this specific customer
        print('lineItems -- ${selectedDraftItems.toList()}');

        final customerCartId = await createCustomerCart(
          customerAccessToken: 'fe4e37203ac97bf9a33ec556b5eeba88',
          /* vanshi user */
          lineItems: selectedDraftItems.toList(),
        );

        if (customerCartId != null) {
          cartId.value = customerCartId;
          print('cartId.value -- ${cartId.value}');
          Get.snackbar('Success', 'Cart created for customer!');
        }

        clearDraftItems(); // Clear after successful submission
      } else {
        Get.snackbar('Error', 'Failed to create draft order');
      }
    } catch (e) {
      print('Error creating draft order: $e');
      Get.snackbar('Error', 'Failed to create draft order: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<String?> createCustomerCart({required String customerAccessToken, required List<Map<String, dynamic>> lineItems}) async {
    try {
      const mutation = r'''
      mutation createCustomerCart($input: CartInput!) {
        cartCreate(input: $input) {
          cart {
            id
            checkoutUrl
            createdAt
          }
        }
      }
    ''';

      // Convert line items to cart line items format
      print('lineItems -- $lineItems');
      // final cartLines = lineItems.map((item) => {'merchandiseId': item['variant_id'].toString(), 'quantity': item['quantity']}).toList();

      final cartLines =
          lineItems.map((item) {
            final variantId = item['variant_id'].toString();
            // Extract just the numeric ID from the Global ID
            final numericId = variantId.split('/').last;

            return {
              'merchandiseId': numericId, // Use just the numeric ID
              'quantity': item['quantity'],
            };
          }).toList();

      print('Processed cartLines: $cartLines');

      final client = GraphQLClient(
        link: HttpLink(
          'https://dermatics-in.myshopify.com/api/2023-07/graphql.json',
          defaultHeaders: {'X-Shopify-Storefront-Access-Token': '1e5f786dc58ad552b19a218ac59889d5'},
        ),
        cache: GraphQLCache(),
      );

      final result = await client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'input': {
              'lines': cartLines,
              'attributes': [
                {'key': 'customer_id', 'value': customerAccessToken},
              ],
            },
          },
        ),
      );

      if (result.hasException) {
        print('result.hasException -- ${result.hasException}');
        throw Exception(result.exception.toString());
      }

      print('result.data?[cartCreate][cart][id] -- ${result.data?['cartCreate']['cart']['id']}');
      final cartId = result.data?['cartCreate']['cart']['id'];
      print('Successfully created cart with ID: $cartId');
      return cartId;
      // return result.data?['cartCreate']['cart']['id'];
    } catch (e) {
      print('Error creating customer cart: $e');
      return null;
    }
  }

  var cartId = ''.obs;

  Future<void> initializeCart() async {
    try {
      isLoading(true);
      final newCartId = await createBlankCart();
      if (newCartId != null) {
        cartId.value = newCartId;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create cart');
    } finally {
      isLoading(false);
    }
  }

  Future<String?> createBlankCart() async {
    try {
      const mutation = '''
      mutation CreateCart {
        cartCreate(input: { lines: [] }) {
          cart {
            id
            checkoutUrl
          }
        }
      }
    ''';

      final httpLink = HttpLink(
        'https://dermatics-in.myshopify.com/api/2023-07/graphql.json',
        defaultHeaders: {'X-Shopify-Storefront-Access-Token': '1e5f786dc58ad552b19a218ac59889d5'},
      );

      final GraphQLClient _client = GraphQLClient(cache: GraphQLCache(), link: httpLink);

      final result = await _client.mutate(MutationOptions(document: gql(mutation)));

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data?['cartCreate']['cart']['id'];
    } catch (e) {
      print('Error creating cart: $e');
      return null;
    }
  }

  final Appointment? item;

  IndividualUpcomingScheduleController(this.item);

  RxBool isCallButtonEnabled = false.obs;
  Timer? _timeCheckTimer;

  @override
  void onInit() {
    super.onInit();
    if (item != null) {
      // _setupTimeChecker();
    }
  }

  @override
  void onClose() {
    _timeCheckTimer?.cancel();
    super.onClose();
  }

  // final RxList<Map<String, dynamic>> callHistory = <Map<String, dynamic>>[].obs;
  // final RxBool hasCallHistory = false.obs;

  // var isLoadingCallHistory = false.obs;
  var callHistoryData = Rxn<CallHistoryData>();
  var callHistoryStatus = false.obs; // 👈 will be true if API status is true

  var isLoadingAppointmentData = false.obs;
  Rxn<AppointmentDetailData> appointmentData = Rxn<AppointmentDetailData>();
  // Rxn<AppointmentDetailDataWithoutCallHistory> appointmentDataWithoutCallHistory = Rxn<AppointmentDetailDataWithoutCallHistory>();

  var callDuration = 0.obs;

  Future<void> callHistoryApi(Map<String, String?> callLog, String? appointmentId) async {

    // ✅ Don't call API if user is logged out
    // if (AuthController.isLoggedIn.value) {
    //   print("User logged out. API not called.");
    //   return;
    // }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    print('token -- $token');

    // isLoadingCallHistory.value = true;
    // final url = Uri.parse('http://192.168.1.10:5000/api/doctors/request');
    final url = Uri.parse('${Constants.baseUrl}appointments/$appointmentId/call-history');

    print('url -- $url');

    final data = callLog;

    print(data);

    try {
      final response = await http.post(url, headers: {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': 'Bearer $token'}, body: jsonEncode(data));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('responseData -- $responseData');
        // ✅ check if status is true
        final status = responseData['success'] ?? false;
        callHistoryStatus.value = status;
        print('status -- $status');
        print('callHistoryStatus.value -- ${callHistoryStatus.value}');

        if (status) {
          Constants.showSuccess("Success");

          // save data in observable
          callHistoryData.value = CallHistoryData.fromJson(responseData);
          update();
          fetchAppointmentByIdApi(appointmentId.toString());
          Get.back();
        } else {
          print('Error errorMessage:-- ${responseData['message']}');
          Constants.showCallHistoryError(responseData['message'] ?? "Failed");
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? "Something went wrong!";
        print('Error errorMessage: $errorMessage');
        callHistoryStatus.value = false;
        Constants.showCallHistoryError(errorMessage);
      }
    } catch (e) {
      print('Error: $e');
      callHistoryStatus.value = false;
      Constants.showCallHistoryError("Error -- $e");
    } finally {
      callHistoryStatus.value = false;
      // isLoadingCallHistory.value = false;
    }
  }

  Future<void> fetchAppointmentByIdApi(String appointmentId) async {

    // ✅ Don't call API if user is logged out
    // if (AuthController.isLoggedIn.value) {
    //   print("User logged out. API not called.");
    //   return;
    // }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    print('token -+=~~~~~~~~~~~~~~=+- $token');

    isLoadingAppointmentData.value = true;
    // final url = Uri.parse('http://192.168.1.10:5000/api/appointments');
    final url = Uri.parse('${Constants.baseUrl}appointments/$appointmentId');
    print('url ---=== $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        isLoadingAppointmentData.value = false;
        final responseData = jsonDecode(response.body);

        print('fetchAppointmentByIdApi Appointments: $responseData');

        final appointmentDetails = SingleAppointmentDetailModel.fromJson(responseData);
        print('appointmentData.value ---=== ${appointmentDetails.data}');
        appointmentData.value = appointmentDetails.data;
        callDuration.value = appointmentDetails.data?.callHistory?.duration ?? 0;
        print('callDuration.value -- ${callDuration.value}');
        // final message = responseData['message'] ?? 'Success';
        // Constants.showSuccess(message);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? "Login failed";
        print('fetchAppointmentByIdApi errorMessage ---- $errorMessage');
        Constants.showError(errorMessage);
      }
    } catch (e) {
      print('Error fetchAppointmentByIdApi: $e');
      Constants.showError("Error -- $e");
    } finally {
      isLoadingAppointmentData.value = false;
    }
  }

  /*Future<void> fetchAppointmentByIdApiWithoutCallHistory(String appointmentId) async {
    final authController = Get.put(AuthController());

    // ✅ Don't call API if user is logged out
    if (AuthController.isLoggedIn.value) {
      print("User logged out. API not called.");
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    print('token -+=~~~~~~~~~~~~~~=+- $token');

    isLoadingAppointmentData.value = true;
    // final url = Uri.parse('http://192.168.1.10:5000/api/appointments');
    final url = Uri.parse('${Constants.baseUrl}appointments/$appointmentId');
    print('url ---=== $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        isLoadingAppointmentData.value = false;
        final responseData = jsonDecode(response.body);

        // print('Appointments: $responseData');

        final appointmentDetails = SingleAppointmentDetailModelWithoutCallHistory.fromJson(responseData);
        print('appointmentData.value ---=== ${appointmentDetails.data}');
        appointmentDataWithoutCallHistory.value = appointmentDetails.data;
        // callDuration.value = appointmentDetails.data?.callHistory?.duration ?? 0;
        // print('callDuration.value -- ${callDuration.value}');
        // final message = responseData['message'] ?? 'Success';
        // Constants.showSuccess(message);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? "Login failed";
        print('fetchAppointmentByIdApi errorMessage ---- $errorMessage');
        Constants.showError(errorMessage);
      }
    } catch (e) {
      print('Error fetchAppointmentByIdApi: $e');
      Constants.showError("Error -- $e");
    } finally {
      isLoadingAppointmentData.value = false;
    }
  }*/
}

class LineItem {
  final String variantId;
  final int quantity;
  final double price;

  LineItem({required this.variantId, required this.quantity, required this.price});

  Map<String, dynamic> toJson() {
    return {'variant_id': variantId, 'quantity': quantity, 'price': price};
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
