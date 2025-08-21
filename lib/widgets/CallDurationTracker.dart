// lib/utils/call_duration_tracker.dart
import 'dart:async';

class CallDurationTracker {
  static DateTime? _callStartTime;
  static DateTime? _callEndTime;
  static Timer? _durationTimer;
  static Duration _currentDuration = Duration.zero;

  static void startCall() {
    _callStartTime = DateTime.now();
    _currentDuration = Duration.zero;

    _durationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _currentDuration += Duration(seconds: 1);
      print('VANSHI CallDurationTrackerCall duration: ${formatDuration(_currentDuration)}');
    });

    print('VANSHI CallDurationTracker Call started at: $_callStartTime');
  }

  static void endCall() {
    _callEndTime = DateTime.now();
    _durationTimer?.cancel();
    _durationTimer = null;

    print('VANSHI CallDurationTracker Call ended at: $_callEndTime');
    print('VANSHI CallDurationTracker Total call duration: ${getFormattedDuration()}');
  }

  static Duration? get totalDuration {
    if (_callStartTime != null && _callEndTime != null) {
      return _callEndTime!.difference(_callStartTime!);
    }
    return null;
  }

  static String getFormattedDuration() {
    final duration = totalDuration;
    if (duration != null) {
      return formatDuration(duration);
    }
    return '00:00:00';
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  static void reset() {
    _durationTimer?.cancel();
    _durationTimer = null;
    _callStartTime = null;
    _callEndTime = null;
    _currentDuration = Duration.zero;
  }
}