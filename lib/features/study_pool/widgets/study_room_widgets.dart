import 'package:flutter/material.dart';

import '../../../models/study_room.dart';
import '../../../models/user.dart';
import '../../../widgets/app_text.dart';

showAlertDialog({
  required BuildContext context,
  required User user,
  required StudyRoom studyRoom,
  required Function onLeave,
}) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: const AppText(
      text: "Cancel",
    ),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = TextButton(
    child: const AppText(text: "Leave", textColor: Colors.red),
    onPressed: () async {
      await onLeave();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: const AppText(
      text: "Warning!",
      textColor: Colors.red,
      textSize: 20,
      fontWeight: FontWeight.w600,
    ),
    content: AppText(
      text: user.userId == studyRoom.roomOwner
          ? "Are you sure you want to leave this study room? The room will be deleted and the tutees will be notified and kicked to the room. "
          : "Are you sure you want to leave this study room?",
    ),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showEndSessionDialog({
  required BuildContext context,
  required User user,
  required StudyRoom studyRoom,
  required Function onEndSession,
}) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: const AppText(
      text: "Cancel",
    ),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = TextButton(
    child: const AppText(text: "End session", textColor: Colors.red),
    onPressed: () async {
      await onEndSession();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: const AppText(
      text: "Warning!",
      textColor: Colors.red,
      textSize: 20,
      fontWeight: FontWeight.w600,
    ),
    content:
        const AppText(text: "Are you sure you want to end this study session?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
