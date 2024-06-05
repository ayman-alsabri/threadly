import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:soundpool/soundpool.dart';
import 'package:sqflite/sqflite.dart';
import 'package:usage_track/drawer.dart';
import 'package:usage_track/providers/database.dart';
import 'package:usage_track/providers/work_data.dart';

class SettengsScreen extends StatefulWidget {
  const SettengsScreen({super.key});
  static const route = 'settengs/screen';

  @override
  State<SettengsScreen> createState() => _SettengsScreenState();
}

class _SettengsScreenState extends State<SettengsScreen> {
  final pool = Soundpool.fromOptions(
      options:
          const SoundpoolOptions(maxStreams: 25, streamType: StreamType.music));
  int poolId = 0;
  @override
  void initState() {
    super.initState();
    rootBundle
        .load('assets/images/tick.ogg')
        .then((value) => pool.load(value))
        .then((value) => poolId = value);
  }

  @override
  void dispose() {
    super.dispose();
    pool.release();
  }

  Hero listTileBuilder(
    IconData icon,
    String title,
    Widget onPressed,
    BuildContext context,
    ThemeData theme,
  ) {
    return Hero(
      tag: title,
      child: Material(
        child: GestureDetector(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            color: theme.colorScheme.secondaryContainer.withOpacity(0.4),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    icon,
                    color: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        title.tr,
                        style: TextStyle(
                          color: theme.colorScheme.tertiary,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () => Navigator.push(
            context,
            PageRouteBuilder(
              reverseTransitionDuration: const Duration(milliseconds: 20),
              barrierDismissible: true,
              opaque: false,
              pageBuilder: (context, animation, secondaryAnimation) => Hero(
                tag: title,
                child: FittedBox(
                  child: Theme(
                    data: theme.copyWith(
                      radioTheme: RadioThemeData(
                        fillColor: MaterialStatePropertyAll(
                            theme.colorScheme.onPrimary),
                        overlayColor: MaterialStatePropertyAll(
                            theme.colorScheme.onPrimary),
                      ),
                      listTileTheme: ListTileThemeData(
                        leadingAndTrailingTextStyle: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onPrimary),
                      ),
                    ),
                    child: onPressed,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final thedatabase = TheDatabase.theDatabase;
    final theme = WorkData.currenTheme;
    final workData = Provider.of<WorkData>(context, listen: false);
    final list = workData.itemTypes;
    return Scaffold(
      appBar: AppBar(
        title: Text('settengs'.tr),
      ),
      body: ListView(
        children: [
          listTileBuilder(
            Icons.color_lens,
            'theme',
            const ThemeDialog(),
            context,
            theme,
          ),
          listTileBuilder(
            WorkData.currenTheme.brightness == Brightness.light
                ? Icons.dark_mode
                : Icons.light_mode,
            'theme mode',
            const ThemeModeDialog(),
            context,
            theme,
          ),
          listTileBuilder(
            Icons.star,
            'change default type',
            AlertDialog(
              title: Text('please select your default type'.tr),
              content: SizedBox(
                height: 300,
                child: ListWheelScrollView.useDelegate(
                  childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 2),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(15)),
                              child: InkWell(
                                onTap: () async {
                                  await workData
                                      .setFavoriteType(list[index]!.id);
                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                        flex: 3,
                                        fit: FlexFit.tight,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            list[index]!.name,
                                            style: TextStyle(
                                                fontSize: 40,
                                                color: theme.disabledColor),
                                          ),
                                        )),
                                    Flexible(
                                        flex: 1,
                                        child: Icon(
                                          Icons.touch_app_outlined,
                                          color: theme.disabledColor,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      childCount: list.length),
                  itemExtent: 90,
                  onSelectedItemChanged: (value) {
                    pool.play(poolId);
                  },
                  diameterRatio: 5,
                  useMagnifier: false,
                ),
              ),
            ),
            context,
            theme,
          ),
          listTileBuilder(
            Icons.language,
            'languages',
            AlertDialog(
              title: Text('languages'.tr),
              content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:

                      // content: const SizedBox(),
                      [
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await thedatabase.update('user', {'localCode': 'ar_EG'},
                            where: 'id=1',
                            conflictAlgorithm: ConflictAlgorithm.replace);
                        await TheDatabase.updatelocal();
                        await Get.updateLocale(const Locale('ar', 'EG'));
                      },
                      child: const Text('العربية'),
                    ),
                    TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await thedatabase.update(
                              'user', {'localCode': 'en_US'},
                              where: 'id=1',
                              conflictAlgorithm: ConflictAlgorithm.replace);
                          await TheDatabase.updatelocal();
                          await Get.updateLocale(const Locale('en', 'US'));
                        },
                        child: const Text('english'))
                  ]),
            ),
            context,
            theme,
          ),
        ],
      ),
    );
  }
}
