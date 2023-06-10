import 'dart:convert';

class Message {
  final String messageId;
  final String roomId;
  final String userId;
  final String firstName;
  final String lastName;
  final String message;
  final String createdAt;

  Message({
    required this.messageId,
    required this.roomId,
    required this.userId,
    required this.message,
    required this.firstName,
    required this.lastName,
    this.createdAt = '',
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'messageId': messageId});
    result.addAll({'roomId': roomId});
    result.addAll({'userId': userId});
    result.addAll({'message': message});
    return result;
  }

  factory Message.fromMap(Map<String, dynamic> map,
      [bool isFromAppSend = false]) {
    return Message(
      messageId: isFromAppSend ? map['message']['_id'] ?? '' : map['_id'] ?? '',
      roomId: '',
      userId:
          isFromAppSend ? map['user']['userId'] ?? '' : map['userId']['_id'] ?? '',
      firstName: isFromAppSend
          ? map['user']['firstName'] ?? ''
          : map['userId']['firstName'] ?? '',
      lastName: isFromAppSend
          ? map['user']['lastName'] ?? ''
          : map['userId']['lastName'] ?? '',
      message: isFromAppSend ? map['message']['message'] ?? '' : map['message'] ?? '',
      createdAt:
          isFromAppSend ? map['message']['createdAt'] ?? '' : map['createdAt'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source));
}
