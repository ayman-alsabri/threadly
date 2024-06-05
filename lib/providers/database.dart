import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqflite.dart' as db;
import 'package:usage_track/providers/theme.dart';

class TheDatabase {
  TheDatabase._();

  static late final Database theDatabase;
  static late String localCode;
  static late List<ThemeData> themes;
  static late ThemeMode themeMode;
  static late String userName;
  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  static final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static late final String databasePath;

  static Future<void> databaseOpenner() async {
    final databasePath1 = '${await db.getDatabasesPath()}/statistics.db';
    databasePath = databasePath1;

    theDatabase = await db.openDatabase(
      databasePath1,
      version: 1,
      onCreate: (datab, version) async {
        await datab.execute(
            'CREATE TABLE user (id INTEGER PRIMARY KEY , userId INTEGER , value INTEGER , paymentAmount INTEGER ,shopToken STRING , name STRING , shopName STRING , localCode STRING , themeMode STRING , theme STRING)');
        await datab.execute(
            'CREATE TABLE types (id INTEGER PRIMARY KEY , price INTEGER , name STRING , isFavorite INTEGER)');
        await datab.execute(
            'CREATE TABLE work_data (id INTEGER PRIMARY KEY , quantity INTEGER , amountSpent INTEGER , hasBeenSubmitted INTEGER , date STRING , typeName STRING )');
        await datab.execute(
            'CREATE TABLE paidAll (id INTEGER PRIMARY KEY , amount INTEGER , date STRING)');
        await datab.execute(
            'CREATE TABLE paidAll_notification (id INTEGER PRIMARY KEY , amount INTEGER , date STRING)');

        await datab.insert('user', {
          'value': 0,
          'paymentAmount': 0,
          'name': '',
          'shopName': '',
          'localCode':
              '${Get.deviceLocale?.languageCode}_${Get.deviceLocale?.countryCode}',
          'themeMode': 'auto',
          'theme': 'blue',
        });
      },
    );

    final userdata = (await theDatabase.query('user'))[0];
    localCode = userdata['localCode'] as String;

    userName = userdata['name'] as String;

    switch (userdata['themeMode'] as String) {
      case 'auto':
        themeMode = ThemeMode.system;
        break;
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
    }

    switch (userdata['theme'] as String) {
      case 'golden':
        themes = AppTheme.golden;
        break;
      case 'blue':
        themes = AppTheme.blue;
        break;
      case 'brown':
        themes = AppTheme.brown;
        break;
      case 'grey':
        themes = AppTheme.grey;
        break;
    }
  }

  static Future<void> updatelocal() async {
    final userdata = (await theDatabase.query('user'))[0];
    localCode = userdata['localCode'] as String;
  }

  static Future<void> updateThemeMode() async {
    final userdata = (await theDatabase.query('user'))[0];
    switch (userdata['themeMode'] as String) {
      case 'auto':
        themeMode = ThemeMode.system;
        break;
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
    }
  }

  static Future<void> updateTheme() async {
    final userdata = (await theDatabase.query('user'))[0];
    switch (userdata['theme'] as String) {
      case 'golden':
        themes = AppTheme.golden;
        break;
      case 'blue':
        themes = AppTheme.blue;
        break;
      case 'brown':
        themes = AppTheme.brown;
        break;
      case 'grey':
        themes = AppTheme.grey;
        break;
    }
  }

  static Future<int> saveCredintials(Map<String, String?> userData) async {
    userName = userData['name'] as String;

    return await theDatabase.update(
        'user', {'name': userData['name'], 'shopName': userData['shopName']});
  }
}
