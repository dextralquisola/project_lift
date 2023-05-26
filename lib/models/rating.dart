import 'dart:convert';

import './subject.dart';

class Rating {
  final Subject subject;
  final List<SubjectRating> subjectRatings;

  Rating({
    required this.subject,
    required this.subjectRatings,
  });

  double getSubjectRating() {
    if (subjectRatings.isEmpty) return 0;

    final totalRating = subjectRatings.fold(
        0, (previousValue, element) => previousValue + element.rating);

    return totalRating / subjectRatings.length;
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'subject': subject.toMap()});
    result.addAll({'ratings': subjectRatings});

    return result;
  }

  factory Rating.fromMap(Map<String, dynamic> map, [bool isUserMapped = true]) {
    return Rating(
      subject: Subject.fromMap(map['subject']),
      subjectRatings: map['ratings'].isEmpty
          ? []
          : List<SubjectRating>.from(
              map['ratings']?.map(
                (x) => SubjectRating.fromMap(x, isUserMapped),
              ),
            ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Rating.fromJson(String source) => Rating.fromMap(json.decode(source));
}

class SubjectRating {
  final int rating;
  final String feedback;
  final String firstName;
  final String lastName;

  SubjectRating({
    required this.rating,
    required this.feedback,
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'rating': rating});
    result.addAll({'feedback': feedback});
    result.addAll({'firstName': firstName});
    result.addAll({'lastName': lastName});

    return result;
  }

  factory SubjectRating.fromMap(Map<String, dynamic> map,
      [bool isUserMapped = true]) {
    return SubjectRating(
      rating: map['value']?.toInt() ?? 0,
      feedback: map['feedback'] ?? '',
      firstName: isUserMapped
          ? map['tuteeId'] == null
              ? map['tutorId']['firstName'] ?? ''
              : map['tuteeId']['firstName'] ?? ''
          : '',
      lastName: isUserMapped
          ? map['tuteeId'] == null
              ? map['tutorId']['lastName'] ?? ''
              : map['tuteeId']['lastName'] ?? ''
          : '',
    );
  }

  String toJson() => json.encode(toMap());

  factory SubjectRating.fromJson(String source) =>
      SubjectRating.fromMap(json.decode(source));
}
