// lib/services/call_service.dart
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import '../widgets/Constants.dart';

class CallService {

  static final ZegoUIKitPrebuiltCallInvitationService invitationService = ZegoUIKitPrebuiltCallInvitationService();

  static Future<void> initializeCallService() async {
    final prefs = await SharedPreferences.getInstance();
    final doctorId = prefs.getString('doctor_id') ?? '';
    final doctorName = prefs.getString('doctor_name') ?? 'Doctor';

    print('CallService doctorId -- $doctorId');
    print('CallService doctorName -- $doctorName');

    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: Constants.zegoAppId,
      appSign: Constants.zegoAppSign,
      userID: Constants.currentUser.id,
      userName: Constants.currentUser.name,
      plugins: [ZegoUIKitSignalingPlugin()],
      config: ZegoCallInvitationConfig(
        offline: ZegoCallInvitationOfflineConfig(autoEnterAcceptedOfflineCall: false),
      ),
      notificationConfig: ZegoCallInvitationNotificationConfig(
        androidNotificationConfig: ZegoCallAndroidNotificationConfig(
          showFullScreen: true,
          fullScreenBackgroundAssetURL: 'assets/image/call.png',
          callChannel: ZegoCallAndroidNotificationChannelConfig(
              channelID: "ZegoUIKit",
              channelName: "Call Notifications",
              sound: "call",
              icon: "call"
          ),
          missedCallChannel: ZegoCallAndroidNotificationChannelConfig(
            channelID: "MissedCall",
            channelName: "Missed Call",
            sound: "missed_call",
            icon: "missed_call",
            vibrate: false,
          ),
        ),
        iOSNotificationConfig: ZegoCallIOSNotificationConfig(
          systemCallingIconName: 'CallKitIcon',
        ),
      ),
    );
  }

  static Future<void> startAppointmentCall({
    required String patientUserId,
    required String bookingId,
    required String patientName,
  }) async {
    try {
      // Get the signaling plugin instance
      print('sending call invitation');
      sendCallButton(
        isVideoCall: true,
        inviteeUsersIDTextCtrl: patientUserId,
        onCallFinished: onSendCallInvitationFinished,
      );
    } catch (e) {
      print('Error sending call invitation: $e');
      rethrow;
    }
  }

  static Widget sendCallButton({
    required bool isVideoCall,
    required String inviteeUsersIDTextCtrl,
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
    final invitees = getInvitesFromTextCtrl(inviteeUsersIDTextCtrl.trim());

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
        print('userIDs: $userIDs');
      }

      var message = "User doesn't exist or is offline: $userIDs";
      if (code.isNotEmpty) {
        message += ', code: $code, message:$message';
      }
      print('message:$message');
      Constants.showSuccess(message);
    } else if (code.isNotEmpty) {
      Constants.showError('code: $code, message:$message');
      print('code: $code, message:$message');
    }
  }

  static List<ZegoUIKitUser> getInvitesFromTextCtrl(String textCtrlText) {
    final invitees = <ZegoUIKitUser>[];

    final inviteeIDs = textCtrlText.trim().replaceAll('，', '');
    inviteeIDs.split(',').forEach((inviteeUserID) {
      if (inviteeUserID.isEmpty) {
        print('inviteeUserID: $inviteeUserID');
        return;
      }

      print('inviteeUserID NOT EMPTY: $inviteeUserID');
      invitees.add(ZegoUIKitUser(id: inviteeUserID, name: 'user_$inviteeUserID'));
    });

    return invitees;
  }
}