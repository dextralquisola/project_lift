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
    print('ratingAsTutor: ${[...ratingAsTutor.map((e) => e.rating).toList()]}');
    print('ratingAsTutee: $ratingAsTutee');
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
      isEmailVerified: false,
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
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      token: map['token'] ?? '',
      isEmailVerified: map['isEmailVerified'] ?? false,
      ratingAsTutor: map['ratingsAsTutor'] == null || map['ratingsAsTutor'].isEmpty
          ? []
          : List<Rating>.from(
              map['ratingsAsTutor']?.map(
                (x) => Rating.fromMap(x),
              ),
            ),
      ratingAsTutee: map['ratingsAsTutee'] == null || map['ratingsAsTutee'].isEmpty
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

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
