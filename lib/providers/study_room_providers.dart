import 'package:flutter/material.dart';
import 'package:project_lift/models/study_room.dart';

class StudyRoomProvider with ChangeNotifier{
  List<StudyRoom> _studyRooms = [];

  List<StudyRoom> get studyRooms => _studyRooms;

  void addStudyRoomFromJson(dynamic data) {
    // _studyRooms.add(studyRoom);
    notifyListeners();
  }
}