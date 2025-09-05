import 'dart:convert';
import 'package:Doctor/widgets/Constants.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class UpdateController extends GetxController {
  RxBool isUpdateAvailable = false.obs;
  RxBool forceUpdate = false.obs;
  RxString latestVersion = "".obs;
  RxString releaseNotes = "".obs;
  RxString playStoreUrl = "".obs;
  RxString latestBuildNumber = "".obs;

  Future<void> checkAppUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; // e.g. "1.0.1"
      final currentBuildNumber = int.parse(packageInfo.buildNumber); // e.g. 2
      print('currentVersion(currentBuildNumber) ----> $currentVersion($currentBuildNumber)');

      // 👉 Point this to your backend API
      final response = await http.get(Uri.parse("${Constants.baseUrl}app-version"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('DATA ----> $data');

        latestVersion.value = data["latest_version"];     // e.g. "1.0.1"
        latestBuildNumber.value = data["latest_build_version"]; // e.g. "3"
        releaseNotes.value = "Please update the app's new version.";
        playStoreUrl.value = data["android_url"];
        // forceUpdate.value = data["forceUpdate"];

        // 🔍 Compare version + build
        if (_isNewerVersion(
          latestVersion.value,
          currentVersion,
          latestBuildNumber.value,
          currentBuildNumber,
        )) {
          isUpdateAvailable.value = true;
        }
      }
    } catch (e) {
      print("Update check error: $e");
    }
  }

  bool _isNewerVersion(
      String storeVersion, String localVersion, String storeBuild, int localBuild) {
    List<int> s = storeVersion.split('.').map(int.parse).toList();
    List<int> l = localVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < s.length; i++) {
      if (s[i] > l[i]) return true;
      if (s[i] < l[i]) return false;
    }

    // ✅ Versions equal → compare build numbers (parse here)
    int storeBuildInt = int.tryParse(storeBuild) ?? 0;
    return storeBuildInt > localBuild;
  }

  Future<void> launchUpdate() async {
    if (await canLaunchUrl(Uri.parse(playStoreUrl.value))) {
      await launchUrl(Uri.parse(playStoreUrl.value),
          mode: LaunchMode.externalApplication);
    }
  }
}
