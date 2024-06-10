import 'dart:async';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:usage_track/auth-screen/providers/auth.dart';
import 'package:usage_track/drawer.dart';
import 'package:usage_track/main-screen/add_dialog.dart';
import 'package:usage_track/main-screen/history/history_page.dart';
import 'package:usage_track/main-screen/home/home_page.dart';
import 'package:usage_track/main-screen/payment_dialog.dart';
import 'package:usage_track/main-screen/providers/firebase_data.dart';
import 'package:usage_track/main-screen/widgets/bottom_bar.dart';
import 'package:usage_track/providers/database.dart';
import 'package:usage_track/providers/work_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const route = 'home/screen';

  Future _setAllData(FirebaseData firebaseData, WorkData workData,
      BuildContext context) async {
    await initializeDateFormatting(TheDatabase.localCode);
    try {
      await workData.getFromLocalDatabase(false);
      await firebaseData.hasPaid();
      if (TheDatabase.firstInit) {
        await firebaseData
            .addWorkToFirebase()
            .then((value) => firebaseData.getAndSetData())
            .then((value) => workData.getFromLocalDatabase(true));
        await TheDatabase.updateFirstInit();
      }
      // await firebaseData.getAndSetData();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('no internet connection or internet is very slow'.tr),
        ),
      );
    }
    if (TheDatabase.firstInit) return;
    firebaseData
        .addWorkToFirebase()
        .then((value) => firebaseData.getAndSetData())
        .then((value) => workData.getFromLocalDatabase(true))
        .catchError(
      (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('no internet connection or internet is very slow'.tr),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final workData = Provider.of<WorkData>(context, listen: false);
    final firebaseData = Provider.of<FirebaseData>(context, listen: false);

    final width = MediaQuery.sizeOf(context).width;
    return FutureBuilder(
        future: _setAllData(firebaseData, workData, context),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Scaffold(
                    body: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/icons/threadly.png',
                            color: WorkData.currenTheme.colorScheme.secondary,
                            width: 150,
                          ),
                          LoadingAnimationWidget.staggeredDotsWave(
                            color: WorkData.currenTheme.colorScheme.secondary,
                            size: width * 0.2,
                          ),
                        ],
                      ),
                    ),
                  )
                : firebaseData.getHasPaid
                    ? const ValidHomeScreen()
                    : const PaymentScreen());
  }
}

//

//payment screen

//
class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = WorkData.currenTheme;
    final size = MediaQuery.sizeOf(context);

    // final firebaseData = Provider.of<FirebaseData>(context);
    // print(firebaseData.getHasPaid);

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.account_circle_outlined,
          size: 50,
        ),
        title: Text(TheDatabase.userName.replaceAll('_', ' ')),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
              onPressed: Get.forceAppUpdate, icon: const Icon(Icons.sync))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: double.maxFinite,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                  'assets/images/payment-background-${theme.brightness == Brightness.light ? 'black' : 'white'}.png'),
              fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: FutureBuilder(
              future: TheDatabase.theDatabase.query('user'),
              builder: (context, list) {
                if (list.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }
                final amount = list.data?[0]['paymentAmount'];
                final format = WorkData().formatNumbers;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: size.height * 0.04,
                        ),
                        Text(
                          'payment first'.tr,
                          style: theme.textTheme.headlineSmall,
                        ),
                        SizedBox(height: size.height * 0.03),
                        Text(
                          'firstDetails'.tr +
                              format.format(amount) +
                              'ryals'.tr +
                              'details'.tr,
                          style: theme.textTheme.labelLarge,
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            // margin: const EdgeInsets.only(bottom: 80),
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            width: size.width * 0.9,
                            child: Column(children: [
                              ListTile(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          'scan to pay'.tr,
                                          textAlign: TextAlign.center,
                                        ),
                                        content: Image.asset(
                                            'assets/images/extra/kuraimi.jpg'),
                                        actions: const [
                                          SelectableText('3006535177')
                                        ],
                                        actionsAlignment:
                                            MainAxisAlignment.center,
                                      );
                                    },
                                  );
                                },
                                leading: Image.asset(
                                    'assets/images/kuraimi-icon.png'),
                                title: Text(
                                  'kuraimi'.tr,
                                  style: theme.textTheme.labelMedium,
                                ),
                                subtitle: Text(
                                  'click for more information'.tr,
                                  style: theme.textTheme.labelSmall,
                                ),
                                trailing: const Icon(Icons.payment),
                              ),
                              ListTile(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          'scan to pay'.tr,
                                          textAlign: TextAlign.center,
                                        ),
                                        content: Image.asset(
                                            'assets/images/extra/jawali.jpg'),
                                      );
                                    },
                                  );
                                },
                                leading: Image.asset(
                                    'assets/images/jawali-icon.png'),
                                title: Text(
                                  'jawali'.tr,
                                  style: theme.textTheme.labelMedium,
                                ),
                                subtitle: Text(
                                  'click for more information'.tr,
                                  style: theme.textTheme.labelSmall,
                                ),
                                trailing: const Icon(Icons.payment),
                              ),
                              ListTile(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          'scan to pay'.tr,
                                          textAlign: TextAlign.center,
                                        ),
                                        content: Image.asset(
                                            'assets/images/extra/btc.jpg'),
                                        actions: const [
                                          SelectableText(
                                              'bc1qn6l84d44xgkvufv0n6lr7zdz2cgkw0kunyy7ds')
                                        ],
                                        actionsAlignment:
                                            MainAxisAlignment.center,
                                      );
                                    },
                                  );
                                },
                                leading: Image.asset(
                                    'assets/images/bitcoin-icon.png'),
                                title: Text(
                                  'bitcoin'.tr,
                                  style: theme.textTheme.labelMedium,
                                ),
                                subtitle: Text(
                                  'click for more information'.tr,
                                  style: theme.textTheme.labelSmall,
                                ),
                                trailing: const Icon(Icons.currency_bitcoin),
                              ),
                              ListTile(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          'scan to pay'.tr,
                                          textAlign: TextAlign.center,
                                        ),
                                        content: Image.asset(
                                            'assets/images/extra/usdt.jpg'),
                                        actions: const [
                                          SelectableText(
                                              '6fgCpH22RqwTvSRD5QMU82WCKYPpRfnEUnVmCkHqazDq')
                                        ],
                                        actionsAlignment:
                                            MainAxisAlignment.center,
                                      );
                                    },
                                  );
                                },
                                leading:
                                    Image.asset('assets/images/usdt-icon.png'),
                                title: Text(
                                  'usdt'.tr,
                                  style: theme.textTheme.labelMedium,
                                ),
                                subtitle: Text(
                                  'click for more information'.tr,
                                  style: theme.textTheme.labelSmall,
                                ),
                                trailing: const Icon(Icons.attach_money),
                              ),
                            ]),
                          ),
                        ),
                      ),
                    )
                  ],
                );
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Provider.of<Auth>(context, listen: false).logout(false);
          },
          child: const Text('logout')),
    );
  }
}

//

// paid screen

//

@pragma('vm:entry-point')
Future<void> onBackgroundMessageHandler(RemoteMessage message) async {
  Database theDatabase;
  bool isArabic = true;
  String? title = message.notification?.title;
  String? body = message.notification?.body;

  try {
    theDatabase = TheDatabase.theDatabase;
  } catch (e) {
    theDatabase =
        await openDatabase('${await getDatabasesPath()}/statistics.db');
    // theDatabase = TheDatabase.theDatabase;
  }

  isArabic = (((await theDatabase.query('user'))[0])['localCode'] as String)
      .contains('ar');

  if (message.data.length == 2) {
    final orignalId = message.data['originalId'];
    final work = (await theDatabase
        .query('work_data', where: 'id=?', whereArgs: [orignalId]))[0];
    final delete = int.parse(message.data['delete']);
    if (delete == 1) {
      await theDatabase
          .delete('work_data', where: 'id=?', whereArgs: [orignalId]);
    } else {
      await theDatabase.update('work_data', {'hasBeenSubmitted': 2},
          where: 'id=?', whereArgs: [orignalId]);
    }
    title = delete == 1
        ? isArabic
            ? 'تم رفض العمل'
            : 'work has been declined'
        : isArabic
            ? 'تمت الموافقة على العمل'
            : 'work has been accepted';

    body = delete == 1
        ? isArabic
            ? 'تم رفض العمل: ${work['quantity']} ${work['typeName']} ومبلغ  ${work['amountSpent']} ريال'
            : 'your work: ${work['quantity']} ${work['typeName']} and amount  ${work['amountSpent']} ryals has been declined'
        : isArabic
            ? 'تمت الموافقة على العمل: ${work['quantity']} ${work['typeName']} ومبلغ  ${work['amountSpent']} ريال'
            : 'your work: ${work['quantity']} ${work['typeName']} and amount  ${work['amountSpent']} ryals has been accepted';
  }
  if (message.data.length == 3) {
    await theDatabase.insert(
      'paidAll_notification',
      {
        'amount': int.parse(message.data['amount']),
        'date': message.data['date'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    title = isArabic ? 'طلب تصفية الحساب' : 'request for clearing the record';
    body = isArabic
        ? ' تصفية الحساب بمبلغ ${message.data['amount']}'
        : 'clearitg the record with ${message.data['amount']}ryals';
  }

  if (message.data.length == 4) {
    final edit = int.parse(message.data['edit']);
    final price = int.parse(message.data['price']);
    final id = int.parse(message.data['id']);
    final name = message.data['name'];
    if (edit == 1) {
      await theDatabase.update(
        'types',
        {
          'price': price,
        },
        where: 'name=?',
        whereArgs: [name],
      );
    } else {
      await theDatabase.insert(
        'types',
        {'id': id, 'price': price, 'name': name, 'isFavorite': 0},
      );
    }
    title = edit == 1
        ? isArabic
            ? 'تم تعديل سعر القطعة ($name)'
            : 'type ($name) price has been updated'
        : isArabic
            ? 'تمت اضافة نوع جديد'
            : 'new type added';
    body = edit == 1
        ? isArabic
            ? 'السعر الجديد $price'
            : '$price is the new price'
        : isArabic
            ? 'النوع: $name , سعر القطعة: $price'
            : 'type name: $name , price: $price';
  }
  if (message.data.length == 1) {
    if (message.data['id'] == null) return;
    final id = int.parse(message.data['id']);
    await theDatabase.delete('work_data', where: 'id=?', whereArgs: [id]);
    title = isArabic
        ? 'خطأ. لم يتم تسليم الطلب'
        : 'ERROR. request has not been submitted';
    body = isArabic
        ? 'تأكد أن التطبيق مثبت لدى المستخدم'
        : 'please make sure that the app is installed with the user';
  }

  await FlutterLocalNotificationsPlugin().show(
      message.messageId?.hashCode ?? 1,
      title,
      body,
      const NotificationDetails(
          android: AndroidNotificationDetails(
        'high_importance_channel', 'High Importance Notifications',
        // color: WorkData.currenTheme.colorScheme.secondary
      )));
}

class ValidHomeScreen extends StatefulWidget {
  const ValidHomeScreen({super.key});

  @override
  State<ValidHomeScreen> createState() => _ValidHomeScreenState();
}

class _ValidHomeScreenState extends State<ValidHomeScreen>
    with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Provider.of<FirebaseData>(context, listen: false)
          .addWorkToFirebase()
          .then((value) => _workdata.getFromLocalDatabase(true))
          .catchError((e) => _workdata.getFromLocalDatabase(true));
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessageHandler);
    FirebaseMessaging.onMessage.listen((message) async {
      final theDatabase = TheDatabase.theDatabase;
      bool isArabic = TheDatabase.localCode.contains('ar');
      String? title = message.notification?.title;
      String? body = message.notification?.body;

      if (message.data.length == 2) {
        final orignalId = message.data['originalId'];
        final work = (await theDatabase
            .query('work_data', where: 'id=?', whereArgs: [orignalId]))[0];
        final delete = int.parse(message.data['delete']);
        if (delete == 1) {
          await theDatabase
              .delete('work_data', where: 'id=?', whereArgs: [orignalId]);
        } else {
          await theDatabase.update('work_data', {'hasBeenSubmitted': 2},
              where: 'id=?', whereArgs: [orignalId]);
        }
        title = delete == 1
            ? isArabic
                ? 'تم رفض العمل'
                : 'work has been declined'
            : isArabic
                ? 'تمت الموافقة على العمل'
                : 'work has been accepted';

        body = delete == 1
            ? isArabic
                ? 'تم رفض العمل: ${work['quantity']} ${work['typeName']} ومبلغ  ${work['amountSpent']} ريال'
                : 'your work: ${work['quantity']} ${work['typeName']} and amount  ${work['amountSpent']} ryals has been declined'
            : isArabic
                ? 'تمت الموافقة على العمل: ${work['quantity']} ${work['typeName']} ومبلغ  ${work['amountSpent']} ريال'
                : 'your work: ${work['quantity']} ${work['typeName']} and amount  ${work['amountSpent']} ryals has been accepted';
      }
      if (message.data.length == 3) {
        await theDatabase.insert(
          'paidAll_notification',
          {
            'amount': int.parse(message.data['amount']),
            'date': message.data['date'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        title =
            isArabic ? 'طلب تصفية الحساب' : 'request for clearing the record';
        body = isArabic
            ? ' تصفية الحساب بمبلغ ${message.data['amount']}'
            : 'clearitg the record with ${message.data['amount']}ryals';
      }

      if (message.data.length == 4) {
        final edit = int.parse(message.data['edit']);
        final price = int.parse(message.data['price']);
        final id = int.parse(message.data['id']);
        final name = message.data['name'];
        if (edit == 1) {
          await theDatabase.update(
            'types',
            {
              'price': price,
            },
            where: 'name=?',
            whereArgs: [name],
          );
        } else {
          await theDatabase.insert(
            'types',
            {'id': id, 'price': price, 'name': name, 'isFavorite': 0},
          );
        }
        title = edit == 1
            ? isArabic
                ? 'تم تعديل سعر القطعة ($name)'
                : 'type ($name) price has been updated'
            : isArabic
                ? 'تمت اضافة نوع جديد'
                : 'new type added';
        body = edit == 1
            ? isArabic
                ? 'السعر الجديد $price'
                : '$price is the new price'
            : isArabic
                ? 'النوع: $name , سعر القطعة: $price'
                : 'type name: $name , price: $price';
      }
      if (message.data.length == 1) {
        if (message.data['id'] == null) return;
        final id = int.parse(message.data['id']);
        await theDatabase.delete(
          'work_data',
          where: 'id=?',
          whereArgs: [id],
        );
        title = isArabic
            ? 'خطأ. لم يتم تسليم الطلب'
            : 'ERROR. request has not been submitted';
        body = isArabic
            ? 'تأكد أن التطبيق مثبت لدى المستخدم'
            : 'please make sure that the app is installed with the user';
      }

      FlutterLocalNotificationsPlugin().show(
          message.messageId?.hashCode ?? 1,
          title,
          body,
          const NotificationDetails(
              android: AndroidNotificationDetails(
            'high_importance_channel', 'High Importance Notifications',
            // color: WorkData.currenTheme.colorScheme.secondary
          )));
      await _workdata.getFromLocalDatabase(true);
    });
  }

  late final _workdata = Provider.of<WorkData>(context, listen: false);
  late final _controller = PageController();

  bool _animation = false;
  bool _isSyncing = false;

  final _theme = WorkData.currenTheme;
  int _selected = 0;
  final List _pages = [
    {'body': const HomePage(), 'title': 'work data'.tr},
    {'body': const HistoryPage(), 'title': 'history'.tr},
  ];

  void _onTap(int index) async {
    if (index != _selected) {
      setState(() {
        _animation = true;
      });

      index == 1
          ? await _controller.nextPage(
              duration: const Duration(milliseconds: 300), curve: Curves.linear)
          : await _controller.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear);
    }
    setState(() {
      _animation = false;
      _selected = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final firebasedata = Provider.of<FirebaseData>(context, listen: false);
    final _ = Provider.of<FirebaseData>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: 'open drawer'.tr,
          );
        }),
        title: AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            opacity: _animation ? 0 : 1,
            child: Text(_pages[_selected]['title'])),
        actions: [
          if (_workdata.paidNotification != null)
            Builder(
              builder: (context) => IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const PaymentDialog(),
                    );
                  },
                  icon: Icon(
                    Icons.notification_important,
                    color: _theme.colorScheme.error,
                  )),
            ),
          Builder(builder: (context) {
            return IconButton(
              onPressed: _isSyncing
                  ? () {}
                  : () async {
                      setState(() {
                        _isSyncing = true;
                      });
                      try {
                        await firebasedata.hasPaid();
                        await firebasedata.addWorkToFirebase();
                        await firebasedata.getAndSetData();
                        await _workdata.getFromLocalDatabase(true);
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('can\'t sync now, please try again'.tr),
                          ),
                        );
                      } finally {
                        setState(() {
                          _isSyncing = false;
                        });
                      }
                    },
              icon: _isSyncing
                  ? Icon(
                      Icons.sync_lock,
                      color: _theme.colorScheme.primary.withOpacity(0.5),
                    )
                  : const Icon(Icons.sync),
              tooltip: 'sync'.tr,
            );
          })
        ],
      ),
      body: PageView(
        onPageChanged: _onTap,
        controller: _controller,
        children: const [
          (HomePage()),
          (HistoryPage()),
        ],
      ),
      drawer: const TheDrawer(),
      bottomNavigationBar: BottomBar(selected: _selected, onTap: _onTap),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (context) => _workdata.itemTypes.isEmpty
                  ? Center(
                      child: Text(
                      'no types yet'.tr,
                      style: _theme.textTheme.headlineSmall,
                    ))
                  : const AddDialog(),
              backgroundColor: _theme.scaffoldBackgroundColor,
              elevation: 1);

          // FirebaseAuth.instance.signOut();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
