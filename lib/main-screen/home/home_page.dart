import 'package:flutter/material.dart';
import 'package:usage_track/main-screen/home/widgets/all_monthes_data.dart';
import 'package:usage_track/main-screen/home/widgets/first_month_data.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Stack(
          children: [
            FirstMonthContainer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AllMonthesData(),
              ],
            )
          ],
        )

        //  Stack(
        //   children: [

        //     Column(
        //       children: [
        //         Expanded( child: SizedBox(height: double.infinity)),
        //         Expanded( child: AllMonthesData()),
        //       ],
        //     ),
        //     Column(
        //       children: [
        // Expanded( child: FirstMonthContainer()),
        //         Expanded( child: SizedBox()),
        //       ],
        //     ),
        //   ],
        // ),

        );
  }
}
