import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import './message.dart';
import './subject.dart';

class ToDo {
  final String id;
  final String title;
  final String description;
  final bool isDone;

  ToDo({
    required this.id,
    required this.title,
    required this.description,
    required this.isDone,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'title': title});
    result.addAll({'description': description});
    result.addAll({'isDone': isDone});

    return result;
  }

  ToDo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isDone,
  }) {
    return ToDo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
    );
  }

  factory ToDo.fromMap(Map<String, dynamic> map) {
    return ToDo(
      id: map['_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isDone: map['isDone'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory ToDo.fromJson(String source) => ToDo.fromMap(json.decode(source));
}

class StudyRoom {
  final String roomId;
  final String roomName;
  final String roomOwner;
  final String location;
  final String schedule;
  final List<Message> messages;
  final List<Map<String, dynamic>> participants;
  final Subject subject;
  final List<ToDo> todos;
  final int participantCount;
  final bool sessionEnded;

  StudyRoom({
    required this.roomId,
    required this.roomName,
    required this.messages,
    required this.participants,
    required this.roomOwner,
    required this.subject,
    required this.location,
    required this.schedule,
    required this.todos,
    required this.sessionEnded,
    this.participantCount = 0,
  });

  factory StudyRoom.fromMap(
    Map<String, dynamic> map, [
    bool isMapMessage = false,
    bool isParticipantPopulated = true,
  ]) {
    return StudyRoom(
      roomId: map['_id'] ?? '',
      todos: map['todoList'] != null
          ? List<ToDo>.from(
              map['todoList']?.map(
                (x) => ToDo.fromMap(x),
              ),
            )
          : [],
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
                  'userId': x['userId']['_id'] ?? '',
                  'firstName': (x['userId']['firstName']) ?? '',
                  'lastName': x['userId']['lastName'] ?? '',
                  'status': x['status'] ?? '',
                },
              ),
            )
          : List<Map<String, dynamic>>.from(
              map['participants']?.map(
                (x) => {
                  'userId': x['userId'] ?? '',
                  'status': x['status'] ?? '',
                },
              ),
            ),
      roomName: map['name'] ?? '',
      roomOwner: map['owner'] ?? '',
      location: map['location'] ?? '',
      schedule: map['schedule'] ?? '',
      sessionEnded: map['sessionEnded'] ?? false,
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
    String? location,
    String? schedule,
    bool? sessionEnded,
    List<ToDo>? todos,
  }) {
    return StudyRoom(
      roomId: roomId ?? this.roomId,
      messages: messages ?? this.messages,
      participants: participants ?? this.participants,
      roomName: roomName ?? this.roomName,
      roomOwner: roomOwner ?? this.roomOwner,
      subject: subject ?? this.subject,
      participantCount: participantCount ?? this.participantCount,
      location: location ?? this.location,
      schedule: schedule ?? this.schedule,
      todos: todos ?? this.todos,
      sessionEnded: sessionEnded ?? this.sessionEnded,
    );
  }

  void printRoom() {
    if (kDebugMode) {
      print("Room ID: $roomId");
      print("Room Name: $roomName");
      print("Room Owner: $roomOwner");
      print("Room Messages: $messages");
      print("Room Participants: ${participants.length}");
      print("location: $location");
      print("schedule: $schedule");
      print("sessionEnded: $sessionEnded");
    }
  }

  factory StudyRoom.fromJson(String source) =>
      StudyRoom.fromMap(json.decode(source));

  factory StudyRoom.empty() {
    return StudyRoom(
      roomId: '',
      messages: [],
      participants: [],
      todos: [],
      roomName: '',
      roomOwner: '',
      location: '',
      schedule: '',
      sessionEnded: false,
      subject: Subject.empty(),
      participantCount: 0,
    );
  }
}

class StudyRoomSchedule {
  final String scheduleString;

  StudyRoomSchedule({
    required this.scheduleString,
  });

  DateTime get scheduleDate => DateTime.parse(
        scheduleString.split('+')[0],
      );

  String get scheduleDateAsISOString => scheduleString.split('+')[0];

  TimeOfDay get fromTime => TimeOfDay(
        hour:
            int.parse(scheduleString.split('+')[1].split('.')[0].split(':')[0]),
        minute:
            int.parse(scheduleString.split('+')[1].split('.')[0].split(':')[1]),
      );
  TimeOfDay get toTime => TimeOfDay(
        hour:
            int.parse(scheduleString.split('+')[1].split('.')[1].split(':')[0]),
        minute:
            int.parse(scheduleString.split('+')[1].split('.')[1].split(':')[1]),
      );
}
