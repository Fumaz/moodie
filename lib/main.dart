import 'package:flutter/material.dart';
import 'package:moodie/app/app.dart';
import 'package:moodie/util/notifications.dart';

import 'database/database.dart';

void main() {
  setup().then((value) {
    showNotificationDaily();
    runApp(const MoodieApp());
  });
}
