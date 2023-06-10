import 'dart:convert';

import './rating.dart';
import './subject.dart';

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
  final List<TuteeRating> ratingsAsTutee;

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
    required this.ratingsAsTutee,
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

  factory Request.fromMap(Map<String, dynamic> map,
      [bool isMyRequest = false]) {
    return Request(
      requestId: map['_id'] ?? '',
      subject: Subject.fromMap(map['subject']),
      tutorId: map['tutorId'] ?? map['tutorId']['_id'] ?? '',
      tuteeId: map['studentId'] ?? map['studentId']['_id'] ?? '',
      tuteeFirstName: map['studentId'] ?? map['studentId']['firstName'] ?? '',
      tuteeLastName: map['studentId'] ?? map['studentId']['lastName'] ?? '',
      roomName: map['name'] ?? '',
      status: map['status'] ?? '',
      location: map['location'] ?? '',
      schedule: map['schedule'] ?? '',
      ratingsAsTutee: isMyRequest
          ? []
          : List<TuteeRating>.from(
              map['studentId']['ratingsAsTutee']?.map(
                (x) => TuteeRating.fromMap(x, isUserMapped: false),
              ),
            ),
    );
  }

  List<TuteeRating> get getRatingsAsTutee => ratingsAsTutee;

  double getRating() {
    double totalRating = 0;

    for (var rating in ratingsAsTutee) {
      totalRating += rating.rating;
    }

    return totalRating / (ratingsAsTutee.isEmpty ? 1 : ratingsAsTutee.length);
  }

  String parsedRating() {
    var rating = getRating();

    if (rating == 0) return '0';

    int wholeNumber = rating.toInt();
    double decimalValue = rating - wholeNumber;

    if (decimalValue > 0) {
      return rating.toStringAsFixed(1);
    }

    return getRating().toStringAsFixed(0);
  }

  String toJson() => json.encode(toMap());

  factory Request.fromJson(String source) =>
      Request.fromMap(json.decode(source));
}
