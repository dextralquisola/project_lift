import 'package:flutter/material.dart';

String dateTimeAvailabilityFormatter(
  BuildContext context,
  String dateTimeAvailability,
) {
  var days = "";

  final timeDayAvailableList = dateTimeAvailability.split("+");

  final daysAvailable = timeDayAvailableList[0].split(".");
  final timeAvailable = timeDayAvailableList[1];

  final timeAvailableList = timeAvailable.split("-");
  final ft = timeAvailableList[0];
  final tt = timeAvailableList[1];

  if (daysAvailable.length == 6) {
    days = "M - S";
  } else {
    days = timeDayAvailableList[0].replaceAll(".", ", ");
  }

  var fromTime = TimeOfDay(
      hour: int.parse(ft.split(":")[0]), minute: int.parse(ft.split(":")[1]));

  var toTime = TimeOfDay(
      hour: int.parse(tt.split(":")[0]), minute: int.parse(tt.split(":")[1]));

  return "$days ${fromTime.format(context)} - ${toTime.format(context)}";
}
