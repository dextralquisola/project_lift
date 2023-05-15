

List<bool> daysSelectedBuilder(List<String> days) {
  List<bool> daysSelected = [false, false, false, false, false, false, false];

  for (int i = 0; i < days.length; i++) {
    daysSelected[convertDayToIndex(days[i])] = true;
  }

  return daysSelected;
}

String selectedDaysBuilder(List<bool> sd) {
  String selectedDays = "";

  for (int i = 0; i < sd.length; i++) {
    if (sd[i]) {
      // M.T.W.Th.F.Sat.Sun.
      selectedDays += "${dateIndexConvertToDay(i)}.";
    }
  }

  return selectedDays.substring(0, selectedDays.length - 1);
}

String dateIndexConvertToDay(int index) {
  switch (index) {
    case 0:
      return "M";
    case 1:
      return "T";
    case 2:
      return "W";
    case 3:
      return "Th";
    case 4:
      return "F";
    case 5:
      return "Sat";
    default:
      return "";
  }
}

int convertDayToIndex(String day) {
  switch (day) {
    case "M":
      return 0;
    case "T":
      return 1;
    case "W":
      return 2;
    case "Th":
      return 3;
    case "F":
      return 4;
    case "Sat":
      return 5;
    default:
      return -1;
  }
}
