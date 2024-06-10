import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:usage_track/main-screen/home/widgets/custom_dialog.dart';
import 'package:usage_track/providers/database.dart';
import 'package:usage_track/providers/work_data.dart';

class AllMonthesData extends StatefulWidget {
  const AllMonthesData({
    super.key,
  });

  @override
  State<AllMonthesData> createState() => _AllMonthesDataState();
}

class _AllMonthesDataState extends State<AllMonthesData> {
  var isExpanded = false;

  late final workData = Provider.of<WorkData>(context);

  late final list = workData.list;
  late final firstItem = list.isEmpty ? null : list.first;
  final currentDate = DateTime.now();

  final theme = WorkData.currenTheme;
  late final size = MediaQuery.sizeOf(context);

  int builderCount(DayWork? firstItem, DateTime currentDate) {
    if (firstItem == null) return 0;
    int tempcount = 0;
    tempcount = currentDate.year - firstItem.date.year;
    if (tempcount > 0) {
      //only here if first item isnt in the same year
      if (tempcount > 1) {
        tempcount *= (tempcount - 1) * 12;
      }
      tempcount += (12 - firstItem.date.month);
      tempcount += (currentDate.month - 1);
    } else {
      tempcount = currentDate.month - firstItem.date.month;
    }

    // if(firstItem.date.month==currentDate.month && firstItem.date.year == currentDate.year){
    //   return 0;
    // }
    return tempcount;
  }

  List indicateYearAndMonth(
      int index, DateTime currentDate, WorkData workData) {
    int year = firstItem!.date.year;
    int month = firstItem!.date.month + index - 1;
    if (month > 12) {
      year += month ~/ 12;
      month %= 12;
      if (month == 0) {
        month = 12;
      }
    }

    // if (index < currentDate.month) {
    //   month = currentDate.month - index - 1;
    //   return [year + 1, month];
    // }
    // for (int a = 1; a < index; a++) {
    //   month -= 1;
    //   if (a % 12 == 0) {
    //     year -= 1;
    //     month = 12;
    //   }
    // }
    return [year, month];
  }

  @override
  Widget build(BuildContext context) {
    double containerCount = (builderCount(firstItem, currentDate) / 2);
    return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        alignment: Alignment.center,
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: theme.scaffoldBackgroundColor.withOpacity(0.5),
                blurRadius: 1,
                offset: const Offset(0, -3))
          ],
          color: theme.colorScheme.secondaryContainer,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(40),
          ),
        ),
        height: isExpanded
            ? size.height * 0.6
            : firstItem == null
                ? size.height * 0.2
                : containerCount > 2
                    ? size.height * 0.4
                    : containerCount.floor() * size.height * 0.1 +
                        size.height * 0.2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IconButton(
                tooltip: 'expand'.tr,
                onPressed: () => setState(() {
                      isExpanded = !isExpanded;
                    }),
                icon: Icon(isExpanded ? Icons.expand_more : Icons.expand_less)),
            (firstItem == null || firstItem!.date.month == currentDate.month)
                ? Center(child: Text('data'.tr))
                : Expanded(
                    child: GridView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2),
                      // clipBehavior: Clip.none,
                      itemCount: builderCount(firstItem, currentDate),
                      itemBuilder: (context, index) {
                        final yearMonth = indicateYearAndMonth(
                            index + 1, currentDate, workData);

                        final titleText =
                            '${'data for'.tr}${DateFormat.yM(TheDatabase.localCode).format(DateTime(yearMonth[0], yearMonth[1]))}';

                        return InkWell(
                          highlightColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () => Navigator.push(
                            context,
                            PageRouteBuilder(
                              barrierDismissible: true,
                              transitionDuration:
                                  const Duration(milliseconds: 1000),
                              reverseTransitionDuration:
                                  const Duration(microseconds: 10),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      CustomDialog(
                                titleText: titleText,
                                yearMonth: yearMonth,
                              ),
                              opaque: false,
                            ),
                          ),
                          child: Hero(
                            tag: titleText,
                            child: Card(
                              margin: const EdgeInsets.only(
                                  bottom: 15, top: 15, left: 10, right: 10),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: FittedBox(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        titleText,
                                        style: theme.textTheme.headlineMedium,
                                      ),
                                      Icon(
                                        Icons.touch_app,
                                        color: theme.colorScheme.onSecondary,
                                      ),
                                      Text('press to view full data'.tr),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ));
  }
}
