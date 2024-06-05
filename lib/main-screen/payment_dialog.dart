import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:usage_track/main-screen/providers/firebase_data.dart';
import 'package:usage_track/providers/work_data.dart';

class PaymentDialog extends StatefulWidget {
  const PaymentDialog({super.key});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  bool _isloading = false;
  @override
  Widget build(BuildContext context) {
    final workdata = Provider.of<WorkData>(context, listen: false);
    final firebaseData = Provider.of<FirebaseData>(context, listen: false);
    final format = workdata.formatNumbers;
    final amount = workdata.paidNotification!.amount;

    return AlertDialog(
      title: Text('payment request'.tr),
      content: FittedBox(
        child: Text('paid amount: '.tr + format.format(amount)),
      ),
      actions: [
        ElevatedButton(
          onPressed: _isloading
              ? null
              : () async {
                  setState(() {
                    _isloading = true;
                  });
                  try {
                    await firebaseData.addPaidAll(amount, false);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('please connect to the internet'.tr)));
                  }
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
          child: Text('cancle'.tr),
        ),
        const SizedBox(
          width: 10,
        ),
        ElevatedButton(
          onPressed: _isloading
              ? null
              : () async {
                  setState(() {
                    _isloading = true;
                  });
                  try {
                    await firebaseData.addPaidAll(amount, true);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('please connect to the internet'.tr)));
                  }
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
          child: Text('ok'.tr),
        ),
      ],
    );
  }
}
