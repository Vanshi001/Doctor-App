import 'package:Doctor/screens/AuthScreen.dart';
import 'package:Doctor/screens/MainScreen.dart';
import 'package:Doctor/widgets/CallService.dart';
import 'package:Doctor/widgets/ColorCodes.dart';
import 'package:Doctor/widgets/Constants.dart';
import 'package:Doctor/zegocloud/common.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'controllers/NetworkController.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final fcmToken = await FirebaseMessaging.instance.getToken();
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    print("FCMToken $fcmToken");
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Status bar background color
      statusBarIconBrightness: Brightness.dark, // Android dark icons
      statusBarBrightness: Brightness.light, // iOS dark icons
    ),
  );

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final Widget initialScreen = await getInitialScreen(prefs);

  // Initialize call service if user is logged in
  if (prefs.getString('access_token') != null) {
    // print('CallService.initializeCallService main');
    // await CallService.initializeCallService();
  }

  /// 2/5: set navigator key to ZegoUIKitPrebuiltCallInvitationService
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(Constants.navigatorKey);

  ZegoUIKit().initLog().then((value) {
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI([ZegoUIKitSignalingPlugin()]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: ColorCodes.colorBlue1, // transparent or any color
        statusBarIconBrightness: Brightness.dark, // dark icons for light background
        statusBarBrightness: Brightness.light, // for iOS
      ),
    );

    runApp(
      GetMaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: Constants.navigatorKey,
        home: initialScreen,
        // builder: (context, child) {
        //   return Stack(children: [child!, ZegoUIKitPrebuiltCallMiniOverlayPage(contextQuery: () => navigatorKey.currentState!.context)]);
        // },
      ),
    );
  });

  // onUserLogin();
}


Future<Widget> getInitialScreen(SharedPreferences prefs) async {
  /*  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('shopify_access_token');
  final expiryString = prefs.getString('token_expiry');

  if (token != null && token.isNotEmpty && expiryString != null) {
    final expiry = DateTime.tryParse(expiryString);
    if (expiry != null && DateTime.now().isBefore(expiry)) {
      return NavigationScreen();
    } else {
      // Expired token, clear it
      await prefs.remove('shopify_access_token');
      await prefs.remove('token_expiry');
    }
  }*/

  final token = prefs.getString('access_token');
  print('Token: $token');
  final doctorId = prefs.getString('doctor_id');
  print('doctorId: $doctorId');

  if (token != null && token.isNotEmpty) {
    // You can also set currentUser ID and name here if needed
    // currentUser.id = prefs.getString('doctor_id') ?? '';
    // currentUser.name = prefs.getString('doctor_name') ?? 'Doctor';

    return MainScreen(); // Token exists → Go to MainScreen
  } else {
    return AuthScreen(); // No token → Go to AuthScreen
  }

  // return AuthScreen(); // ❌ No valid token, go to auth screen
}

