import 'package:intl/intl.dart';

class ActivityModel {
  int activityId = 0;
  int exerciseId = 0;
  String exerciseName = "";
  int kcalExpense = 0;
  String activityDate = "";

  ActivityModel({
    required this.activityId,
    required this.exerciseId,
    required this.exerciseName,
    required this.activityDate,
    required this.kcalExpense,
  });

  DateTime getActivityDateTime() {
    DateFormat inputFormat = DateFormat('dd-MM-yyyy HH:mm:ss');
    DateTime dateTime = inputFormat.parse(activityDate);
    return dateTime;
  }

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      activityId: json['act_id'] as int,
      exerciseId: json['ex_id'] as int,
      exerciseName: json['ex_name'] as String,
      activityDate: json['act_date'] as String,
      kcalExpense: json['kcal_expense'] as int,
    );
  }
}

class ActivityResponse {
  bool isError = false;
  List<ActivityModel> data = [];
  String errorMessage = "";

  ActivityResponse({
    required this.isError,
    required this.data,
    required this.errorMessage,
  });

  factory ActivityResponse.fromJson(Map<String, dynamic> json) {
    return ActivityResponse(
      isError: json['isError'],
      // ดึงข้อมูลจาก Key 'data' มาแปลงเป็น List ของคลาส ActivityModel
      data: (json['data'] as List)
          .map((item) => ActivityModel.fromJson(item))
          .toList(),
      errorMessage: json['errorMessage'],
    );
  } // ActivityResponse
}