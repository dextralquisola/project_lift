// const String baseServerAddress =
//     'http://10.0.2.2:3000'; // used to connect to local host server

// const String baseServerAddress = 'http://192.168.254.100:3000';
// const String baseServerAddress = 'https://liftapp-google.onrender.com'; //test deploy
// const String baseServerAddress = 'https://liftapp.onrender.com';

import 'package:flutter/foundation.dart';

String baseServerAddress =
    kReleaseMode ? 'https://liftapp.onrender.com' : 'http://10.0.2.2:3000';

enum StudyRoomStatus { public, private }
