import 'dart:convert';

class StudyRoom {
  final String roomId;
  final String roomName;
  final String roomOwner;
  final List<Map<String, dynamic>> participants;

  StudyRoom({
    required this.roomId,
    required this.roomName,
    required this.participants,
    required this.roomOwner,
  });

  factory StudyRoom.fromMap(Map<String, dynamic> map) {
    return StudyRoom(
      roomId: map['_id'] ?? '',
      participants: List<Map<String, dynamic>>.from(
        map['participants']?.map(
          (x) => {
            'userId': x['userId'],
            'status': x['status'],
          },
        ),
      ),
      roomName: map['name'] ?? '',
      roomOwner: map['owner'] ?? '',
    );
  }

  factory StudyRoom.fromJson(String source) =>
      StudyRoom.fromMap(json.decode(source));
}
