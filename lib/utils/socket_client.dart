import '../constants/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketClient {
  io.Socket? socket;
  late String authToken;
  static SocketClient? _instance;

  SocketClient._internal(String authToken) {
    socket = io.io(
      baseServerAddress,
      io.OptionBuilder().setTransports(['websocket']).setQuery(
        {
          'authToken': authToken,
        },
      ).build(),
    );

    // socket!.connect();
    socket!.onConnect((data) => print('Connection established'));
    socket!.onConnectError((data) => print('Connect Error: $data'));
    socket!.onDisconnect((data) => print('Socket.IO server disconnected'));
  }

  factory SocketClient(String authToken) {
    _instance = SocketClient._internal(authToken);
    return _instance!;
  }

  static SocketClient get instance {
    return _instance!;
  }
}
