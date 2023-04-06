import 'package:flutter/material.dart';

import '../models/message.dart';

class MessageProvider with ChangeNotifier {
  List<Message> _messages = [];

  List<Message> get messages => _messages.reversed.toList();

  void setMessages() {}
}
