import 'dart:convert';

class Message {
  final String messageId;
  final String roomId;
  final String userId;
  final String message;
  final String createdAt;

  Message({
    required this.messageId,
    required this.roomId,
    required this.userId,
    required this.message,
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

  factory Message.fromMap(Map<String, dynamic> map, [bool isFromAppSend = false]) {
    return Message(
      messageId: map['_id'] ?? '',
      roomId: map['roomId'] ?? '',
      userId: isFromAppSend ? map['userId'] : map['userId']['_id'] ?? '',
      message: map['message'] ?? '',
      createdAt: map['createdAt'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) => Message.fromMap(json.decode(source));
}
