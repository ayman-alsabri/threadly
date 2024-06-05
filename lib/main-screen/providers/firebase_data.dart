import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:usage_track/providers/database.dart';
import 'package:usage_track/providers/work_data.dart';

class FirebaseData with ChangeNotifier {
  bool _init = true;
  final PaidNotification? _paidNotification;
  final List<DayWork?> _workDataList;
  final List<DayWork?> _unsupmittedList;
  final Future<void> Function(bool) _getFromLocalDatabase;
  final void Function(int id) _deleteWork;
  final Future<void> Function({
    required int amountSpent,
    required int quantity,
    required String typeName,
    required int id,
    required DateTime date,
    required int hasBeenSubmitted,
  }) _addWork;
  FirebaseData(
    this._paidNotification,
    this._workDataList,
    this._getFromLocalDatabase,
    this._unsupmittedList,
    this._addWork,
    this._deleteWork,
  );

  final Database _theDatabase = TheDatabase.theDatabase;
  final _fireStore = FirebaseFirestore.instance;
  final _functions = FirebaseFunctions.instance;
  bool getHasPaid = false;
  String? _myToken;

  Future<void> getAndSetData() async {
    final Map<String, dynamic> map = (await _theDatabase.query('user'))[0];
    final connectivityResult =
        await InternetAddress.lookup('google.com').timeout(
      const Duration(seconds: 4),
      onTimeout: () => throw Exception('no internet'),
    );

    if (!connectivityResult.isNotEmpty ||
        !connectivityResult[0].rawAddress.isNotEmpty) {
      throw Exception('no internet');
    }

    final lastIdOrNot2 = (await _theDatabase.query('types',
        columns: ['id'], orderBy: 'id DESC'));

    final id = (lastIdOrNot2.isEmpty ? 0 : lastIdOrNot2[0]['id'] as int);

    try {
      final demo = _fireStore
          .collection('/users')
          .doc(map['shopName'])
          .collection('/types');
      var data = await demo
          .where('id', isGreaterThan: id)
          .get(const GetOptions(source: Source.server))
          .then((value) {
        return value.docs;
      });

      for (var element in data) {
        final map = element.data();
        await _theDatabase.insert(
            'types',
            {
              'price': map['price'],
              'name': element.id,
              'id': map['id'],
              'isFavorite': 0,
            },
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    } catch (e) {
      rethrow;
    }
    try {
      final availableWork = await _theDatabase.query('work_data',
          columns: ['id'], orderBy: 'id DESC', limit: 1);

      final demo = _fireStore
          .collection('/users')
          .doc(map['shopName'])
          .collection('/workers')
          .doc((map['userId'] as int).toString())
          .collection('/work');
      final data = await demo
          .where('id',
              isGreaterThan: availableWork.isEmpty ? 0 : availableWork[0]['id'])
          .get(const GetOptions(
            source: Source.server,
          ))
          .then((value) {
        return value.docs;
      });

      for (var element in data) {
        final map = element.data();
        await _theDatabase.insert(
            'work_data',
            {
              'quantity': map['quantity'],
              'typeName': map['typeName'],
              'amountSpent': map['amountSpent'],
              'hasBeenSubmitted': 2,
              'date': element.id,
              'id': map['id'],
            },
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    } catch (e) {
      rethrow;
    }
    try {
      final availablePayment = await _theDatabase.query('paidAll',
          columns: ['id'], orderBy: 'id DESC', limit: 1);
      final demo = _fireStore
          .collection('/users')
          .doc(map['shopName'])
          .collection('/workers')
          .doc((map['userId'] as int).toString())
          .collection('/paidAll');
      var data = await demo
          .where('id',
              isGreaterThan:
                  availablePayment.isEmpty ? 0 : availablePayment[0]['id'])
          .get()
          .then((value) {
        return value.docs;
      });

      for (var element in data) {
        final map = element.data();
        await _theDatabase.insert(
            'paidAll',
            {
              'amount': map['amount'],
              'date': element.id,
            },
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    } catch (e) {
      rethrow;
    }
//it will throw an error if theres a problem in database
    // await _getFromLocalDatabase();
  }

  Future<void> hasPaid() async {
    bool payment = false;

    try {
      final list = (await _theDatabase.query('user'))[0];
      payment = list['value'] == 1;
    } catch (e) {
      rethrow;
    }
    try {
      final connectivityResult =
          await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 6),
        onTimeout: () => throw Exception('no internet'),
      );

      if (!connectivityResult.isNotEmpty ||
          !connectivityResult[0].rawAddress.isNotEmpty) {
        throw Exception('no internet');
      }

      final Map<String, dynamic> map = (await _theDatabase.query('user'))[0];

      final String? token =
          (await _fireStore.collection('/users').doc(map['shopName']).get())
              .get('token');
      await _theDatabase.update('user', {'shopToken': token},
          where: 'id=1', conflictAlgorithm: ConflictAlgorithm.replace);

      if (_init) {
        _myToken = await TheDatabase.firebaseMessaging.getToken();

        await _fireStore
            .collection('/users')
            .doc(map['shopName'])
            .collection('/workers')
            .doc((map['userId'] as int).toString())
            .update({'token': _myToken});
        _init = false;
      }

//here is the Null bug
      final data = await _fireStore
          .collection('/users')
          .doc(map['shopName'])
          .collection('/workers')
          .doc((map['userId'] as int).toString())
          .get();
      payment = data.get('hasPaid') as bool;

      await _theDatabase.update('user', {'value': payment ? 1 : 0},
          where: 'id=1', conflictAlgorithm: ConflictAlgorithm.replace);

      if (payment) {
        final namelist = (map['shopName'] as String).codeUnits;
        String name = '';
        for (var element in namelist) {
          name += element.toString();
        }

        await TheDatabase.firebaseMessaging.subscribeToTopic('${name}types');
      }
    } catch (e) {
      rethrow;
    } finally {
      getHasPaid = payment;
    }
  }

  Future<void> addWorkToFirebase() async {
    try {
      final connectivityResult =
          await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 4),
        onTimeout: () => throw Exception('no internet'),
      );

      if (!connectivityResult.isNotEmpty ||
          !connectivityResult[0].rawAddress.isNotEmpty) {
        throw Exception('no internet');
      }
      final Map<String, dynamic> map = (await _theDatabase.query('user'))[0];
      // final data = _fireStore
      //     .collection('/users')
      //     .doc(map['shopName'])
      //     .collection('/workers')
      //     .doc((map['userId'] as int).toString())
      //     .collection('work');
      for (var element in _unsupmittedList) {
        final token = map['shopToken'] as String;
        final workerId = (await _theDatabase
            .query('user', columns: ['userId']))[0]['userId'];
        final data = {
          'amountSpent': element?.amountSpent.toString(),
          'id': element?.id.toString(),
          'workerId': workerId.toString(),
          'date': element?.date.toIso8601String(),
          'quantity': element?.quantity.toString(),
          'typeName': element?.type.name,
        };
        final workersName = (map['name'] as String).replaceAll('_', ' ');
        final messageBody =
            'تم اضافة ${element?.quantity} ${element?.type.name}';

        _myToken ??= await TheDatabase.firebaseMessaging.getToken();
        _functions.httpsCallable("sendAddWorkRequest").call(
          {
            'token': token,
            'id': element?.id.toString(),
            'myToken': _myToken,
            'data': data,
            'workerName': workersName,
            'messageBody': messageBody,
          },
        );

        // await data.doc(element!.date.toIso8601String()).set({
        //   'amountSpent': element.amountSpent,
        //   'id': element.id,
        //   'timeStamp': Timestamp.fromDate(element.date),
        //   'quantity': element.quantity,
        //   'typeName': element.type.name,
        // });
        await _theDatabase.update(
            'work_data',
            {
              'hasBeenSubmitted': 1,
            },
            where: 'id=?',
            whereArgs: [element?.id]);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addOneWorkToFirebase(
      {required int amountSpent,
      required int quantity,
      required String typeName}) async {
    int hasBeenSubmitted = 0;
    final Map<String, dynamic> map = (await _theDatabase.query('user'))[0];
    final datestamp = DateTime.now();
    final id = await _theDatabase.insert('work_data', {
      'quantity': quantity,
      'amountSpent': amountSpent,
      'hasBeenSubmitted': 0,
      'date': datestamp.toIso8601String(),
      'typeName': typeName
    });

    try {
      final connectivityResult =
          await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 4),
        onTimeout: () => throw Exception('no internet'),
      );

      if (!connectivityResult.isNotEmpty ||
          !connectivityResult[0].rawAddress.isNotEmpty) {
        throw Exception('no internet');
      }

      final token = map['shopToken'] as String;
      final workerId =
          (await _theDatabase.query('user', columns: ['userId']))[0]['userId'];
      final data = {
        'amountSpent': amountSpent.toString(),
        'id': id.toString(),
        'workerId': workerId.toString(),
        'date': datestamp.toIso8601String(),
        'quantity': quantity.toString(),
        'typeName': typeName,
      };
      final workersName = (map['name'] as String).replaceAll('_', ' ');
      final messageBody = 'تم اضافة $quantity $typeName';

      _myToken ??= await TheDatabase.firebaseMessaging.getToken();
      _functions.httpsCallable("sendAddWorkRequest").call(
        {
          'token': token,
          'id': id.toString(),
          'myToken': _myToken,
          'data': data,
          'workerName': workersName,
          'messageBody': messageBody,
        },
      );
      // final data = _fireStore
      //     .collection('/users')
      //     .doc(map['shopName'])
      //     .collection('/workers')
      //     .doc((map['userId'] as int).toString())
      //     .collection('work');
      // await data.doc(datestamp.toIso8601String()).set({
      // 'amountSpent': amountSpent,
      // 'id': id,
      // 'timeStamp': Timestamp.fromDate(datestamp),
      // 'quantity': quantity,
      // 'typeName': typeName,
      // });
      await _theDatabase.update(
          'work_data',
          {
            'hasBeenSubmitted': 1,
          },
          where: 'id=?',
          whereArgs: [id]);
      hasBeenSubmitted = 1;
    } catch (e) {
      rethrow;
    } finally {
      _addWork(
          amountSpent: amountSpent,
          date: datestamp,
          id: id,
          quantity: quantity,
          typeName: typeName,
          hasBeenSubmitted: hasBeenSubmitted);
      notifyListeners();
    }
  }

  Future<void> deleteAWork(int id) async {
    final Map<String, dynamic> map = (await _theDatabase.query('user'))[0];
    final theItem = _workDataList.firstWhere((element) => element!.id == id);
    if (theItem!.hasBeenSubmitted == 0) {
      await _theDatabase.delete('work_data', where: 'id=?', whereArgs: [id]);
      _deleteWork(id);
      notifyListeners();
      return;
    }
    try {
      final connectivityResult =
          await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 4),
        onTimeout: () => throw Exception('no internet'),
      );

      if (!connectivityResult.isNotEmpty ||
          !connectivityResult[0].rawAddress.isNotEmpty) {
        throw Exception('no internet');
      }

      final data = _fireStore
          .collection('/users')
          .doc(map['shopName'])
          .collection('/workers')
          .doc((map['userId'] as int).toString())
          .collection('work');
      await data.doc(theItem.date.toIso8601String()).delete();
      await _theDatabase.delete('work_data', where: 'id=?', whereArgs: [id]);
      _deleteWork(id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addPaidAll(int amount, bool ok) async {
    final connectivityResult =
        await InternetAddress.lookup('google.com').timeout(
      const Duration(seconds: 4),
      onTimeout: () => throw Exception('no internet'),
    );

    if (!connectivityResult.isNotEmpty ||
        !connectivityResult[0].rawAddress.isNotEmpty) {
      throw Exception('no internet');
    }
    final map = (await _theDatabase.query('user'))[0];
    final paidAllLength = (await _theDatabase.query('paidAll')).length;
    _functions.httpsCallable('responsForPaidAll').call({
      'ok': ok,
      'shopId': map['shopName'],
      'workerId': map['userId'].toString(),
      'id': (paidAllLength + 1).toString(),
      'date': _paidNotification!.date.toIso8601String(),
      //amountSpent was by mistake but im too lazy to corret it because it needs deployment again
      'amountSpent': amount.toString(),
      'token': map['shopToken'],
      'message': ok
          ? 'تمت الموافقة على تصفية الحساب من قبل ${TheDatabase.userName.replaceAll('_', ' ')}'
          : 'تم رفض تصفية الحساب من قبل ${TheDatabase.userName.replaceAll('_', ' ')}',
      'messageBody': 'مبلغ $amount',
      'data': {
        'delete': ok ? '1' : '0',
        'amount': amount.toString(),
        'workerId': map['userId'].toString(),
        'date': _paidNotification!.date.toIso8601String(),
      },
    });
    if (ok) {
      await _theDatabase.insert('paidAll', {
        'amount': amount,
        'date': _paidNotification!.date.toIso8601String()
      });
    }
    await _theDatabase.delete('paidAll_notification');
    _getFromLocalDatabase(true);
  }
}
