import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:usage_track/main-screen/history/widgets/breif_container.dart';
import 'package:usage_track/main-screen/history/widgets/valid_and_unvalid_scrollview.dart';
import 'package:usage_track/providers/database.dart';
import 'package:usage_track/providers/work_data.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final workdata = Provider.of<WorkData>(context);
    final validAndUnvalid = workdata.validAndUnvalidList;
    final lastPaidAll =
        workdata.paidList.isEmpty ? null : workdata.paidList.last;
    final theme = WorkData.currenTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: FittedBox(
            child: Text(
              lastPaidAll == null
                  ? ('no full payment yet'.tr)
                  : ('${'last full payment was on '.tr}${DateFormat.yMd(TheDatabase.localCode).format(lastPaidAll.date)}'),
              style: theme.textTheme.headlineSmall!.copyWith(fontSize: 25),
            ),
          ),
        ),
        const SizedBox(height: 10),
        BreifContainer(
          theme: theme,
          format: workdata.formatNumbers,
          validData: validAndUnvalid[0],
        ),
        const SizedBox(height: 10),
        const ValidAndUnvalidScroll(),
      ],
    );
  }
}
