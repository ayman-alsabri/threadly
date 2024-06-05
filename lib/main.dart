import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:usage_track/auth-screen/providers/auth.dart';
import 'package:usage_track/languages/texts.dart';
import 'package:usage_track/main-screen/home_screen.dart';
import 'package:usage_track/main-screen/providers/firebase_data.dart';
import 'package:usage_track/providers/database.dart';
import 'package:usage_track/providers/work_data.dart';
import 'package:usage_track/settengs_screen/settengs_screen.dart';

import 'auth-screen/auth_screen.dart';

const androidsettings = AndroidInitializationSettings('noti_icon');

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  importance: Importance.high, playSound: true, enableVibration: true,
  showBadge: true,
);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyApHk17PB81K7uVK0lkbIqn9IGo8pBBJhs",
          appId: "1:32914581241:android:5c2f08935d434279d16428",
          messagingSenderId: "32914581241",
          projectId: "statistics-1ba97"));

  await TheDatabase.databaseOpenner();

  await flutterLocalNotificationsPlugin.initialize(const InitializationSettings(
      android: androidsettings));

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await TheDatabase.firebaseMessaging.requestPermission(
      provisional: true,
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      sound: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (context) => WorkData(),
        ),
        ChangeNotifierProxyProvider<WorkData, FirebaseData>(
          update: (context, value, previous) => FirebaseData(
            value.paidNotification,
            value.list,
            value.getFromLocalDatabase,
            value.unsubmiitedList,
            value.addWork,
            value.deleteWork,
          ),
          create: (context) => FirebaseData(
            null,
            [],
            (b) async {},
            [],
            (
                {required int amountSpent,
                required int quantity,
                required String typeName,
                required int id,
                required DateTime date,
                required int hasBeenSubmitted}) async {},
            (int id) {},
          ),
        ),
      ],
      builder: (context, child) => GetMaterialApp(
        locale: Locale(TheDatabase.localCode.replaceRange(2, null, ''),
            TheDatabase.localCode.replaceRange(0, 3, '')),
        fallbackLocale: Locale(TheDatabase.localCode.replaceRange(2, null, ''),
            TheDatabase.localCode.replaceRange(0, 3, '')),
        translations: Texts(),
        title: 'Threadly',
        theme: TheDatabase.themes[0],
        darkTheme: TheDatabase.themes[1],
        themeMode: TheDatabase.themeMode,
        home: StreamBuilder(
          stream: TheDatabase.firebaseAuth.authStateChanges(),
          builder: (context, snapshot) =>
              snapshot.hasData ? const HomeScreen() : const AuthScreen(),
        ),
        routes: {
          AuthScreen.route: (context) => const AuthScreen(),
          HomeScreen.route: (context) => const HomeScreen(),
          SettengsScreen.route: (context) => const SettengsScreen(),
        },
      ),
    );
  }
}
