import 'dart:convert';

class Rating {
  final int rating;
  final String feedback;
  final String firstName;
  final String lastName;

  Rating({
    required this.rating,
    required this.feedback,
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'rating': rating});
    result.addAll({'feedback': feedback});

    return result;
  }

  factory Rating.fromMap(Map<String, dynamic> map, [bool isUserMapped = true]) {
    return Rating(
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

  factory Rating.fromJson(String source) => Rating.fromMap(json.decode(source));
}
