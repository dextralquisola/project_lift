import 'package:flutter/material.dart';
import 'package:project_lift/models/study_room.dart';

import '../models/message.dart';

class CurrentStudyRoomProvider with ChangeNotifier {
  StudyRoom _studyRoom = StudyRoom.empty();

  int _currentMessagePage = 1;
  int _totalMessagePage = 1;

  int get currentMessagePage => _currentMessagePage;

  StudyRoom get studyRoom => _studyRoom;
  List<Message> get messages => _studyRoom.messages;
  List<Map<String, dynamic>> get pendingParticipants => _studyRoom.participants
      .where((element) => element['status'] == 'pending')
      .toList();

  bool get isEmpty => _studyRoom.roomId.isEmpty;

  void setMessagesFromJson(dynamic data) {
    _totalMessagePage = data['totalPages'];

    if (_currentMessagePage > _totalMessagePage) return;

    List<dynamic> messages = data['messages'];
    var newMessages = messages.map((e) => Message.fromMap(e)).toList();

    var uniqueMessages = newMessages;

    if (messages.length == 10) {
      _currentMessagePage++;
    } else if (messages.length < 10) {
      uniqueMessages = removeDuplicatedMessages(newMessages);
    }

    _studyRoom = _studyRoom
        .copyWith(messages: [..._studyRoom.messages, ...uniqueMessages]);
    notifyListeners();
  }

  List<Message> removeDuplicatedMessages(List<Message> messages) {
    var uniqueMessages = <Message>[];
    for (var message in messages) {
      if (_studyRoom.messages.indexWhere(
              (element) => element.messageId == message.messageId) ==
          -1) {
        uniqueMessages.add(message);
      }
    }
    return uniqueMessages;
  }

  void setStudyRoomFromJson(dynamic data) {
    var studyRoom = StudyRoom.fromMap(data);
    _studyRoom = studyRoom;
    notifyListeners();
  }

  void leaveStudyRoom() {
    _totalMessagePage = 1;
    _currentMessagePage = 1;
    _studyRoom = StudyRoom.empty();
    notifyListeners();
  }

  void addMessage(dynamic data) {
    var message = Message.fromMap(data, true);
    _studyRoom =
        _studyRoom.copyWith(messages: [message, ..._studyRoom.messages]);
    notifyListeners();
  }

  void addParticipant(dynamic data) {
    var participant = data;
    _studyRoom = _studyRoom
        .copyWith(participants: [..._studyRoom.participants, participant]);
    notifyListeners();
  }

  void acceptParticipant(String userId) {
    _studyRoom = _studyRoom.copyWith(
      participants: _studyRoom.participants
          .map(
            (e) =>
                e['userId'] == userId ? {...e, 'status': 'accepted'} : {...e},
          )
          .toList(),
    );
    notifyListeners();
  }

  void removeParticipantById(String userId) {
    _studyRoom = _studyRoom.copyWith(
      participants: _studyRoom.participants
          .where((element) => element['userId'] != userId)
          .toList(),
    );
    notifyListeners();
  }

  void clearRoom() {
    _studyRoom = StudyRoom.empty();
    notifyListeners();
  }
}
