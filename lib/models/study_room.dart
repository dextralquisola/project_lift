import 'dart:convert';

import 'package:project_lift/models/message.dart';
import 'package:project_lift/models/subject.dart';

class StudyRoom {
  final String roomId;
  final String roomName;
  final String roomOwner;
  final List<Message> messages;
  final List<Map<String, dynamic>> participants;
  final Subject subject;
  final int participantCount;

  StudyRoom({
    required this.roomId,
    required this.roomName,
    required this.messages,
    required this.participants,
    required this.roomOwner,
    required this.subject,
    this.participantCount = 0,
  });

  factory StudyRoom.fromMap(Map<String, dynamic> map,
      [bool isMapMessage = false, bool isParticipantPopulated = true]) {
    return StudyRoom(
      roomId: map['_id'] ?? '',
      messages: isMapMessage
          ? List<Message>.from(
              map['messages']?.map(
                (x) => Message.fromMap(x),
              ),
            )
          : [],
      participants: isParticipantPopulated
          ? List<Map<String, dynamic>>.from(
              map['participants']?.map(
                (x) => {
                  'userId': x['userId']['_id'],
                  'firstName': x['userId']['firstName'],
                  'lastName': x['userId']['lastName'],
                  'status': x['status'],
                },
              ),
            )
          : [],
      roomName: map['name'] ?? '',
      roomOwner: map['owner'] ?? '',
      subject: Subject.fromMap(map['subject']),
      participantCount: map['participantCount'] ?? 0,
    );
  }

  StudyRoom copyWith({
    String? roomId,
    String? roomName,
    String? roomOwner,
    List<Message>? messages,
    List<Map<String, dynamic>>? participants,
    Subject? subject,
    int? participantCount,
  }) {
    return StudyRoom(
      roomId: roomId ?? this.roomId,
      messages: messages ?? this.messages,
      participants: participants ?? this.participants,
      roomName: roomName ?? this.roomName,
      roomOwner: roomOwner ?? this.roomOwner,
      subject: subject ?? this.subject,
      participantCount: participantCount ?? this.participantCount,
    );
  }

  void printRoom() {
    print("Room ID: $roomId");
    print("Room Name: $roomName");
    print("Room Owner: $roomOwner");
    print("Room Messages: $messages");
    print("Room Participants: $participants");
    print("participantCount: $participantCount");
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
      subject: Subject.empty(),
      participantCount: 0,
    );
  }
}
