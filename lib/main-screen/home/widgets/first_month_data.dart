import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:usage_track/main-screen/providers/firebase_data.dart';
import 'package:usage_track/providers/work_data.dart';

class FirstMonthContainer extends StatelessWidget {
  const FirstMonthContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final workdata = Provider.of<WorkData>(context);
    Provider.of<FirebaseData>(context);
    final currentDate = DateTime.now();
    final currentMonth = workdata.currentMonth(currentDate);
    final size = MediaQuery.sizeOf(context);
    final theme = WorkData.currenTheme;

    List<Widget> putting(int index) {
      List<Widget> widgetlist = [];
      for (var element in currentMonth) {
        if (element.date.day == index + 1) {
          widgetlist.add(
            FittedBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'work: '.tr +
                        workdata.formatNumbers.format(element.quantity),
                    style: theme.textTheme.labelMedium,
                  ),
                  Text(
                    'spent: '.tr +
                        workdata.formatNumbers.format(element.amountSpent),
                    style: theme.textTheme.labelMedium,
                  ),
                  element.hasBeenSubmitted == 2
                      ? Icon(
                          Icons.check_circle_outline,
                          color: theme.colorScheme.background,
                          size: 15,
                        )
                      : element.hasBeenSubmitted==0? Icon(
                          Icons.av_timer,
                          color: theme.disabledColor,
                          size: 15,
                        ): Icon(Icons.timelapse_rounded,color: theme.disabledColor,
                          size: 15,),
                  const SizedBox(
                    height: 2,
                  ),
                ],
              ),
            ),
          );
        }
      }
      return widgetlist;
    }

    return Container(
      height: (size.height * 0.6),
      margin: const EdgeInsets.only(
        left: 5,
        right: 5,
        
      ),color: Colors.transparent,
      constraints: const BoxConstraints(maxHeight: double.maxFinite),
      child: Column(
        children: [
          ListTile(
            title: Text('data for month'.tr),
          ),
          Expanded(
            child: GridView.builder(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.all(10),
              itemCount:
                  DateTime(currentDate.year, currentDate.month + 1, 0).day,
              itemBuilder: (context, index) {
                var children = putting(index);
                return Card(
                  clipBehavior: Clip.hardEdge,
                  elevation: 3,
                  margin: const EdgeInsets.all(3),
                  child: Column(
                    children: [
                      Text(
                        (workdata.formatNumbers.format(index + 1)).toString(),
                        textAlign: TextAlign.start,
                        style: theme.textTheme.labelMedium,
                      ),
                      Expanded(
                        child: children.isEmpty
                            ? Center(
                                child: Icon(
                                Icons.feed,
                                color: theme.colorScheme.onPrimary
                                    .withOpacity(0.2),
                                size: 30,
                              ))
                            : SingleChildScrollView(
                                reverse: true,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: children,
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              },
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5),
            ),
          ),
        ],
      ),
    );
  }
}
