// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:intl/intl.dart';
import 'package:usage_track/providers/database.dart';

class WorkData with ChangeNotifier {
  final _database = TheDatabase.theDatabase;

  // bool _firstInit = true;

  List<PaidALL?> _paidList = [];
  List<ItemType?> _itemTypes = [];
  List<DayWork?> _list = [];
  PaidNotification? _paidNotification;

  List<DayWork?> get list {
    return [..._list];
  }

  PaidNotification? get paidNotification {
    return _paidNotification;
  }

  List<PaidALL?> get paidList {
    return [..._paidList];
  }

  List<ItemType?> get itemTypes {
    return [..._itemTypes];
  }

  ItemType? get favoriteType {
    ItemType? item;
    for (var element in _itemTypes) {
      if (element!.isFavorite) {
        item = element;
      }
    }
    return item;
  }

  List<List<DayWork?>> get validAndUnvalidList {
    List<DayWork?> valid = [];
    List<DayWork?> unvalid = [];
    if (_paidList.isEmpty) {
      valid = _list.where((element) => element!.hasBeenSubmitted == 2).toList();
      return [valid, unvalid];
    }

    final lastPiad = _paidList.last;
    for (var element in _list) {
      if (element!.date.isAfter(lastPiad!.date) &&
          element.hasBeenSubmitted == 2) {
        valid.add(element);
      }

      if (element.date.isBefore(lastPiad.date) &&
          element.hasBeenSubmitted == 2) {
        unvalid.add(element);
      }
    }

    return [valid, unvalid];
  }

  List<DayWork?> get unsubmiitedList {
    // if(_list.isEmpty)return[];
    return (list.where((element) => element!.hasBeenSubmitted == 0).toList());
  }

  List<DayWork> currentMonth(DateTime date) {
    final List<DayWork> local = [];
    for (var element in _list) {
      if (element!.date.year == date.year && element.date.month == date.month) {
        local.add(element);
      }
    }
    return local;
  }

  Future<void> addWork({
    required int quantity,
    required int amountSpent,
    required String typeName,
    required int id,
    required DateTime date,
    required int hasBeenSubmitted,
  }) async {
    final workDay = DayWork(
        id: id,
        type: _itemTypes.firstWhere((element) => element!.name == typeName)!,
        quantity: quantity,
        amountSpent: amountSpent,
        date: date,
        hasBeenSubmitted: hasBeenSubmitted);
    //it will throw an error if there are no types
    _list.add(workDay);
    // notifyListeners();
  }

  void deleteWork(int id) {
    _list.removeWhere(
      (element) => element!.id == id,
    );
    notifyListeners();
  }

  Future<void> setFavoriteType(int id) async {
    ItemType? previous;
    for (var element in _itemTypes) {
      if (element!.isFavorite) {
        previous = element;
        element.isFavorite = false;
      }

      if (element.id == id) {
        element.isFavorite = true;
      }
    }
    await _database.update('types', {'isFavorite': 1},
        where: 'id=?', whereArgs: [id]);
    if (previous != null) {
      await _database.update('types', {'isFavorite': 0},
          where: 'id=?', whereArgs: [previous.id]);
    }
    notifyListeners();
  }

  Future<void> getFromLocalDatabase(bool notify) async {
// get deafault item types
    final listTypes = await _database.query('types');
    List<ItemType?> templist = [];

    for (var element in listTypes) {
      // print(element['id'].runtimeType);
      templist.add(ItemType(
        isFavorite: element['isFavorite'] == 1,
        id: element['id'] as int,
        name: element['name'] as String,
        price: element['price'] as int,
      ));
    }

    if (templist.isEmpty) return;

    _itemTypes = templist;
//get daywork list

    List<DayWork?> templist2 = [];
    final list = await _database.query('work_data');
    for (var dayWork in list) {
      templist2.add(DayWork(
        id: dayWork['id'] as int,
        type:
            _itemTypes.firstWhere((type) => type?.name == dayWork['typeName'])!,
        quantity: dayWork['quantity'] as int,
        amountSpent: dayWork['amountSpent'] as int,
        date: DateTime.parse(
          dayWork['date'] as String,
        ),
        hasBeenSubmitted: dayWork['hasBeenSubmitted'] as int,
      ));
    }
    // if (templist2.isEmpty) return;
    _list = templist2;

    //get paidall list
    final List<PaidALL?> templist3 = [];
    final listPaidAll = await _database.query('paidAll');
    for (var element in listPaidAll) {
      templist3.add(PaidALL(
        id: element['id'] as int,
        amount: element['amount'] as int,
        date: DateTime.parse(element['date'] as String),
      ));
    }
    _paidList = templist3;
    final map = (await _database.query('paidAll_notification'));
    if (map.isNotEmpty) {
      _paidNotification = PaidNotification(
        date: DateTime.parse(map[0]['date'] as String),
        amount: map[0]['amount'] as int,
      );
    } else {
      _paidNotification = null;
    }
    // try {
    //   if (_firstInit) {
    //     final connectivityResult =
    //         await InternetAddress.lookup('google.com').timeout(
    //       const Duration(seconds: 4),
    //       onTimeout: () => throw Exception('no internet'),
    //     );

    //     if (!connectivityResult.isNotEmpty ||
    //         !connectivityResult[0].rawAddress.isNotEmpty) {
    //       throw Exception('no internet');
    //     }
    //     final fireStore = FirebaseFirestore.instance;
    //     final map = (await _database.query('user'))[0];
    //     final List<DayWork> delete = [];
    //     final List<DayWork> update = [];
    //     for (var element in _list) {
    //       if (element!.date
    //           .isBefore(DateTime.now().subtract(const Duration(days: 7 * 4)))) {
    //         if ((await fireStore
    //                 .collection('/users')
    //                 .doc(map['shopName'] as String)
    //                 .collection('/workers')
    //                 .doc((map['userId'] as int).toString())
    //                 .collection('/work')
    //                 .doc(element.date.toIso8601String())
    //                 .get())
    //             .exists) {
    //           await _database.update('work_data', {'hasBeenSubmitted': 2},
    //               where: 'id=?', whereArgs: [element.id]);
    //           update.add(element);
    //         } else {
    //           await _database
    //               .delete('work_data', where: 'id=?', whereArgs: [element.id]);
    //           delete.add(element);
    //         }
    //       }
    //     }
    //     for (var element in delete) {
    //       _list.remove(element);
    //     }
    //     for (var element in update) {
    //       for (var listelement in _list) {
    //         if (listelement!.id == element.id) {
    //           listelement.hasBeenSubmitted = 2;
    //           break;
    //         }
    //       }
    //     }
    //     _firstInit = false;
    //   }
    // } catch (e) {
    //   print('.\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n');
    //   print(e);
    //   print('.\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n');
    // }
    // if (_paidNotification?.date
    //         .isBefore(DateTime.now().subtract(const Duration(days: 7 * 4))) ??
    //     false) {
    //   await _database.delete('paidAll_notification');
    //   _paidNotification = null;
    // }
    if (notify) {
      notifyListeners();
    }
  }

  void noti() {
    notifyListeners();
  }

  //numberFormat and currentTheme

  NumberFormat get formatNumbers {
    return NumberFormat('##,###,###.##', TheDatabase.localCode);
  }

  static ThemeData get currenTheme {
    // return AppTheme.darkTheme;
    switch (TheDatabase.themeMode) {
      case ThemeMode.system:
        {
          var brightness =
              SchedulerBinding.instance.platformDispatcher.platformBrightness;
          switch (brightness) {
            case Brightness.dark:
              return TheDatabase.themes[1];
            case Brightness.light:
              return TheDatabase.themes[0];
          }
        }
      case ThemeMode.light:
        return TheDatabase.themes[0];
      case ThemeMode.dark:
        return TheDatabase.themes[1];
    }
  }
}

// all final for the shop owner to provide in order to force them to buy
class ItemType {
  final String name;
  bool isFavorite;
  final int price;
  final int id;

  ItemType({
    required this.id,
    required this.name,
    required this.price,
    required this.isFavorite,
  });
}

//all final in order to not change and cheate
class DayWork {
  final ItemType type;
  final int quantity;
  final int amountSpent;
  final DateTime date;
  final int id;
  int hasBeenSubmitted;

  DayWork({
    required this.id,
    required this.type,
    required this.quantity,
    required this.amountSpent,
    required this.date,
    this.hasBeenSubmitted = 0,
  });
}

class PaidALL {
  final DateTime date;
  final int amount;
  final int id;

  PaidALL({
    required this.id,
    required this.amount,
    required this.date,
  });
}

class PaidNotification {
  final DateTime date;
  final int amount;

  PaidNotification({
    required this.date,
    required this.amount,
  });
}
