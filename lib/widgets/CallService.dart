// lib/services/call_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:uuid/uuid.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import '../controllers/IndividualUpcomingScheduleController.dart';
import '../widgets/Constants.dart';
import 'CallDurationTracker.dart';
import 'package:timezone/timezone.dart' as tz;

import 'ColorCodes.dart';
import 'TextStyles.dart';

class CallService {
  static DateTime? callStartTime;
  static DateTime? callEndTime;
  static Duration? finalDuration;

  static final ZegoUIKitPrebuiltCallInvitationService invitationService = ZegoUIKitPrebuiltCallInvitationService();
  static final navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> initializeCallService(String callerUserName, BuildContext context, String? appointmentId) async {
    callStartTime = null;
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
      events: ZegoUIKitPrebuiltCallEvents(
        // Modify your custom configurations here.
        onHangUpConfirmation: (
          ZegoCallHangUpConfirmationEvent event,

          /// defaultAction to return to the previous page
          Future<bool> Function() defaultAction,
        ) async {
          var config = ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall();
          _setupCallDurationTracking(config, context, appointmentId);

          return await showDialog(
            context: event.context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: ColorCodes.colorBlue1,
                title: Text("Hang Up", style: TextStyles.textStyle5_2),
                content: Text("Are you sure want to hang up the call?", style: TextStyles.textStyle5_2),
                actions: [
                  ElevatedButton(child: const Text("Cancel", style: TextStyles.textStyle4), onPressed: () => Navigator.of(context).pop(false)),
                  ElevatedButton(
                    child: const Text("Exit", style: TextStyles.textStyle4),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      print('EXIT');
                      CallDurationTracker.endCall();

                      final currentTimeStr = formatCurrentTime();
                      finalDuration = parseDuration(currentTimeStr);
                      _saveCallLog(finalDuration, appointmentId);
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
      requireConfig: (ZegoCallInvitationData data) {
        var config = ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall();

        config.layout = ZegoLayout.pictureInPicture(isSmallViewDraggable: true, switchLargeOrSmallViewByClick: true);

        _setupCallDurationTracking(config, context, appointmentId);

        return config;
      },
      invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
        onOutgoingCallCancelButtonPressed: () {
          print('invitationEvents onOutgoingCallCancelButtonPressed button clicked');
          ZegoUIKitPrebuiltCallController().hangUp(context);
        },
        onOutgoingCallDeclined: (callID, callee, customData) {
          print('invitationEvents onOutgoingCallDeclined callID -- $callID');
          print('invitationEvents onOutgoingCallDeclined callee name-- ${callee.name}');
          ZegoUIKitPrebuiltCallInvitationService().reject(causeByPopScope: true);
          // ZegoUIKitPrebuiltCallController().hangUp(context);
          Constants.showError('${callee.name} has rejected the appointment call.');
        },

        /*onOutgoingCallRejectedCauseBusy: (callID, callee, customData) {
          print('invitationEvents callID -- $callID');
          print('invitationEvents callee name-- ${callee.name}');
          ZegoUIKitPrebuiltCallInvitationService().reject();
        },*/
        onInvitationUserStateChanged: (event) {
          print('invitationEvents Invitation state changed: ${event.last.state}');
          // Get.back();
        },
      ),

      config: ZegoCallInvitationConfig(offline: ZegoCallInvitationOfflineConfig(autoEnterAcceptedOfflineCall: false)),

      // notificationConfig: ZegoCallInvitationNotificationConfig(
      //   androidNotificationConfig: ZegoCallAndroidNotificationConfig(
      //     showFullScreen: true,
      //     fullScreenBackgroundAssetURL: 'assets/image/call.png',
      //     callChannel: ZegoCallAndroidNotificationChannelConfig(
      //       channelID: "ZegoUIKit",
      //       channelName: "Call Notifications",
      //       sound: "call",
      //       icon: "call",
      //     ),
      //     missedCallChannel: ZegoCallAndroidNotificationChannelConfig(
      //       channelID: "MissedCall",
      //       channelName: "Missed Call",
      //       sound: "missed_call",
      //       icon: "missed_call",
      //       vibrate: false,
      //     ),
      //   ),
      //   iOSNotificationConfig: ZegoCallIOSNotificationConfig(systemCallingIconName: 'CallKitIcon'),
      // ),
    );

    print('INIT SERVICE -- ${Constants.currentUser.id} -- ${Constants.currentUser.name}');

    await sendCallInvitation(Constants.currentUser.id, Constants.currentUser.name, isVideo: true);

    /*await ZegoUIKitPrebuiltCallInvitationService().send(
      invitees: [ZegoCallUser(Constants.currentUser.id, Constants.currentUser.name)],
      isVideoCall: true,
    );*/
  }

  static Duration parseDuration(String time) {
    final parts = time.split(':');
    if (parts.length != 3) return Duration.zero; // fallback if invalid

    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    final seconds = int.tryParse(parts[2]) ?? 0;

    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  static String formatCurrentTime() {
    final now = DateTime.now();
    final hours = now.hour.toString().padLeft(2, '0');
    final minutes = now.minute.toString().padLeft(2, '0');
    final seconds = now.second.toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  static void _setupCallDurationTracking(ZegoUIKitPrebuiltCallConfig config, BuildContext context, String? appointmentId) {
    // Use duration callback for timing (this is available)
    config.duration = ZegoCallDurationConfig(
      isVisible: true,
      onDurationUpdate: (Duration duration) {
        print('VANSHI Elapsed time: ${CallDurationTracker.formatDuration(duration)}');

        // Track start time on first duration update
        if (callStartTime == null) {
          callStartTime = DateTime.now().subtract(duration);
          CallDurationTracker.startCall();
          print('VANSHI Call started at: $callStartTime');
        }

        // Check for 15-minute limit (900 seconds)
        if (duration.inSeconds >= 900) {
          print('VANSHI 15-minute time limit reached - ending call');
          // You can add logic to end the call here if needed
          callEndTime = DateTime.now();
          CallDurationTracker.endCall();
          ZegoUIKitPrebuiltCallController().hangUp(context);
          finalDuration = duration;
          print('finalDuration ---- $finalDuration');
          _saveCallLog(finalDuration, appointmentId);
        }
      },
    );

    // Use window events for call start/end detection
    /*config.windowCreated = (controller) {
      print('Call window created - call started');
      callStartTime = DateTime.now();
      CallDurationTracker.startCall();
    };

    config.onWindowDestroyed = (controller) {
      print('Call window destroyed - call ended');
      callEndTime = DateTime.now();
      CallDurationTracker.endCall();
      _saveCallLog();
    };*/
  }

  static void _saveCallLog(Duration? duration, String? appointmentId) {
    // Save to shared preferences or send to your backend

    final callLog = {'startTime': callStartTime?.toIso8601String(), 'endTime': callEndTime?.toIso8601String()};

    print('VANSHI Call log: $callLog');
    // Save to controller
    final controller = Get.find<IndividualUpcomingScheduleController>();
    // controller.callHistory.add(callLog);
    // controller.hasCallHistory.value = true;

    // Also save to shared preferences for persistence
    controller.callHistoryApi(callLog, appointmentId);
    Get.back();
    // saveCallLogToPrefs(callLog);
  }

  static void saveCallLogToPrefs(Map<String, dynamic> callLog) async {
    final prefs = await SharedPreferences.getInstance();
    final callHistoryJson = prefs.getStringList('call_history') ?? [];
    callHistoryJson.add(jsonEncode(callLog));
    await prefs.setStringList('call_history', callHistoryJson);
  }

  static Future<void> sendCallInvitation(String targetUserId, String targetUserName, {bool isVideo = true}) async {
    try {
      await ZegoUIKitPrebuiltCallInvitationService().send(invitees: [ZegoCallUser(targetUserId, targetUserName)], isVideoCall: isVideo);
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

  static Future<void> startAppointmentCall({required String patientUserId, required String patientName}) async {
    try {
      // Get the signaling plugin instance
      print('sending call invitation');
      late TextEditingController inviteeUsersIDTextCtrl = TextEditingController(text: patientUserId);
      // inviteeUsersIDTextCtrl.text = patientUserId;

      sendCallButton(
        isVideoCall: true,
        inviteeUsersIDTextCtrl: inviteeUsersIDTextCtrl,
        name: patientName,
        onCallFinished: (code, message, errorInvitees) {
          print('Call finished: $code, $message, $errorInvitees');
        },
      );
    } catch (e) {
      print('Error sending call invitation: $e');
      rethrow;
    }
  }

  static Future<void> startAppointmentCall_({required String patientUserId, required String patientName}) async {
    try {
      print('sending call invitation to: $patientUserId');

      // Send invitation through the signaling plugin
      await invitationService.send(isVideoCall: true, invitees: [ZegoCallUser(patientUserId, patientName)]).then((result) {
        // Handle the call result
        print('Call invitation sent successfully');

        // Since we can't get direct callback, set up listeners for call events
        // print('result.toString() -- ${result.toString()}');
      });
    } catch (e) {
      print('Error sending call invitation: $e');
      rethrow;
    }
  }

  static Widget sendCallButton({
    required bool isVideoCall,
    required TextEditingController inviteeUsersIDTextCtrl,
    required String name,
    void Function(String code, String message, List<String>)? onCallFinished,
  }) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: inviteeUsersIDTextCtrl,
      builder: (context, inviteeUserID, _) {
        final invitees = getInvitesFromTextCtrl(inviteeUserID.toString(), name);

        return ZegoSendCallInvitationButton(
          isVideoCall: isVideoCall,
          invitees: invitees,
          resourceID: 'zego_data',
          iconSize: const Size(40, 40),
          buttonSize: const Size(50, 50),
          onPressed: onCallFinished,
        );
      },
    );
    /*final invitees = getInvitesFromTextCtrl(inviteeUsersIDTextCtrl.trim(), name);

    print('invitees ---- $invitees');
    return ZegoSendCallInvitationButton(
      isVideoCall: isVideoCall,
      invitees: invitees,
      resourceID: 'zego_data',
      iconSize: const Size(40, 40),
      buttonSize: const Size(50, 50),
      onPressed: onCallFinished,
    );*/
  }

  static void onSendCallInvitationFinished(String code, String message, List<String> errorInvitees) {
    print('onSendCallInvitationFinished');
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

      // print('1C inviteeUserID: $inviteeUserID');
      invitees.add(ZegoUIKitUser(id: inviteeUserID, name: name)); /*'user_$inviteeUserID'*/
    });

    return invitees;
  }
}
