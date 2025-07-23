// services/shopify_service.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class ShopifyService extends GetxService {
  final Dio _dio = Dio();

  @override
  void onInit() {
    _dio.options.baseUrl = 'https://dermatics-in.myshopify.com/admin/api/2024-01';
    _dio.options.headers = {
      'X-Shopify-Access-Token': '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',
      'Content-Type': 'application/json',
    };
    super.onInit();
  }

  Future<Map<String, dynamic>?> createDraftOrder({
    required String customerId,
    required List<Map<String, dynamic>> lineItems,
    String? note,
  }) async {
    try {
      final response = await _dio.post(
        '/draft_orders.json',
        data: {
          'draft_order': {
            'customer': {'id': customerId},
            'line_items': lineItems,
            'note': note,
          }
        },
      );
      return response.data['draft_order'];
    } catch (e) {
      Get.snackbar('Error', 'Failed to create draft order');
      return null;
    }
  }

  final selectedCustomerId = RxString('');
  final selectedItems = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final ShopifyService _shopifyService = Get.find();

  Future<void> submitDraftOrder({String? note}) async {
    if (selectedCustomerId.isEmpty) {
      Get.snackbar('Error', 'Please select a customer');
      return;
    }

    if (selectedItems.isEmpty) {
      Get.snackbar('Error', 'Please add at least one product');
      return;
    }

    isLoading(true);
    try {
      final result = await _shopifyService.createDraftOrder(
        customerId: selectedCustomerId.value,
        lineItems: selectedItems.toList(),
        note: note,
      );

      if (result != null) {
        Get.snackbar('Success', 'Draft order created successfully!');
        // clearForm();
      }
    } finally {
      isLoading(false);
    }
  }


  Future<List<Map<String, dynamic>>> getCustomers() async {
    try {
      final response = await _dio.get('/customers.json');
      return (response.data['customers'] as List).cast<Map<String, dynamic>>();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch customers');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await _dio.get('/products.json');
      return (response.data['products'] as List).cast<Map<String, dynamic>>();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch products');
      return [];
    }
  }
}