import 'package:project_lift/models/user.dart';

class StudyRoom {
  final String roomId;
  final List<User> participants;
  final String roomDescription;
  final String roomOwner;

  StudyRoom({
    required this.roomId,
    required this.roomDescription,
    required this.participants,
    required this.roomOwner,
  });
}
