import 'dart:convert';

import 'package:project_lift/models/rating.dart';

import './subject.dart';

class User {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final List<Subject> subjects;
  final String token;
  final String firebaseToken;
  final String deviceToken;
  final List<Rating> ratingAsTutor;
  final List<Rating> ratingAsTutee;
  final bool isEmailVerified;
  final bool hasRoom;
  final bool isAvailable;
  final String avatar;
  final String dateTimeAvailability;

  User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.token,
    required this.subjects,
    required this.ratingAsTutor,
    required this.ratingAsTutee,
    required this.isEmailVerified,
    required this.avatar,
    required this.dateTimeAvailability,
    required this.isAvailable,
    this.hasRoom = false,
    this.firebaseToken = '',
    this.deviceToken = '',
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'firstName': firstName});
    result.addAll({'lastName': lastName});
    result.addAll({'email': email});
    result.addAll({'role': role});
    result.addAll({'deviceToken': deviceToken});

    return result;
  }

  User copyFrom({
    String? userId,
    String? firstName,
    String? lastName,
    String? email,
    String? token,
    String? role,
    String? deviceToken,
    String? firebaseToken,
    List<Subject>? subjects,
    List<Rating>? ratingAsTutor,
    List<Rating>? ratingAsTutee,
    bool? isEmailVerified,
    bool? hasRoom,
    String? avatar,
    String? dateTimeAvailability,
    bool? isAvailable,
  }) {
    return User(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      token: token ?? this.token,
      deviceToken: deviceToken ?? this.deviceToken,
      firebaseToken: firebaseToken ?? this.firebaseToken,
      subjects: subjects ?? this.subjects,
      ratingAsTutor: ratingAsTutor ?? this.ratingAsTutor,
      ratingAsTutee: ratingAsTutee ?? this.ratingAsTutee,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      hasRoom: hasRoom ?? this.hasRoom,
      avatar: avatar ?? this.avatar,
      isAvailable: isAvailable ?? this.isAvailable,
      dateTimeAvailability: dateTimeAvailability ?? this.dateTimeAvailability,
    );
  }

  void printUser() {
    print('userId: $userId');
    print('firstName: $firstName');
    print('lastName: $lastName');
    print('email: $email');
    print('role: $role');
    print('token: $token');
    print('deviceToken: $deviceToken');
    print('firebaseToken: $firebaseToken');
    print('subjects: $subjects');
    //print('ratingAsTutor: ${[...ratingAsTutor.map((e) => e.rating).toList()]}');
    print('ratingAsTutee: $ratingAsTutee');
    print('dateTimeAvailability: $dateTimeAvailability');
    print('isAvailable: $isAvailable');
    print('isEmailVerified: $isEmailVerified');
  }

  factory User.emptyUser() {
    return User(
      userId: '',
      firstName: '',
      lastName: '',
      email: '',
      role: '',
      token: '',
      deviceToken: '',
      firebaseToken: '',
      avatar: '',
      dateTimeAvailability: '',
      isEmailVerified: false,
      isAvailable: false,
      subjects: [],
      ratingAsTutor: [],
      ratingAsTutee: [],
    );
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['_id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      avatar: map['avatar'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      token: map['token'] ?? '',
      isAvailable: map['isAvailable'] ?? false,
      dateTimeAvailability: map['timeAndDateAvailability'] ?? '',
      isEmailVerified: map['isEmailVerified'] ?? false,
      hasRoom: map['hasRoom'] ?? false,
      ratingAsTutor: map['ratingsAsTutor'] == null
          ? []
          : List<Rating>.from(
              map['ratingsAsTutor']?.map(
                (x) => Rating.fromMap(x),
              ),
            ),
      ratingAsTutee: map['ratingsAsTutee'] == null
          ? []
          : List<Rating>.from(
              map['ratingsAsTutee']?.map(
                (x) => Rating.fromMap(x),
              ),
            ),
      subjects: map['subjects'].isEmpty
          ? []
          : List<Subject>.from(
              map['subjects']?.map(
                (x) => Subject.fromMap(x),
              ),
            ),
    );
  }

  Subject get firstSubject => subjects.first;
  List<Subject> get getSubjects => subjects;
  List<Rating> get tutorRatings => ratingAsTutor;
  List<Rating> get tuteeRatings => ratingAsTutee;

  Subject getSubject(String subjectCode) {
    return subjects.firstWhere((subject) => subject.subjectCode == subjectCode);
  }

  List<SubTopic> getSubTopics(String subjectCode) {
    return [SubTopic.empty(), ...getSubject(subjectCode).subTopics];
  }

  bool isSubjectAdded(String subjectCode) {
    return subjects.any((subject) => subject.subjectCode == subjectCode);
  }

  double getRating([bool isTutor = false]) {
    double totalRating = 0;

    var ratings = isTutor ? ratingAsTutor : ratingAsTutee;
    for (var rating in ratings) {
      var subjectRatings = 0;
      for (var subjRating in rating.subjectRatings) {
        subjectRatings += subjRating.rating;
      }
      totalRating += rating.subjectRatings.isNotEmpty
          ? subjectRatings / rating.subjectRatings.length
          : 0;
    }

    return ratings.isNotEmpty ? totalRating / ratings.length : 0;
  }

  String parsedRating([bool isTutor = false]) {
    var rating = getRating(isTutor);

    if (rating == 0) return '0';

    int wholeNumber = rating.toInt();
    double decimalValue = rating - wholeNumber;

    if (decimalValue > 0) {
      return rating.toStringAsFixed(1);
    }

    return getRating(isTutor).toStringAsFixed(0);
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
