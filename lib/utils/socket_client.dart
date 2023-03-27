import '../constants/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketClient {
  io.Socket? socket;
  late String userId;
  static SocketClient? _instance;

  SocketClient._internal(String userId) {
    socket = io.io(
      baseServerAddress,
      io.OptionBuilder().setTransports(['websocket']).build(),
    );

    // socket!.connect();
    socket!.onConnect((data) => print('Connection established'));
    socket!.onConnectError((data) => print('Connect Error: $data'));
    socket!.onDisconnect((data) => print('Socket.IO server disconnected'));
  }

  factory SocketClient(String userId) {
    _instance = SocketClient._internal(userId);
    return _instance!;
  }

  static SocketClient get instance {
    return _instance!;
  }
}
