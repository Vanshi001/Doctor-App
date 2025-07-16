import 'package:Doctor/screens/AuthScreen.dart';
import 'package:Doctor/screens/MainScreen.dart';
import 'package:Doctor/widgets/Constants.dart';
import 'package:Doctor/zegocloud/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Status bar background color
      statusBarIconBrightness: Brightness.dark, // Android dark icons
      statusBarBrightness: Brightness.light, // iOS dark icons
    ),
  );

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final Widget initialScreen = await getInitialScreen(prefs);

  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  ZegoUIKit().initLog().then((_) {
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI([ZegoUIKitSignalingPlugin()]);
  });

  // onUserLogin();

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: initialScreen,
      builder: (context, child) {
        return Stack(children: [child!, ZegoUIKitPrebuiltCallMiniOverlayPage(contextQuery: () => navigatorKey.currentState!.context)]);
      },
    ),
  );
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

void onUserLogin() {
  /// 4/5. initialized ZegoUIKitPrebuiltCallInvitationService when account is logged in or re-logged in
  ///
  ZegoUIKitPrebuiltCallInvitationService().init(
    appID: 260617754 /*input your AppID*/,
    appSign: "0b18f31ba87471a155cfea2833abf4c8168690730f6d565f985115620ca14e28" /*input your AppSign*/,
    userID: Constants.currentUser.id,
    userName: Constants.currentUser.name,
    plugins: [ZegoUIKitSignalingPlugin()],
    requireConfig: (ZegoCallInvitationData data) {
      final config =
          (data.invitees.length > 1)
              ? ZegoCallInvitationType.videoCall == data.type
                  ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
                  : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
              : ZegoCallInvitationType.videoCall == data.type
              ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
              : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

      /// custom avatar
      config.avatarBuilder = customAvatarBuilder;

      /// support minimizing, show minimizing button
      config.topMenuBar.isVisible = true;
      config.topMenuBar.buttons.insert(0, ZegoCallMenuBarButtonName.minimizingButton);
      config.topMenuBar.buttons.insert(1, ZegoCallMenuBarButtonName.soundEffectButton);

      return config;
    },
  );
}
