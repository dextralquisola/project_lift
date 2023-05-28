import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/user.dart';
import '../../../utils/date_time_utils.dart';

bool isAvailableAtCurrentDate(User tutor) {
  final daysAvail = getFilledDays(tutor.dateTimeAvailability.split('+')[0]);
  final fromTime = getFromTime(tutor.dateTimeAvailability.split('+')[1]);
  final toTime = getToTime(tutor.dateTimeAvailability.split('+')[1]);

  var now = TimeOfDay.now();
  if (daysAvail.contains(DateFormat('EEEE').format(DateTime.now()))) {
    if ((now.hour > fromTime.hour ||
            (now.hour == fromTime.hour && now.minute >= fromTime.minute)) &&
        (now.hour < toTime.hour ||
            (now.hour == toTime.hour && now.minute < toTime.minute))) {
      return true;
    }
  }

  return false;
}
