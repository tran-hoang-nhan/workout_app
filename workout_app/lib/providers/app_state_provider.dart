import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrentDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void updateDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (state != today) {
      state = today;
    }
  }
}

final currentDateProvider = NotifierProvider<CurrentDateNotifier, DateTime>(() {
  return CurrentDateNotifier();
});

class NavigationNotifier extends Notifier<String> {
  @override
  String build() => 'home';

  void setTab(String tabId) {
    state = tabId;
  }
}

final navigationProvider = NotifierProvider<NavigationNotifier, String>(() {
  return NavigationNotifier();
});
