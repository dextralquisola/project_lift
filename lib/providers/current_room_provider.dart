import 'package:flutter/material.dart';
import 'package:project_lift/models/study_room.dart';

import '../models/message.dart';

class CurrentStudyRoomProvider with ChangeNotifier {
  StudyRoom _studyRoom = StudyRoom.empty();

  StudyRoom get studyRoom => _studyRoom;
  List<Message> get messages => _studyRoom.messages;

  bool get isEmpty => _studyRoom.roomId.isEmpty;

  void addMessage(Message message) {
    _studyRoom.messages.add(message);
    notifyListeners();
  }

  void setStudyRoomFromJson(dynamic data) {
    var studyRoom = StudyRoom.fromMap(data, true);
    _studyRoom = studyRoom;
    notifyListeners();
  }

  void leaveStudyRoom() {
    _studyRoom = StudyRoom.empty();
    notifyListeners();
  }
}
