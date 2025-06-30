import 'package:get/get.dart';

import '../model/schedule_item.dart';

enum TabType { all, today, tomorrow }

class UpcomingSchedulesController extends GetxController {
  var selectedTab = TabType.today.obs;

  final List<ScheduleItem> allList = [
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/women/1.jpg',
      clinic: 'All 1 - Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '22 May 2025',
      time: '12:30 - 13:00 pm',
    ),
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/women/1.jpg',
      clinic: 'All 2 - Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '22 May 2025',
      time: '12:30 - 13:00 pm',
    ),
  ];

  final List<ScheduleItem> todayList = [
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/women/44.jpg',
      clinic: 'T 1 - Dermatics India',
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

  final List<ScheduleItem> tomorrowList = [
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/men/15.jpg',
      clinic: 'TR 1 - Dermatics India',
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
      case TabType.today:
        return todayList;
      case TabType.tomorrow:
        return tomorrowList;
      case TabType.all:
      return allList;
    }
  }

  void updateTab(TabType tab) {
    selectedTab.value = tab;
  }
}
