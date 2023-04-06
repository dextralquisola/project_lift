import 'dart:convert';

class Message {
  final String messageId;
  final String roomId;
  final String userId;
  final String message;

  Message({
    required this.messageId,
    required this.roomId,
    required this.userId,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'messageId': messageId});
    result.addAll({'roomId': roomId});
    result.addAll({'userId': userId});
    result.addAll({'message': message});
  
    return result;
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageId: map['messageId'] ?? '',
      roomId: map['roomId'] ?? '',
      userId: map['userId'] ?? '',
      message: map['message'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) => Message.fromMap(json.decode(source));
}
