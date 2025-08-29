// lib/utils/call_duration_tracker.dart
import 'dart:async';

class CallDurationTracker {
  static DateTime? callStartTime;
  static DateTime? callEndTime;
  static Timer? _durationTimer;
  static Duration _currentDuration = Duration.zero;
  static bool _isCallActive = false;

  static void startCall() {
    if (_isCallActive) {
      print('VANSHI CallDurationTracker: Call is already active');
      return;
    }

    callStartTime = DateTime.now();
    _currentDuration = Duration.zero;
    _isCallActive = true;

    _durationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isCallActive) {
      _currentDuration += Duration(seconds: 1);
      print('VANSHI CallDurationTrackerCall duration: ${formatDuration(_currentDuration)}');
      } else {
        timer.cancel();
      }
    });

    print('VANSHI CallDurationTracker Call started at: $callStartTime');
  }

  static void endCall() {
    if (!_isCallActive) {
      print('VANSHI CallDurationTracker: No active call to end');
      return;
    }

    callEndTime = DateTime.now();
    _isCallActive = false;
    _durationTimer?.cancel();
    _durationTimer = null;

    print('VANSHI CallDurationTracker Call ended at: $callEndTime');
    print('VANSHI CallDurationTracker Total call duration: ${getFormattedDuration()}');
  }

  // Call this when call is cut/disconnected unexpectedly
  static void onCallCut() {
    if (!_isCallActive) {
      print('VANSHI CallDurationTracker: No active call to cut');
      return;
    }

    print('VANSHI CallDurationTracker: Call was cut/disconnected');
    endCall(); // Use the same end call logic
  }

  // Force stop the tracker in case of any issues
  static void forceStop() {
    _isCallActive = false;
    _durationTimer?.cancel();
    _durationTimer = null;
    print('VANSHI CallDurationTracker: Force stopped');
  }

  static Duration? get totalDuration {
    if (callStartTime != null && callEndTime != null) {
      return callEndTime!.difference(callStartTime!);
    }
    return null;
  }

  static Duration get currentDuration => _currentDuration;

  static bool get isCallActive => _isCallActive;

  static String getFormattedDuration() {
    final duration = totalDuration;
    if (duration != null) {
      return formatDuration(duration);
    }
    return formatDuration(_currentDuration);
    // return '00:00:00';
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  static void reset() {
    _isCallActive = false;
    _durationTimer?.cancel();
    _durationTimer = null;
    callStartTime = null;
    callEndTime = null;
    _currentDuration = Duration.zero;
    _currentDuration = Duration.zero;
    print('VANSHI CallDurationTracker: Reset complete');
  }
}