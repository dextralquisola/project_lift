import 'dart:convert';

class User {
  final String userId;
  final String name;
  final String email;
  final String token;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.token,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': name});
    result.addAll({'email': email});

    return result;
  }

  User copyFrom({
    String? userId,
    String? name,
    String? email,
    String? token,

  }) {
    return User(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
    );
  }

  factory User.initialize() {
    return User(
      userId: '',
      name: '',
      email: '',
      token: '',
    );
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user']['_id'] ?? '',
      name: map['user']['name'] ?? '',
      email: map['user']['email'] ?? '',
      token: map['token'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
