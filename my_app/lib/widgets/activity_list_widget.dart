import 'package:flutter/material.dart';
import 'package:my_app/models/activity_model.dart';

class ActivityListWidget extends StatelessWidget {
  const ActivityListWidget({super.key, required this.activityModelStore});
  final List<ActivityModel> activityModelStore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      height: 400,
      child: ListView.builder(
        itemCount: activityModelStore.length,
        itemBuilder: (context, index) {
          ActivityModel item = activityModelStore[index];

          return ListTile(title: Text(item.activityDate));
        },
      ), // ListView.builder
    ); // Container
  }
}