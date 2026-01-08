import 'package:eschool/utils/ExamSubmitSyncService.dart';
import 'package:flutter/widgets.dart';

class GlobalAppLifecycleObserver with WidgetsBindingObserver {
  static final GlobalAppLifecycleObserver _i = GlobalAppLifecycleObserver._();
  GlobalAppLifecycleObserver._();

  static void install() {
    print("Installing GlobalAppLifecycleObserver");
    WidgetsBinding.instance.addObserver(_i);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
  }
}
