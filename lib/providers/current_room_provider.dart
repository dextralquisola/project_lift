import 'package:flutter/material.dart';
import 'package:project_lift/models/study_room.dart';

import '../models/message.dart';

class CurrentStudyRoomProvider with ChangeNotifier {
  StudyRoom _studyRoom = StudyRoom.empty();

  StudyRoom get studyRoom => _studyRoom;
  List<Message> get messages => _studyRoom.messages.reversed.toList();
  List<Map<String, dynamic>> get pendingParticipants => _studyRoom.participants
      .where((element) => element['status'] == 'pending')
      .toList();

  bool get isEmpty => _studyRoom.roomId.isEmpty;

  void setMessagesFromJson(dynamic data) {
    var messages = List<Message>.from(data.map((x) => Message.fromMap(x)));
    _studyRoom = _studyRoom.copyWith(messages: messages);
    notifyListeners();
  }

  void setStudyRoomFromJson(dynamic data) {
    var studyRoom = StudyRoom.fromMap(data);
    _studyRoom = studyRoom;
    notifyListeners();
  }

  void leaveStudyRoom() {
    _studyRoom = StudyRoom.empty();
    notifyListeners();
  }

  void addMessage(dynamic data) {
    var message = Message.fromMap(data, true);
    _studyRoom =
        _studyRoom.copyWith(messages: [..._studyRoom.messages, message]);
    notifyListeners();
  }
}
