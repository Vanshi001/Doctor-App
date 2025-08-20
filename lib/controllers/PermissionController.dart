import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionController extends GetxController {
  // Observables to track permission status
  var cameraPermissionGranted = false.obs;
  var microphonePermissionGranted = false.obs;
  // var locationPermissionGranted = false.obs;
  var notificationPermissionGranted = false.obs;
  var isLoading = false.obs;
  var currentAddress = ''.obs;

  // Request all required permissions
  Future<void> requestAllPermissions() async {
    isLoading.value = true;

    print('requestAllPermissions');

    await requestCameraPermission();
    await requestMicrophonePermission();
    await requestNotificationPermission();
    // await requestLocationPermission();

    isLoading.value = false;
  }

  // Request Camera Permission
  Future<void> requestCameraPermission() async {
    try {
      print('requestCameraPermission');

      final status = await Permission.camera.request();
      cameraPermissionGranted.value = status.isGranted;

      if (status.isDenied) {
        Get.snackbar(
          "Camera Permission Denied",
          "Please enable camera access in settings.",
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to request camera permission: $e");
    }
  }

  // Request Microphone Permission
  Future<void> requestMicrophonePermission() async {
    try {
      print('requestMicrophonePermission');

      final status = await Permission.microphone.request();
      microphonePermissionGranted.value = status.isGranted;

      if (status.isDenied) {
        Get.snackbar(
          "Microphone Permission Denied",
          "Please enable microphone access in settings.",
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to request microphone permission: $e");
    }
  }

  // Request Notification Permission
  Future<void> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      notificationPermissionGranted.value = status.isGranted;

      if (status.isDenied) {
        Get.snackbar(
          "Notification Permission Denied",
          "Please enable notifications in settings.",
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to request notification permission: $e");
    }
  }

  // Request Location Permission
  /*Future<void> requestLocationPermission() async {
    try {
      print('requestLocationPermission');

      final status = await Permission.location.request();
      locationPermissionGranted.value = status.isGranted;

      if (status.isGranted) {
        // ✅ Permission granted → Fetch location & address
        await _fetchCurrentLocationAndAddress();
      } else if (status.isDenied) {
        Get.snackbar(
          "Location Permission Denied",
          "Please enable location access in settings.",
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to request location permission: $e");
    }
  }*/

  // Helper method to fetch location + address
  Future<void> _fetchCurrentLocationAndAddress() async {
    try {
      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          "Location Services Disabled",
          "Please enable GPS to fetch your location.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // 2. Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // 3. Reverse geocode to get address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = '';
        // String address = "${place.street}, ${place.locality}, ${place.country}";

        if (place.locality != null && place.locality!.isNotEmpty) {
          address += '${place.locality}';
        }
        if (place.country != null && place.country!.isNotEmpty) {
          address += ', ${place.country}';
        }

        // Update your observable variable (e.g., `currentAddress`)
        currentAddress.value = address;

        print("Fetched Address: $address");
        // Get.snackbar(
        //   "Location Updated",
        //   "Your address: $address",
        //   snackPosition: SnackPosition.BOTTOM,
        // );
      }
    } catch (e) {
      Get.snackbar(
        "Location Error",
        "Failed to fetch address: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Check if all permissions are granted
  bool get allPermissionsGranted {
    return cameraPermissionGranted.value &&
        microphonePermissionGranted.value &&
        notificationPermissionGranted.value; //&&
        // locationPermissionGranted.value;
  }

  // New: Platform-specific notification permission check
  Future<void> checkNotificationPermission() async {
    if (Platform.isAndroid) {
      // Android 13+ requires special handling
      if (await Permission.notification.isDenied) {
        notificationPermissionGranted.value = false;
      } else {
        notificationPermissionGranted.value = true;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.notification.status;
      notificationPermissionGranted.value = status.isGranted;
    }
  }
}