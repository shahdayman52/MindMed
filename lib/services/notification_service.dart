import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:mindmed/main.dart';

 // to access flutterLocalNotificationsPlugin



void showInstantNotification() async {
    print("🔔 Button pressed! Trying to show notification..."); // 👈 add this

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'instant_notif',
    'Instant Notifications',
    channelDescription: 'Test notification shown instantly',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: DarwinNotificationDetails(),
  );

  await flutterLocalNotificationsPlugin.show(
    0, // ID
    '🚨 Test Notification',
    'This is a test notification you should see instantly!',
    notificationDetails,
  );
}


void scheduleDailyNotifications() async {
  // 🧠 Morning Notification
  await flutterLocalNotificationsPlugin.zonedSchedule(
    1, // ID
    '🧠 Mind Check-in',
    'How are you feeling today?',
    _nextInstanceOfTime(10, 0),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'morning_notif',
        'Morning Notifications',
        channelDescription: 'Daily mental health check-in',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    androidAllowWhileIdle: true,
    matchDateTimeComponents: DateTimeComponents.time,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        
  );

  // 📔 Evening Notification
  await flutterLocalNotificationsPlugin.zonedSchedule(
    2, // ID
    '📔 Journal Reminder',
    'Reflect and write something down before bed 💭',
    _nextInstanceOfTime(20, 0),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'evening_notif',
        'Evening Notifications',
        channelDescription: 'End-of-day journaling reminder',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    androidAllowWhileIdle: true,
    matchDateTimeComponents: DateTimeComponents.time,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}


tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
  final now = tz.TZDateTime.now(tz.local);
  var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

  if (scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1)); // Schedule for tomorrow
  }

  return scheduled;
}
