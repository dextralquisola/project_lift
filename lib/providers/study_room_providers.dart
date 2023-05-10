import 'package:flutter/material.dart';
import 'package:project_lift/models/study_room.dart';

class StudyRoomProvider with ChangeNotifier {
  List<StudyRoom> _studyRooms = [];
  List<String> _pendingRooms = [];

  int _currentPage = 1;
  int _totalPages = 1;

  List<StudyRoom> get studyRooms => _studyRooms;
  int get currentPage => _currentPage;

  void clearPendingRooms() {
    _pendingRooms = [];
    notifyListeners();
  }

  bool isRoomPending(String roomId) {
    return _pendingRooms.contains(roomId);
  }

  void addPendingRoom(String roomId) {
    _pendingRooms.add(roomId);
    notifyListeners();
  }

  void addSingleStudyRoom(dynamic data) {
    if (_studyRooms.length % 10 == 0) _currentPage++;
    _studyRooms.add(StudyRoom.fromMap(data));
    notifyListeners();
  }

  void addStudyRoomFromJson(dynamic data, bool isPopulatedParticipant) {
    // if (_currentPage > _totalPages) {
    //   return;
    // }
    _totalPages = data['totalPages'];

    List<dynamic> studyRooms = data['rooms'];

    if (studyRooms.length == 10) _currentPage++;

    var newStudyRooms = studyRooms
        .map((e) => StudyRoom.fromMap(e, false, isPopulatedParticipant))
        .toList();
    var uniqueStudyRooms = newStudyRooms;

    if (studyRooms.length < 10) {
      uniqueStudyRooms = removeDuplicates(newStudyRooms);
    }
    _studyRooms = [..._studyRooms, ...uniqueStudyRooms];

    notifyListeners();
  }

  void clearStudyRooms() {
    _currentPage = 1;
    _totalPages = 1;
    _studyRooms = [];
    notifyListeners();
  }

  List<StudyRoom> removeDuplicates(List<StudyRoom> list) {
    List<StudyRoom> newList = [];
    for (StudyRoom studyRoom in list) {
      if (_studyRooms.indexWhere((e) => e.roomId == studyRoom.roomId) == -1) {
        newList.add(studyRoom);
      }
    }
    return newList;
  }

  void removeStudyRoomById(String roomId) {
    _studyRooms.removeWhere((element) => element.roomId == roomId);
    notifyListeners();
  }
}
