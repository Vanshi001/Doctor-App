import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  var isLoading = false.obs;

  final Future _prefs = SharedPreferences.getInstance();

  static const String createCustomerMutation = r'''
mutation createCustomerAccount($input: CustomerCreateInput!) {
  customerCreate(input: $input) {
    customer {
      id
      email
      firstName
      lastName
      phone
    }
    customerUserErrors {
      code
      field
      message
    }
  }
}
''';

  /*Future<void> createCustomer() async {
    isLoading.value = true;

    final HttpLink httpLink = HttpLink(
      ApiEndPoints.baseUrl,
      defaultHeaders: {
        'X-Shopify-Storefront-Access-Token':
        Constants.shopify_access_token.trim(),
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    final ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(link: httpLink, cache: GraphQLCache()),
    );

    final MutationOptions options = MutationOptions(
      document: gql(createCustomerMutation),
      variables: {
        "input": {
          "firstName": firstNameController.text.trim(),
          "lastName": lastNameController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
          "phone": "+91${phoneController.text.trim()}",
        },
      },
    );

    final QueryResult result = await client.value.mutate(options);

    if (result.hasException) {
      final gqlErrors = result.exception?.graphqlErrors;
      if (gqlErrors != null && gqlErrors.isNotEmpty) {
        final errorCode = gqlErrors.first.extensions?['code'];
        if (errorCode == 'THROTTLED') {
          print("Rate limited. Waiting to retry...");
          await Future.delayed(Duration(seconds: 5)); // simple retry logic
          return createCustomer(); // retry once
        } else {
          print("GraphQL Error: ${result.exception.toString()}");
          return;
        }
      }

      // 2. Handle network or other exceptions
      final linkException = result.exception?.linkException;
      if (linkException != null) {
        print("Network Error: ${linkException.toString()}");
        showError("Network Error: Please check your connection.");
        return;
      }

      // 3. Fallback
      print("Unknown error occurred: ${result.exception.toString()}");
      showError("Something went wrong. Please try again.");
      return;
    }

    final customerData = result.data?['customerCreate'];
    final errors = customerData?['customerUserErrors'];

    if (errors != null && errors.isNotEmpty) {
      final customerData = result.data?['customerCreate'];
      final errors = customerData?['customerUserErrors'];

      if (errors != null && errors.isNotEmpty) {
        for (var error in errors) {
          final message = error['message'];
          print("User Error: $message");
          showError(message);
        }
      } else {
        print("Customer Created:-- ${customerData['customer']}");
      }
      isLoading.value = false;
    } else {
      print("Customer Created: ${customerData['customer']}");
      isLoading.value = false;
      showSuccess("Customer Created!");
      Get.offAll(() => NavigationScreen());
    }
  }*/

  /*Future registerWithEmail() async {
    isLoading.value = true;
    try {
      var headers = {
        'Content-Type': 'application/json',
        'X-Shopify-Access-Token': Constants.shopify_access_token,
      };
      Map<String, dynamic> body = {
        "customer": {
          "first_name": firstNameController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        },
      };
      http.Response response = await http.post(
        Uri.parse(Constants.shopify_customer_url),
        body: jsonEncode(body),
        headers: headers,
      );
      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        if (json.containsKey('customer')) {
          final customer = json['customer'];
          print('Customer Created: ${customer['id']}');
          Get.offAll(HomeScreen());
        } else {
          final errors = json['errors'] ?? "Unknown error.";
          print("SignUpController = ERROR 1 -- $errors");
          throw errors;
        }
      } else {
        final error = jsonDecode(response.body);
        print("SignUpController = ERROR 2 -- ${error["errors"]}");
        throw error["errors"] ?? "Unknown error occurred2.";
      }
      isLoading.value = false;
    } catch (e) {
      Get.back();
      if (kDebugMode) {
        print("SignUpController = ERROR 3 -- $e");
      }
      isLoading.value = false;
      showDialog(
        context: Get.context!,
        builder: (context) {
          return SimpleDialog(
            title: Text('Error'),
            contentPadding: EdgeInsets.all(20),
            children: [Text(e.toString())],
          );
        },
      );
    }
  }*/

  bool validateFields() {
    if (nameController.text
        .trim()
        .isEmpty) {
      showError("First Name is required");
      return false;
    } else if (lastNameController.text
        .trim()
        .isEmpty) {
      showError("Last Name is required");
      return false;
    } else if (emailController.text
        .trim()
        .isEmpty) {
      showError("Email is required");
      return false;
    } else if (!GetUtils.isEmail(emailController.text.trim())) {
      showError("Enter a valid email");
      return false;
    } else if (passwordController.text.isEmpty) {
      showError("Password is required");
      return false;
    } else if (passwordController.text.length < 6) {
      showError("Password must be at least 6 characters");
      return false;
    } else if (phoneController.text
        .trim()
        .isEmpty) {
      showError("Phone is required");
      return false;
    } else if (phoneController.text.length < 10) {
      showError("Phone must be at lease 10 digits");
      return false;
    }
    return true;
  }

  void showError(String message) {
    Get.snackbar(
      "Validation Error",
      message,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void showSuccess(String message) {
    Get.snackbar(
      "Successful!",
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
