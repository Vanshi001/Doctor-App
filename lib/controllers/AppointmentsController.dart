import 'dart:ui';

import 'package:get/get.dart';

import '../model/schedule_item.dart';
import '../widgets/ColorCodes.dart';

enum TabType { all, recent, complete, canceled }

class AppointmentsController extends GetxController {
  var selectedTab = TabType.all.obs;

  final List<ScheduleItem> allList = [
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/women/1.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '22 May 2025',
      time: '12:30 - 13:00 pm',
    ),
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/women/1.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '22 May 2025',
      time: '12:30 - 13:00 pm',
    ),
  ];

  final List<ScheduleItem> recentList = [
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/women/44.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '22 May 2025',
      time: '12:30 - 13:00 pm',
    ),
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/women/44.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '22 May 2025',
      time: '12:30 - 13:00 pm',
    ),
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/women/44.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '22 May 2025',
      time: '12:30 - 13:00 pm',
    ),
  ];

  final List<ScheduleItem> completeList = [
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/men/15.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '23 May 2025',
      time: '10:30 - 11:00 am',
    ),
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/men/15.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '23 May 2025',
      time: '10:30 - 11:00 am',
    ),
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/men/15.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '23 May 2025',
      time: '10:30 - 11:00 am',
    ),
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/men/15.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '23 May 2025',
      time: '10:30 - 11:00 am',
    ),
  ];

  final List<ScheduleItem> canceledList = [
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/men/15.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '23 May 2025',
      time: '10:30 - 11:00 am',
    ),
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/men/15.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '23 May 2025',
      time: '10:30 - 11:00 am',
    ),
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/men/15.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '23 May 2025',
      time: '10:30 - 11:00 am',
    ),
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/men/15.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '23 May 2025',
      time: '10:30 - 11:00 am',
    ),
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/men/15.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '23 May 2025',
      time: '10:30 - 11:00 am',
    ),
  ];

  List<ScheduleItem> get currentList {
    switch (selectedTab.value) {
      case TabType.recent:
        return recentList;
      case TabType.complete:
        return completeList;
      case TabType.canceled:
        return canceledList;
      case TabType.all:
      default:
        return allList;
    }
  }

  Color? getDotColorForTab(TabType tab) {
    switch (tab) {
      case TabType.recent:
        return ColorCodes.colorYellow1;
      case TabType.complete:
        return ColorCodes.colorGreen1;
      case TabType.canceled:
        return ColorCodes.colorRed1;
      default:
        return null;
    }
  }

  void updateTab(TabType tab) {
    selectedTab.value = tab;
  }
}
