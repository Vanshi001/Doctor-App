import 'package:Doctor/screens/AuthScreen.dart';
import 'package:Doctor/zegocloud/common.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

final currentUser = ZegoUIKitUser(id: '', name: '');
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  final Widget initialScreen = await getInitialScreen();

  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  ZegoUIKit().initLog().then((_) {
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI([
      ZegoUIKitSignalingPlugin(),
    ]);
  });

  onUserLogin();

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: initialScreen,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            ZegoUIKitPrebuiltCallMiniOverlayPage(
              contextQuery: () => navigatorKey.currentState!.context,
            ),
          ],
        );
      },
    ),
  );
}

Future<Widget> getInitialScreen() async {
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

  return AuthScreen(); // ❌ No valid token, go to auth screen
}

void onUserLogin() {
  /// 4/5. initialized ZegoUIKitPrebuiltCallInvitationService when account is logged in or re-logged in
  ZegoUIKitPrebuiltCallInvitationService().init(
    appID: 260617754 /*input your AppID*/,
    appSign:
        "0b18f31ba87471a155cfea2833abf4c8168690730f6d565f985115620ca14e28" /*input your AppSign*/,
    userID: currentUser.id,
    userName: currentUser.name,
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
      config.topMenuBar.buttons.insert(
        0,
        ZegoCallMenuBarButtonName.minimizingButton,
      );
      config.topMenuBar.buttons.insert(
        1,
        ZegoCallMenuBarButtonName.soundEffectButton,
      );

      return config;
    },
  );
}
