import 'dart:convert';

import 'package:project_lift/models/message.dart';

class StudyRoom {
  final String roomId;
  final String roomName;
  final String roomOwner;
  final List<Message> messages;
  final List<Map<String, dynamic>> participants;

  StudyRoom({
    required this.roomId,
    required this.roomName,
    required this.messages,
    required this.participants,
    required this.roomOwner,
  });

  factory StudyRoom.fromMap(Map<String, dynamic> map,
      [bool isMapMessage = false]) {
    return StudyRoom(
      roomId: map['_id'] ?? '',
      messages: isMapMessage && map['messages'] != []
          ? List<Message>.from(
              map['messages']?.map(
                (x) => Message.fromMap(x),
              ),
            )
          : [],
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

  StudyRoom copyWith({
    String? roomId,
    String? roomName,
    String? roomOwner,
    List<Message>? messages,
    List<Map<String, dynamic>>? participants,
  }) {
    return StudyRoom(
      roomId: roomId ?? this.roomId,
      messages: messages ?? this.messages,
      participants: participants ?? this.participants,
      roomName: roomName ?? this.roomName,
      roomOwner: roomOwner ?? this.roomOwner,
    );
  }

  void printRoom() {
    print("Room ID: $roomId");
    print("Room Name: $roomName");
    print("Room Owner: $roomOwner");
    print("Room Messages: $messages");
    print("Room Participants: $participants");
  }

  factory StudyRoom.fromJson(String source) =>
      StudyRoom.fromMap(json.decode(source));

  factory StudyRoom.empty() {
    return StudyRoom(
      roomId: '',
      messages: [],
      participants: [],
      roomName: '',
      roomOwner: '',
    );
  }
}
