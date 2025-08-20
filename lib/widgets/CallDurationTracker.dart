import 'dart:async';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import 'Constants.dart';

class CallDurationTracker {
  static Timer? _callDurationTimer;
  static const int maxCallDurationMinutes = 15;
  static const int maxCallDurationSeconds = maxCallDurationMinutes * 60;

  static void startCallTimer() {
    // Cancel any existing timer
    _callDurationTimer?.cancel();

    // Start new timer
    _callDurationTimer = Timer(Duration(minutes: maxCallDurationMinutes), () {
      _endCallAfterTimeout();
    });

    print('Call timer started - ${maxCallDurationMinutes} minutes countdown');
  }

  static void _endCallAfterTimeout() {
    print('Call time limit reached - ending call');

    // End the call through ZegoUIKit
    ZegoUIKit().leaveRoom();

    // Show notification to both users
    _showTimeLimitNotification();
  }

  static void _showTimeLimitNotification() {
    // You can use GetX, snackbar, or local notification
    Constants.showError('Call ended automatically after $maxCallDurationMinutes minutes');
  }

  static void stopCallTimer() {
    _callDurationTimer?.cancel();
    _callDurationTimer = null;
    print('Call timer stopped');
  }

  static String getRemainingTime() {
    if (_callDurationTimer == null || !_callDurationTimer!.isActive) {
      return '00:00';
    }

    // Calculate remaining time (this is approximate)
    final remaining = Duration(seconds: maxCallDurationSeconds);
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds.remainder(60);

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}