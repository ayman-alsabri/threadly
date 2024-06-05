import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:usage_track/providers/work_data.dart';

class BreifContainer extends StatelessWidget {
  final ThemeData theme;
  final NumberFormat format;
  final List<DayWork?> validData;
  const BreifContainer({
    super.key,
    required this.theme,
    required this.format,
    required this.validData,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final total = totalAmount();
    final spent = spentAmount();
    return SizedBox(
      height: size.height * 2 / 12,
      child: Card(margin: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 6,
                child: FittedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'total amount:'.tr + format.format(total) + 'ryals'.tr,
                        style: theme.textTheme.headlineMedium,
                        softWrap: false,
                      ),
                      const SizedBox( height: 10,),
                      Text(
                        'spent amount:'.tr + format.format(spent) + 'ryals'.tr,
                        style: theme.textTheme.headlineMedium,
                        softWrap: false,
                      ),                      const SizedBox( height: 10,),

                      Text(
                        'net amount:'.tr +
                        format.format(total - spent) +
                        'ryals'.tr,
                        style: theme.textTheme.headlineMedium,
                        softWrap: false,
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 3,
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: FittedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('avrage income'.tr,
                            style:
                                TextStyle(color: theme.colorScheme.secondary)),
                        Text(
                            format.format(total == 0
                                    ? 0
                                    : (((total - spent) /
                                                (validData.length * 100))
                                            .round() *
                                        100)) +
                                'ryals'.tr,
                            style:
                                TextStyle(color: theme.colorScheme.secondary)),
                        Text('avrage outcome'.tr,
                            style:
                                TextStyle(color: theme.colorScheme.secondary)),
                        Text(
                            format.format(total == 0
                                    ? 0
                                    : (((spent) / (validData.length * 100))
                                            .round() *
                                        100)) +
                                'ryals'.tr,
                            style:
                                TextStyle(color: theme.colorScheme.secondary)),
                        Text('avrage work'.tr,
                            style:
                                TextStyle(color: theme.colorScheme.secondary)),
                        Text(format.format(totalWork()),
                            style:
                                TextStyle(color: theme.colorScheme.secondary)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int totalAmount() {
    int total = 0;
    for (var element in validData) {
      total += element!.quantity * element.type.price;
    }
    return total;
  }

  int spentAmount() {
    int spent = 0;
    for (var element in validData) {
      spent += element!.amountSpent;
    }
    return spent;
  }

  int totalWork() {
    int work = 0;
    for (var element in validData) {
      work += element!.quantity;
    }
    return work;
  }
}
