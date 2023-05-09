import 'dart:convert';

import 'package:project_lift/models/subject.dart';

class Request {
  final String requestId;
  final Subject subject;
  final String tutorId;
  final String tuteeId;
  final String tuteeFirstName;
  final String tuteeLastName;
  final String roomName;
  final String status;
  final String location;
  final String schedule;

  Request({
    required this.requestId,
    required this.subject,
    required this.tutorId,
    required this.tuteeId,
    required this.tuteeFirstName,
    required this.tuteeLastName,
    required this.roomName,
    required this.status,
    required this.location,
    required this.schedule,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'requestId': requestId});
    result.addAll({'subject': subject.toMap()});
    result.addAll({'tuteeId': tuteeId});
    result.addAll({'tuteeFirstName': tuteeFirstName});
    result.addAll({'tuteeLastName': tuteeLastName});
    result.addAll({'roomName': roomName});
    result.addAll({'status': status});
    result.addAll({'location': location});
    result.addAll({'schedule': schedule});

    return result;
  }

  factory Request.fromMap(
    Map<String, dynamic> map,
  ) {
    return Request(
      requestId: map['_id'] ?? '',
      subject: Subject.fromMap(map['subject']),
      tutorId: map['tutorId']['_id'] ?? '',
      tuteeId: map['studentId']['_id'] ?? '',
      tuteeFirstName: map['studentId']['firstName'] ?? '',
      tuteeLastName: map['studentId']['lastName'] ?? '',
      roomName: map['name'] ?? '',
      status: map['status'] ?? '',
      location: map['location'] ?? '',
      schedule: map['schedule'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Request.fromJson(String source) =>
      Request.fromMap(json.decode(source));
}
