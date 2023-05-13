import 'dart:convert';

class TutorApplication {
  final String id;
  final String grades;
  final String briefIntro;
  final String teachingExperience;
  final String status;

  TutorApplication({
    required this.id,
    required this.grades,
    required this.briefIntro,
    required this.teachingExperience,
    required this.status,
  });

  TutorApplication copyFrom({
    String? id,
    String? grades,
    String? briefIntro,
    String? teachingExperience,
    String? status,
  }) {
    return TutorApplication(
      id: id ?? this.id,
      grades: grades ?? this.grades,
      briefIntro: briefIntro ?? this.briefIntro,
      teachingExperience: teachingExperience ?? this.teachingExperience,
      status: status ?? this.status,
    );
  }

  factory TutorApplication.fromMap(Map<String, dynamic> map) {
    return TutorApplication(
      id: map['_id'] ?? '',
      grades: map['grades'] ?? '',
      briefIntro: map['briefIntro'] ?? '',
      teachingExperience: map['teachingExperience'] ?? '',
      status: map['status'] ?? '',
    );
  }

  factory TutorApplication.empty() {
    return TutorApplication(
      id: '',
      grades: '',
      briefIntro: '',
      teachingExperience: '',
      status: '',
    );
  }

  factory TutorApplication.fromJson(String source) =>
      TutorApplication.fromMap(json.decode(source));
}
