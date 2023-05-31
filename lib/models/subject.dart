import 'dart:convert';

class Subject {
  final String subjectCode;
  final String description;
  final List<SubTopic> subTopics;

  Subject({
    required this.subjectCode,
    required this.description,
    required this.subTopics,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'subjectCode': subjectCode});
    result.addAll({'description': description});
    result.addAll({
      'subtopics': subTopicsToListMap(),
    });

    return result;
  }

  List<Map<String, dynamic>> subTopicsToListMap() {
    final result = <Map<String, dynamic>>[];

    for (var subTopic in subTopics) {
      result.add(subTopic.toMap());
    }

    if(subTopics.isEmpty) {
      result.add(SubTopic.empty().toMap());
    }

    return result;
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      subjectCode: map['subjectCode'] ?? '',
      description: map['description'] ?? '',
      subTopics: map['subtopics'].isEmpty
          ? []
          : List<SubTopic>.from(
              map['subtopics']?.map(
                (x) => SubTopic.fromMap(x),
              ),
            ),
    );
  }

  factory Subject.empty() {
    return Subject(
      subjectCode: '',
      description: '',
      subTopics: [],
    );
  }

  String toJson() => json.encode(toMap());

  factory Subject.fromJson(String source) =>
      Subject.fromMap(json.decode(source));
}

class SubTopic {
  final String topic;
  final String description;

  SubTopic({
    required this.topic,
    required this.description,
  });

  SubTopic copyWith({
    String? topic,
    String? description,
  }) {
    return SubTopic(
      topic: topic ?? this.topic,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': topic});
    result.addAll({'description': description});

    return result;
  }

  factory SubTopic.fromMap(Map<String, dynamic> map) {
    return SubTopic(
      topic: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }

  factory SubTopic.empty() {
    return SubTopic(
      topic: '',
      description: '',
    );
  }

  void printSubTopic() {
    print('SubTopic:');
    print('topic: $topic');
    print('description: $description');
  }

  String toJson() => json.encode(toMap());

  factory SubTopic.fromJson(String source) =>
      SubTopic.fromMap(json.decode(source));
}
