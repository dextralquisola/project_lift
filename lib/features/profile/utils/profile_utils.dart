import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/current_room_provider.dart';
import '../../../providers/study_room_providers.dart';
import '../../../providers/tutors_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/user_requests_provider.dart';
import '../../../utils/utils.dart';
import '../../auth/service/auth_service.dart';

Future<void> logout(BuildContext context) async {
  try {
    final authService = AuthService();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final tutorsProvider = Provider.of<TutorProvider>(context, listen: false);
    final userRequestsProvider =
        Provider.of<UserRequestsProvider>(context, listen: false);
    final studyPoolProvider =
        Provider.of<StudyRoomProvider>(context, listen: false);
    final currentStudyRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context, listen: false);
    var isLogoutSuccess = await authService.logout(context);

    if (isLogoutSuccess) {
      userProvider.clearUserData();
      tutorsProvider.clearTutors();
      studyPoolProvider.clearStudyRooms();
      currentStudyRoomProvider.leaveStudyRoom();
      userRequestsProvider.clearRequests();
      await userProvider.logout();
    } else {
      showSnackBar(context, "Something went wrong");
    }
  } catch (e) {
    printLog(e.toString(), "Failed to logout");
  }
}

List<bool> daysSelectedBuilder(List<String> days) {
  List<bool> daysSelected = List.generate(6, (index) => false);

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

  return selectedDays.isEmpty
      ? ""
      : selectedDays.substring(0, selectedDays.length - 1);
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
