import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:moodie/app/page/entries_page.dart';

class MoodieApp extends StatelessWidget {
  const MoodieApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
        title: 'Moodie',
        theme: CupertinoThemeData(
          primaryColor: CupertinoColors.systemPink,
          textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(
              color: getTextColor(),
            ),
          ),
        ),
        home: const EntriesPage());
  }
}

Color getTextColor() {
  return isDarkMode() ? CupertinoColors.white : CupertinoColors.black;
}

bool isDarkMode() {
  return SchedulerBinding.instance!.window.platformBrightness ==
      Brightness.dark;
}
