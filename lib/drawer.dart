import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:usage_track/auth-screen/providers/auth.dart';
import 'package:usage_track/providers/database.dart';
import 'package:usage_track/providers/theme.dart';
import 'package:usage_track/providers/work_data.dart';
import 'package:usage_track/settengs_screen/settengs_screen.dart';

class TheDrawer extends StatelessWidget {
  const TheDrawer({super.key});

  Hero _listTileBuilder(
    IconData icon,
    String title,
    Widget onPressed,
    BuildContext context,
    ThemeData theme,
  ) {
    return Hero(
      tag: title,
      child: Material(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title.tr),
          onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                reverseTransitionDuration: const Duration(milliseconds: 20),
                barrierDismissible: true,
                opaque: false,
                pageBuilder: (context, animation, secondaryAnimation) =>
                    Hero(tag: title, child: FittedBox(child: onPressed)),
              )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = WorkData.currenTheme;
    return Drawer(
      elevation: 0,
      child: SafeArea(
        child: Column(
          children: [
            AppBar(
              title: Text(TheDatabase.userName.replaceAll('_', ' ')),
              leading: const Icon(
                Icons.account_circle,
                size: 50,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: Text('settengs'.tr),
                    onTap: () =>
                        Navigator.pushNamed(context, SettengsScreen.route),
                  ),
                  _listTileBuilder(
                    Icons.logout,
                    'logout',
                    AlertDialog(
                      title: Text('logout'.tr),
                      content: Text('are you sure you want to logout'.tr),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('cancle'.tr)),
                        TextButton(
                            onPressed: () async {
                              await Provider.of<Auth>(context, listen: false)
                                  .logout(false);
                            },
                            child: Text('ok'.tr)),
                      ],
                    ),
                    context,
                    theme,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

//
//
//
//
//
//
//
//
//
//

class ThemeDialog extends StatefulWidget {
  const ThemeDialog({
    super.key,
  });

  @override
  State<ThemeDialog> createState() => _ThemeDialogState();
}

class _ThemeDialogState extends State<ThemeDialog> {
  late int groupValue;

  @override
  void initState() {
    super.initState();
    if (TheDatabase.themes == AppTheme.golden) {
      groupValue = 0;
      return;
    }
    if (TheDatabase.themes == AppTheme.grey) {
      groupValue = 1;
      return;
    }
    if (TheDatabase.themes == AppTheme.blue) {
      groupValue = 2;
      return;
    }
    if (TheDatabase.themes == AppTheme.brown) {
      groupValue = 3;
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('theme'.tr),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Text(
              'golden'.tr,
            ),
            trailing: Radio(
              value: 0,
              groupValue: groupValue,
              onChanged: (value) => setState(() {
                groupValue = value!;
              }),
            ),
          ),
          ListTile(
            leading: Text(
              'grey'.tr,
            ),
            trailing: Radio(
              value: 1,
              groupValue: groupValue,
              onChanged: (value) => setState(() {
                groupValue = value!;
              }),
            ),
          ),
          ListTile(
            leading: Text(
              'blue'.tr,
            ),
            trailing: Radio(
              value: 2,
              groupValue: groupValue,
              onChanged: (value) => setState(() {
                groupValue = value!;
              }),
            ),
          ),
          ListTile(
            leading: Text(
              'brown'.tr,
            ),
            trailing: Radio(
              value: 3,
              groupValue: groupValue,
              onChanged: (value) => setState(() {
                groupValue = value!;
              }),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('cancle'.tr)),
        TextButton(
            onPressed: () async {
              String databasemessage = 'golden';

              switch (groupValue) {
                case 0:
                  databasemessage = 'golden';
                  break;
                case 1:
                  databasemessage = 'grey';
                  break;
                case 2:
                  databasemessage = 'blue';
                  break;
                case 3:
                  databasemessage = 'brown';
                  break;
              }

              await TheDatabase.theDatabase.update(
                  'user', {'theme': databasemessage},
                  where: 'id=1', conflictAlgorithm: ConflictAlgorithm.replace);
              await TheDatabase.updateTheme();
              await Get.forceAppUpdate();
              // Get.changeThemeMode(themeMode);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: Text('ok'.tr)),
      ],
    );
  }
}

//
//
//
//
//
//
//
//

class ThemeModeDialog extends StatefulWidget {
  const ThemeModeDialog({
    super.key,
  });

  @override
  State<ThemeModeDialog> createState() => _ThemeModeDialogState();
}

class _ThemeModeDialogState extends State<ThemeModeDialog> {
  late int groupValue;
  @override
  void initState() {
    super.initState();
    final int groupValuedummy;
    switch (TheDatabase.themeMode) {
      case ThemeMode.system:
        groupValuedummy = 0;
        break;
      case ThemeMode.dark:
        groupValuedummy = 2;
        break;
      case ThemeMode.light:
        groupValuedummy = 1;
        break;
    }
    groupValue = groupValuedummy;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('theme mode'.tr),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Text(
              'auto'.tr,
            ),
            trailing: Radio(
              value: 0,
              groupValue: groupValue,
              onChanged: (value) => setState(() {
                groupValue = value!;
              }),
            ),
          ),
          ListTile(
            leading: Text(
              'light'.tr,
            ),
            trailing: Radio(
              value: 1,
              groupValue: groupValue,
              onChanged: (value) => setState(() {
                groupValue = value!;
              }),
            ),
          ),
          ListTile(
            leading: Text(
              'dark'.tr,
            ),
            trailing: Radio(
              value: 2,
              groupValue: groupValue,
              onChanged: (value) => setState(() {
                groupValue = value!;
              }),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('cancle'.tr)),
        TextButton(
            onPressed: () async {
              String databasemessage = 'auto';

              switch (groupValue) {
                case 0:
                  databasemessage = 'auto';
                  break;
                case 1:
                  databasemessage = 'light';
                  break;
                case 2:
                  databasemessage = 'dark';
                  break;
              }

              await TheDatabase.theDatabase.update(
                  'user', {'themeMode': databasemessage},
                  where: 'id=1', conflictAlgorithm: ConflictAlgorithm.replace);
              await TheDatabase.updateThemeMode();
              await Get.forceAppUpdate();
              // Get.changeThemeMode(themeMode);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: Text('ok'.tr)),
      ],
    );
  }
}
