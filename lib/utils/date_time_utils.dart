import 'package:flutter/material.dart';

List<String> getFilledDays(String days) {
  var filledDays = <String>[];

  var daysList = days.split(".");
  for (var day in daysList) {
    filledDays.add(fillDay(day));
  }

  return filledDays;
}

TimeOfDay getFromTime(String time) {
  return TimeOfDay(
      hour: int.parse(time.split("-")[0].split(":")[0]),
      minute: int.parse(time.split("-")[0].split(":")[1]));
}

TimeOfDay getToTime(String time) {
  return TimeOfDay(
      hour: int.parse(time.split("-")[1].split(":")[0]),
      minute: int.parse(time.split("-")[1].split(":")[1]));
}

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

String fillDay(String dayInitial) {
  switch (dayInitial) {
    case "M":
      return "Monday";
    case "T":
      return "Tuesday";
    case "W":
      return "Wednesday";
    case "Th":
      return "Thursday";
    case "F":
      return "Friday";
    case "S":
      return "Saturday";
    default:
      return "";
  }
}
