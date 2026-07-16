import 'package:flutter/material.dart';
import 'package:my_app/models/activity_model.dart';

class KCalSummary extends StatelessWidget {
  const KCalSummary({
    super.key,
    required this.activityModelStore,
  });

  final List<ActivityModel> activityModelStore;

  int _sumKCal() {
    int sum = 0;

    for (ActivityModel item in activityModelStore) {
      sum += item.kcalExpense;
    }

    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(15),
        color: Colors.black.withValues(alpha: 0.1),
      ), // BoxDecoration
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("เผาผลาญไปแล้ว"),
          Text(
            "${_sumKCal()}",
            style: TextStyle(fontSize: 24),
          ),
        ],
      ), // Column
    ); // Container
  }
}