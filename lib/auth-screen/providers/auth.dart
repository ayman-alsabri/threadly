import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:usage_track/providers/database.dart';

class Auth with ChangeNotifier {
  final _auth = TheDatabase.firebaseAuth;
  final _fireStore = FirebaseFirestore.instance;

  Future<void> signup(Map<String, String?> userData) async {
    final connectivityResult = await InternetAddress.lookup('google.com')
        .timeout(
          const Duration(seconds: 4),
          onTimeout: () => throw Exception(
              'no internet connection or internet is very slow'),
        )
        .onError(
          (error, stackTrace) => throw Exception(
              'no internet connection or internet is very slow'),
        );

    if (!connectivityResult.isNotEmpty ||
        !connectivityResult[0].rawAddress.isNotEmpty) {
      throw Exception('no internet connection or internet is very slow');
    }
    final managerInfo =
        await _fireStore.collection('/users').doc(userData['shopName']).get();
    if (!(managerInfo).exists) {
      throw Exception('the id is not correct');
    }
    final tempToken = managerInfo.get('token');
    final workeToken = await TheDatabase.firebaseMessaging.getToken();

    final prievious = (await _fireStore
            .collection('/users')
            .doc(userData['shopName']!)
            .collection('/workers')
            .count()
            .get())
        .count;
    final amount = (await _fireStore.collection('price').doc('normal').get())
        .get('amount') as int;

    await TheDatabase.theDatabase.update(
      'user',
      {'paymentAmount': amount},
    );

    await TheDatabase.theDatabase
        .update('user', {'userId': prievious + 1}, where: 'id=1');

    await _auth.createUserWithEmailAndPassword(
        email: '${userData['shopName']!}${userData['name']!}@gmail.com',
        password: userData['password']!);
    await _fireStore
        .collection('/users')
        .doc(userData['shopName']!)
        .collection('/workers')
        .doc((prievious + 1).toString())
        .set({
      'name': userData['name'],
      'password': userData['password'],
      'hasPaid': false,
      'timeStamp': Timestamp.now(),
    });

    FirebaseFunctions.instance.httpsCallable('notifyManager').call({
      'token': tempToken,
      'data': {
        'id': (prievious + 1).toString(),
        'name': userData['name'],
        'token': workeToken,
      }
    });
    await TheDatabase.theDatabase
        .update('user', {'userId': prievious + 1}, where: 'id=1');
  }

  Future<void> login(Map<String, String?> userData) async {
    final connectivityResult = await InternetAddress.lookup('google.com')
        .timeout(
          const Duration(seconds: 4),
          onTimeout: () => throw Exception(
              'no internet connection or internet is very slow'),
        )
        .onError(
          (error, stackTrace) => throw Exception(
              'no internet connection or internet is very slow'),
        );

    if (!connectivityResult.isNotEmpty ||
        !connectivityResult[0].rawAddress.isNotEmpty) {
      throw Exception('no internet connection or internet is very slow');
    }
    try {
      final id = (await _fireStore
              .collection('/users')
              .doc(userData['shopName']!)
              .collection('/workers')
              .where('name', isEqualTo: userData['name'])
              .get())
          .docs[0]
          .id;
      final amount = (await _fireStore.collection('price').doc('normal').get())
          .get('amount') as int;

      await TheDatabase.theDatabase.update(
        'user',
        {'paymentAmount': amount},
      );

      await TheDatabase.theDatabase
          .update('user', {'userId': int.parse(id)}, where: 'id=1');
    } catch (e) {
      throw Exception('invalid input');
    }
    await _auth.signInWithEmailAndPassword(
        email: '${userData['shopName']!}${userData['name']!}@gmail.com',
        password: userData['password']!);
  }

  Future<void> logout(bool delete) async {
    await TheDatabase.firebaseMessaging.deleteToken();

    await databaseFactory.deleteDatabase(TheDatabase.databasePath);

    await _auth.signOut();
    await SystemNavigator.pop();
  }
}
