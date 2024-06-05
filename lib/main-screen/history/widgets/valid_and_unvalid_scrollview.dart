import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:usage_track/main-screen/providers/firebase_data.dart';
import 'package:usage_track/providers/database.dart';
import 'package:usage_track/providers/work_data.dart';

class ValidAndUnvalidScroll extends StatelessWidget {
  const ValidAndUnvalidScroll({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            ValidContainer(),
            SizedBox(height: 10),
            UnvalidContainer(),
          ],
        ),
      ),
    );
  }
}

//valid
class ValidContainer extends StatefulWidget {
  const ValidContainer({super.key});

  @override
  State<ValidContainer> createState() => _ValidContainerState();
}

class _ValidContainerState extends State<ValidContainer> {
  final _theme = WorkData.currenTheme;
  late final _format =
      Provider.of<WorkData>(context).formatNumbers;
  late final _size = MediaQuery.sizeOf(context);

  var _isExpanded = true;

  void _onTap() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final firebaseData = Provider.of<FirebaseData>(context,listen:false);
    final workData = Provider.of<WorkData>(context, listen: false);
    final validUnvalid = workData.validAndUnvalidList[0].reversed.toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      constraints: BoxConstraints(
        minHeight: 0,
        maxHeight: _size.height * 0.45,
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: _theme.colorScheme.primary.withOpacity(0.1),
            blurStyle: BlurStyle.normal,
            blurRadius: 5,
            offset: const Offset(-3, 4.5),
          )
        ],
        color: _theme.colorScheme.secondaryContainer,
        borderRadius: const BorderRadiusDirectional.all(Radius.circular(30)),
      ),
      clipBehavior: Clip.hardEdge,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: _onTap,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Card(
                elevation: 0,
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'valid data'.tr,
                        style: _theme.textTheme.headlineSmall!
                            .copyWith(fontSize: 25),
                      ),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: _theme.colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isExpanded)
              Expanded(
                child: ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: validUnvalid.length,
                  itemBuilder: (context, index) {
                    final currentItem = validUnvalid[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: Column(
                        children: [
                          ListTile(
                            // onLongPress: () {
                            // if (DateTime.now()
                            //         .difference(currentItem.date)
                            //         .inMinutes >=
                            //     30) {
                            //   ScaffoldMessenger.of(context)
                            //       .hideCurrentSnackBar();
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //       SnackBar(
                            //           duration: const Duration(seconds: 2),
                            //           content: Text(
                            //               'you can\'t delete it. it\'s too old'
                            //                   .tr)));
                            //   return;
                            // }
                            // showDialog(
                            //   context: context,
                            //   builder: (context) => AlertDialog(
                            //     title:
                            //         Text('do you want to delete this item?'.tr),
                            //     actions: [
                            //       TextButton(
                            //         onPressed: () => Navigator.pop(context),
                            //         child: Text('cancle'.tr),
                            //       ),
                            //       TextButton(
                            //         onPressed: () async {
                            //           try {
                            //             await firebaseData
                            //                 .deleteAWork(currentItem.id);
                            //           } catch (e) {
                            //             if (!context.mounted) return;
                            //             ScaffoldMessenger.of(context)
                            //                 .hideCurrentSnackBar();
                            //             ScaffoldMessenger.of(context)
                            //                 .showSnackBar(
                            //               SnackBar(
                            //                 content: Text(
                            //                     'could not delete it right now,please try again.'
                            //                         .tr),
                            //               ),
                            //             );
                            //           } finally {
                            //             if (context.mounted) {
                            //               Navigator.pop(context);
                            //             }
                            //           }
                            //         },
                            //         child: Text('ok'.tr),
                            //       ),
                            //     ],
                            //   ),
                            // );
                            // },
                            splashColor: Colors.transparent,
                            title: FittedBox(
                              child: Text(
                                  DateFormat.EEEE(TheDatabase.localCode)
                                      .add_yMd()
                                      .format(currentItem!.date),
                                  softWrap: false),
                            ),
                            trailing: FittedBox(
                              child: Column(
                                children: [
                                  Text(
                                    '${'work: '.tr}${_format.format(currentItem.quantity)} ${currentItem.type.name}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: _theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                  Text(
                                    'spent: '.tr +
                                        _format
                                            .format(currentItem.amountSpent) +
                                        'ryals'.tr,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: _theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                  Text(
                                    'amount: '.tr +
                                        _format.format((currentItem.quantity *
                                                currentItem.type.price) -
                                            currentItem.amountSpent) +
                                        'ryals'.tr,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: _theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            color: _theme.colorScheme.secondary,
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

//
//unvalid
class UnvalidContainer extends StatefulWidget {
  const UnvalidContainer({super.key});

  @override
  State<UnvalidContainer> createState() => _UnvalidContainerState();
}

class _UnvalidContainerState extends State<UnvalidContainer> {
  late final _workData = Provider.of<WorkData>(context);
  late final _validUnvalid = _workData.validAndUnvalidList[1].reversed.toList();
  final _theme = WorkData.currenTheme;
  late final _format = _workData.formatNumbers;

  var _isExpanded = false;

  void _onTap() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: _theme.disabledColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        // border: Border.all(width: 2, color: _theme.disabledColor),
      ),
      clipBehavior: Clip.hardEdge,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: _onTap,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Card(
                elevation: 0,
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'unvalid data'.tr,
                        style: _theme.textTheme.headlineSmall!.copyWith(
                            fontSize: 25, color: _theme.disabledColor),
                      ),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: _theme.disabledColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isExpanded)
              ListView.builder(
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: _validUnvalid.length,
                itemBuilder: (context, index) {
                  final currentItem = _validUnvalid[index];

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Column(
                      children: [
                        ListTile(
                          splashColor: Colors.transparent,
                          title: FittedBox(
                            child: Text(
                              DateFormat.EEEE(TheDatabase.localCode)
                                  .add_yMd()
                                  .format(currentItem!.date),
                              softWrap: false,
                              style: TextStyle(color: _theme.disabledColor),
                            ),
                          ),
                          trailing: FittedBox(
                            child: Column(
                              children: [
                                Text(
                                  '${'work: '.tr}${_format.format(currentItem.quantity)} ${currentItem.type.name}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: _theme.colorScheme.onPrimary,
                                    ),
                                ),
                                Text(
                                  'spent: '.tr +
                                      _format.format(currentItem.amountSpent) +
                                      'ryals'.tr,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: _theme.colorScheme.onPrimary,
                                    ),
                                ),
                                Text(
                                  'amount: '.tr +
                                      _format.format((currentItem.quantity *
                                              currentItem.type.price) -
                                          currentItem.amountSpent) +
                                      'ryals'.tr,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: _theme.colorScheme.onPrimary,
                                    ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          color: _theme.disabledColor,
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
