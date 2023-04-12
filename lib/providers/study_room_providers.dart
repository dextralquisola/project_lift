import 'package:flutter/material.dart';
import 'package:project_lift/models/study_room.dart';

class StudyRoomProvider with ChangeNotifier {
  List<StudyRoom> _studyRooms = [];

  List<StudyRoom> get studyRooms => _studyRooms;

  void addSingleStudyRoom(dynamic data) {
    _studyRooms.add(StudyRoom.fromMap(data));
    notifyListeners();
  }

  void addStudyRoomFromJson(dynamic data, bool isPopulatedParticipant) {
    List<dynamic> studyRooms = data['rooms'];

    var newStudyRooms = studyRooms
        .map((e) => StudyRoom.fromMap(e, false, isPopulatedParticipant))
        .toList();
    _studyRooms = [..._studyRooms, ...newStudyRooms];

    notifyListeners();
  }

  void clearStudyRooms() {
    _studyRooms = [];
    notifyListeners();
  }
}
