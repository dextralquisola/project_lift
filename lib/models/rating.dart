import 'dart:convert';

class Rating {
  final int rating;
  final String feedback;

  Rating({
    required this.rating,
    required this.feedback,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'rating': rating});
    result.addAll({'feedback': feedback});

    return result;
  }

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      rating: map['value']?.toInt() ?? 0,
      feedback: map['feedback'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Rating.fromJson(String source) => Rating.fromMap(json.decode(source));
}
