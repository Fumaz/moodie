import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();

void showNotificationDaily() async {
  tz.initializeTimeZones();

  Future<PermissionStatus> status =
      NotificationPermissions.requestNotificationPermissions(
          iosSettings: const NotificationSettingsIos(), openSettings: true);

  var androidChannel = const AndroidNotificationDetails('moodie', 'moodie',
      channelDescription: 'moodie', playSound: true);

  var iosChannel =
      const IOSNotificationDetails(presentBadge: true, presentSound: true);

  tz.setLocalLocation(tz.getLocation('Europe/Rome'));

  await plugin.periodicallyShow(
      0,
      'How are you feeling?',
      'Track your mood for today!',
      RepeatInterval.daily,
      NotificationDetails(
        android: androidChannel,
        iOS: iosChannel,
      ));
}
