import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:usage_track/providers/work_data.dart';

class CustomDialog extends StatelessWidget {
  final String titleText;
  final List yearMonth;
  const CustomDialog(
      {super.key, required this.titleText, required this.yearMonth});
  @override
  Widget build(BuildContext context) {
    final theme = WorkData.currenTheme;
    final workdata = Provider.of<WorkData>(context);
    final currentMonth =
        workdata.currentMonth(DateTime(yearMonth[0], yearMonth[1]));

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
                      : element.hasBeenSubmitted == 0
                          ? Icon(
                              Icons.av_timer,
                              color: theme.disabledColor,
                              size: 15,
                            )
                          : Icon(
                              Icons.timelapse_rounded,
                              color: theme.disabledColor,
                              size: 15,
                            ),
                  // Icon(
                  //   Icons.av_timer,
                  //   color: theme.disabledColor,
                  //   size: 15,
                  // ),
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

    return Hero(
      tag: titleText,
      child: Dialog(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  titleText,
                  style: theme.textTheme.headlineMedium!
                      .copyWith(color: theme.colorScheme.secondary),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(10),
                itemCount: DateTime(yearMonth[0], yearMonth[1] + 1, 0).day,
                itemBuilder: (context, index) {
                  var children = putting(index);
                  return Card(
                    clipBehavior: Clip.hardEdge,
                    elevation: 3,
                    margin: const EdgeInsets.all(3),
                    child: Column(
                      children: [
                        Expanded(
                          child: Text(
                            (workdata.formatNumbers.format(index + 1))
                                .toString(),
                            textAlign: TextAlign.start,
                            style: theme.textTheme.labelMedium!,
                          ),
                        ),
                        Flexible(
                          flex: 3,
                          child: children.isEmpty
                              ? Center(
                                  child: Icon(
                                  Icons.feed,
                                  color: theme.colorScheme.onPrimary
                                      .withOpacity(0.2),
                                  size: 30,
                                ))
                              : SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(
                                      decelerationRate:
                                          ScrollDecelerationRate.fast),
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
            ],
          ),
        ),
      ),
    );
  }
}
