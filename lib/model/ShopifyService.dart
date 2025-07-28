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
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
      error: true,
    ));
    super.onInit();
  }

  Future<Map<String, dynamic>?> createDraftOrder({
    required String customerId,
    required List<Map<String, dynamic>> lineItems,
    // String? note,
  }) async {
    try {
      print('customerId --==-=-= $customerId');
      print('lineItems --==-=-= $lineItems');
      print('dio --==-=-= $_dio');
      // print('lineItems --==-=-= $lineItems');

      if (lineItems.isEmpty) {
        print('ERROR: Line items is empty');
        Get.snackbar('Error', 'No items to add to draft order');
        return null;
      }

      for (int i = 0; i < lineItems.length; i++) {
        final item = lineItems[i];
        print('Line item $i: $item');

        if (!item.containsKey('title') || item['title'] == null || item['title'].toString().isEmpty) {
          print('ERROR: Line item $i missing title');
          Get.snackbar('Error', 'Invalid line item: missing title');
          return null;
        }
      }

      final requestData = {
        'draft_order': {
          'customer': {'id': customerId},
          'line_items': lineItems,
          // 'note': note,
        }
      };

      print('=== REQUEST DATA ===');
      print('Full request: $requestData');

      print('=== MAKING API CALL ===');
      final response = await _dio.post(
        '/draft_orders.json',
        data: requestData,
      );

      print('=== RESPONSE RECEIVED ===');
      print('Status Code: ${response.statusCode}');
      print('Status Message: ${response.statusMessage}');
      print('Response Headers: ${response.headers}');
      print('Response Data Type: ${response.data.runtimeType}');
      print('Response Data: ${response.data}');

      if (response.data != null && response.data is Map) {
        // print('Draft Order Data: ${response.data['draft_order']}');
        return response.data['draft_order'];
      } else {
        print('ERROR: Unexpected response format');
        print('Response: ${response.data}');
        return null;
      }

      // print('response ---- $response');
      // print('response.data[draft_order] -- ${response.data['draft_order']}');
      // return response.data['draft_order'];
    } on DioException catch (dioError) {
      print('=== DIO EXCEPTION ===');
      print('Error Type: ${dioError.type}');
      print('Error Message: ${dioError.message}');
      print('Status Code: ${dioError.response?.statusCode}');
      print('Response Data: ${dioError.response?.data}');
      print('Request Options: ${dioError.requestOptions}');

      // Handle specific error cases
      if (dioError.response?.statusCode == 401) {
        Get.snackbar('Error', 'Authentication failed - check access token');
      } else if (dioError.response?.statusCode == 422) {
        print('Validation Error: ${dioError.response?.data}');
        Get.snackbar('Error', 'Invalid data format');
      } else {
        Get.snackbar('Error', 'Failed to create draft order: ${dioError.message}');
      }
      return null;

    } catch (e, stackTrace) {
      print('=== GENERAL EXCEPTION ===');
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      Get.snackbar('Error', 'Failed to create draft order');
      return null;
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