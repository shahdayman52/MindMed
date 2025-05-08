import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:mindmed/screens/splash_screen.dart';

// ✅ Step 1: Notification plugin instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings();

  final InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings, // ✅ This line was missing
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // ✅ Ask for iOS notification permission
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true);

  runApp(const MyApp());
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // ✅ Step 2: Timezone initialization
//   tz.initializeTimeZones();

//   // ✅ Step 3: Initialize local notification settings
//   const AndroidInitializationSettings androidSettings =
//       AndroidInitializationSettings('@mipmap/ic_launcher');

//   final InitializationSettings initSettings = InitializationSettings(
//     android: androidSettings,
//   );

//   await flutterLocalNotificationsPlugin.initialize(initSettings);
//   // ✅ ASK FOR PERMISSION ON iOS
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           IOSFlutterLocalNotificationsPlugin>()
//       ?.requestPermissions(alert: true, badge: true, sound: true);
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:mindmed/screens/splash_screen.dart';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home:SplashScreen(),

//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:mindmed/screens/splash_screen.dart';
// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home:SplashScreen(),

//     );
//   }
// }

