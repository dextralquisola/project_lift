import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:project_lift/features/auth/screens/login_screen.dart';
import 'package:project_lift/features/find_tutor/service/tutor_service.dart';
import 'package:project_lift/features/study_pool/service/study_pool_service.dart';
import 'package:project_lift/providers/current_room_provider.dart';
import 'package:project_lift/providers/study_room_providers.dart';
import 'package:project_lift/providers/tutors_provider.dart';
import 'package:project_lift/providers/user_provider.dart';
import 'package:project_lift/providers/user_requests_provider.dart';
import 'package:project_lift/widgets/splash_screen.dart';
import 'package:provider/provider.dart';

import 'constants/styles.dart';
import 'features/auth/service/auth_service.dart';
import 'features/home/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TutorProvider()),
        ChangeNotifierProvider(create: (_) => StudyRoomProvider()),
        ChangeNotifierProvider(create: (_) => CurrentStudyRoomProvider()),
        ChangeNotifierProvider(create: (_) => UserRequestsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final authService = AuthService();

  final studyRoomService = StudyPoolService();

  final tutorService = TutorService();

  @override
  void dispose() {
    super.dispose();
    print("Disposing MyApp!");
  }

  @override
  Widget build(BuildContext context) {
    print("Building MyApp!");
    final userProvider = Provider.of<UserProvider>(context);
    return MaterialApp(
      title: 'LFT',
      theme: ThemeData(
        fontFamily: 'Oxygen',
        primarySwatch: getMaterialColor(primaryColor),
      ),
      home: userProvider.isAuthenticated
          ? FutureBuilder(
              future: Future.wait([
                tutorService.fetchTutors(context),
                studyRoomService.getUserRoom(context),
                studyRoomService.fetchStudyRooms(context),
                studyRoomService.getPendingChatRoomIds(context),
                studyRoomService.getTuteeRequests(context),
                studyRoomService.getMyRequests(context),
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen();
                }
                return const HomeScreen();
              },
            )
          : FutureBuilder(
              future: authService.fetchUser(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen();
                }

                return const LoginScreen();
              },
            ),
    );
  }
}
