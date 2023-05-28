import 'dart:convert';

class Rating {
  final String id;
  final String feedback;
  final int rating;
  final String firstName;
  final String lastName;

  Rating({
    required this.id,
    required this.feedback,
    required this.rating,
    required this.firstName,
    required this.lastName,
  });

  factory Rating.fromMap(Map<String, dynamic> map, {bool isUserMapped = true}) {
    return Rating(
      id: map['id'] ?? '',
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

  factory Rating.fromJson(String source) => Rating.fromMap(json.decode(source));
}

class TuteeRating extends Rating {
  TuteeRating({
    required super.id,
    required super.feedback,
    required super.rating,
    required super.firstName,
    required super.lastName,
  });

  factory TuteeRating.fromMap(Map<String, dynamic> map,
      {bool isUserMapped = true}) {
    return TuteeRating(
      id: map['id'] ?? '',
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
}

class TutorRating {
  final String subjectCode;
  final String description;
  final List<SubTopicRating> subTopicRatings;
  final double averageSubjectsRating;

  TutorRating({
    required this.subjectCode,
    required this.description,
    required this.subTopicRatings,
    required this.averageSubjectsRating,
  });

  factory TutorRating.fromMap(Map<String, dynamic> map) {
    return TutorRating(
      subjectCode: map['subject']['subjectCode'] ?? '',
      description: map['subject']['description'] ?? '',
      subTopicRatings: List<SubTopicRating>.from(
          map['subject']['subtopics']?.map((x) => SubTopicRating.fromMap(x))),
      averageSubjectsRating:
          map['subject']['averageSubjectsRating']?.toDouble() ?? 0.0,
    );
  }

  factory TutorRating.fromJson(String source) =>
      TutorRating.fromMap(json.decode(source));
}

class SubTopicRating {
  final String name;
  final String description;
  final List<Rating> ratings;
  final double averageSubtopicsRating;

  SubTopicRating({
    required this.name,
    required this.description,
    required this.ratings,
    required this.averageSubtopicsRating,
  });

  factory SubTopicRating.fromMap(Map<String, dynamic> map) {
    return SubTopicRating(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      ratings: List<Rating>.from(
          map['subtopicsRatings']?.map((x) => Rating.fromMap(x))),
      averageSubtopicsRating: map['averageSubtopicsRating']?.toDouble() ?? 0.0,
    );
  }

  factory SubTopicRating.fromJson(String source) =>
      SubTopicRating.fromMap(json.decode(source));
}
