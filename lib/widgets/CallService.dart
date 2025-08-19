// lib/services/call_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import '../widgets/Constants.dart';

class CallService {
  static DateTime? _callStartTime;
  static DateTime? _callEndTime;

  static final ZegoUIKitPrebuiltCallInvitationService invitationService = ZegoUIKitPrebuiltCallInvitationService();

  static Future<void> initializeCallService(String callerUserName) async {
    final prefs = await SharedPreferences.getInstance();
    final doctorId = prefs.getString('doctor_id') ?? '';
    final doctorName = prefs.getString('doctor_name') ?? 'Doctor';

    // String uniqueUserId = await getUniqueUserId();
    // print("Unique User Id - $uniqueUserId");
    // Constants.currentUser.id = uniqueUserId;

    print('CallService doctorId -- $doctorId');
    print('CallService callerUserName -- $callerUserName');
    // print('CallService doctorName -- $doctorName');

    // First uninitialize any existing service
    /*try {
      await ZegoUIKitPrebuiltCallInvitationService().uninit();
    } catch (e) {
      print('Error uninitializing: $e');
    }*/

    await ZegoUIKitPrebuiltCallInvitationService().init(
      appID: Constants.zegoAppId,
      appSign: Constants.zegoAppSign,
      userID: doctorId,
      userName: callerUserName,
      plugins: [ZegoUIKitSignalingPlugin()],
      // config: ZegoCallInvitationConfig(offline: ZegoCallInvitationOfflineConfig(autoEnterAcceptedOfflineCall: false)),
      notificationConfig: ZegoCallInvitationNotificationConfig(
        androidNotificationConfig: ZegoCallAndroidNotificationConfig(
          showFullScreen: true,
          fullScreenBackgroundAssetURL: 'assets/image/call.png',
          callChannel: ZegoCallAndroidNotificationChannelConfig(
            channelID: "ZegoUIKit",
            channelName: "Call Notifications",
            sound: "call",
            icon: "call",
          ),
          missedCallChannel: ZegoCallAndroidNotificationChannelConfig(
            channelID: "MissedCall",
            channelName: "Missed Call",
            sound: "missed_call",
            icon: "missed_call",
            vibrate: false,
          ),
        ),
        iOSNotificationConfig: ZegoCallIOSNotificationConfig(systemCallingIconName: 'CallKitIcon'),
      ),
    );

    print('INIT SERVICE -- ${Constants.currentUser.id} -- ${Constants.currentUser.name}');

    await sendCallInvitation(Constants.currentUser.id, Constants.currentUser.name, isVideo: true);

    /*await ZegoUIKitPrebuiltCallInvitationService().send(
      invitees: [ZegoCallUser(Constants.currentUser.id, Constants.currentUser.name)],
      isVideoCall: true,
    );*/
  }

  static Future<void> sendCallInvitation(String targetUserId, String targetUserName, {bool isVideo = true}) async {
    try {
      await ZegoUIKitPrebuiltCallInvitationService().send(
        invitees: [ZegoCallUser(targetUserId, targetUserName)], // 👈 pass doctor/patient id here
        isVideoCall: isVideo,
      );
      print("Invitation sent to $targetUserId - $targetUserName");
    } catch (e) {
      print("Error sending call invitation: $e");
    }
  }

  static Future<String> getUniqueUserId() async {
    String? deviceID;
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      final iosDeviceInfo = await deviceInfo.iosInfo;
      deviceID = iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      final androidDeviceInfo = await deviceInfo.androidInfo;
      deviceID = androidDeviceInfo.id; // unique ID on Android
    }

    if (deviceID != null && deviceID.length < 4) {
      if (Platform.isAndroid) {
        deviceID += '_android';
      } else if (Platform.isIOS) {
        deviceID += '_ios___';
      }
    }
    if (Platform.isAndroid) {
      deviceID ??= 'flutter_user_id_android';
    } else if (Platform.isIOS) {
      deviceID ??= 'flutter_user_id_ios';
    }

    // Add random UUID
    final uuid = const Uuid().v4();
    final raw = "$deviceID-$uuid";

    final userID = md5.convert(utf8.encode(raw)).toString().replaceAll(RegExp(r'[^0-9]'), '');
    return userID.substring(userID.length - 6);
  }

  static Future<void> startAppointmentCall({required String patientUserId, required String bookingId, required String patientName}) async {
    try {
      // Get the signaling plugin instance
      print('sending call invitation');
      sendCallButton(isVideoCall: true, inviteeUsersIDTextCtrl: patientUserId, name: patientName, onCallFinished: onSendCallInvitationFinished);
    } catch (e) {
      print('Error sending call invitation: $e');
      rethrow;
    }
  }

  static Widget sendCallButton({
    required bool isVideoCall,
    required String inviteeUsersIDTextCtrl,
    required String name,
    void Function(String code, String message, List<String>)? onCallFinished,
  }) {
    /*return ValueListenableBuilder<String>(
      valueListenable: inviteeUsersIDTextCtrl,
      builder: (context, inviteeUserID, _) {
        final invitees = getInvitesFromTextCtrl(inviteeUserID.trim());

        return ZegoSendCallInvitationButton(
          isVideoCall: isVideoCall,
          invitees: invitees,
          resourceID: 'zego_data',
          iconSize: const Size(40, 40),
          buttonSize: const Size(50, 50),
          onPressed: onCallFinished,
        );
      },
    );*/
    final invitees = getInvitesFromTextCtrl(inviteeUsersIDTextCtrl.trim(), name);

    print('invitees ---- $invitees');
    return ZegoSendCallInvitationButton(
      isVideoCall: isVideoCall,
      invitees: invitees,
      resourceID: 'zego_data',
      iconSize: const Size(40, 40),
      buttonSize: const Size(50, 50),
      onPressed: onCallFinished,
    );
  }

  static void onSendCallInvitationFinished(String code, String message, List<String> errorInvitees) {
    if (errorInvitees.isNotEmpty) {
      var userIDs = '';
      for (var index = 0; index < errorInvitees.length; index++) {
        if (index >= 5) {
          userIDs += '... ';
          break;
        }

        final userID = errorInvitees.elementAt(index);
        userIDs += '$userID ';
      }
      if (userIDs.isNotEmpty) {
        userIDs = userIDs.substring(0, userIDs.length - 1);
        print('1C userIDs:- $userIDs');
      }

      var message = "User doesn't exist or is offline: $userIDs";
      if (code.isNotEmpty) {
        message += ', code: $code, message:$message';
      }
      print('1C message:- $message');
      Constants.showSuccess(message);
    } else if (code.isNotEmpty) {
      Constants.showError('1C code: $code, message:$message');
      print('1C code: $code, message:$message');
    }
  }

  static List<ZegoUIKitUser> getInvitesFromTextCtrl(String textCtrlText, String name) {
    final invitees = <ZegoUIKitUser>[];

    final inviteeIDs = textCtrlText.trim().replaceAll('，', '');
    inviteeIDs.split(',').forEach((inviteeUserID) {
      if (inviteeUserID.isEmpty) {
        return;
      }

      print('1C inviteeUserID: $inviteeUserID');
      invitees.add(ZegoUIKitUser(id: inviteeUserID, name: name)); /*'user_$inviteeUserID'*/
    });

    return invitees;
  }
}
