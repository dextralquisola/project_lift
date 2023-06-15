import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './features/auth/screens/login_screen.dart';
import './features/find_tutor/service/tutor_service.dart';
import './features/study_pool/service/study_pool_service.dart';
import './providers/app_state_provider.dart';
import './providers/current_room_provider.dart';
import './providers/study_room_providers.dart';
import './providers/top_subjects_provider.dart';
import './providers/tutors_provider.dart';
import './providers/user_provider.dart';
import './providers/user_requests_provider.dart';
import './utils/firebase_api.dart';
import './widgets/splash_screen.dart';

import './constants/styles.dart';
import './features/auth/service/auth_service.dart';
import './features/home/screens/home_screen.dart';
import './features/profile/service/profile_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseApi().initNotification();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TutorProvider()),
        ChangeNotifierProvider(create: (_) => StudyRoomProvider()),
        ChangeNotifierProvider(create: (_) => CurrentStudyRoomProvider()),
        ChangeNotifierProvider(create: (_) => UserRequestsProvider()),
        ChangeNotifierProvider(create: (_) => TopSubjectProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
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
  final profileService = ProfileService();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'LFT',
        theme: ThemeData(
          fontFamily: 'Oxygen',
          primarySwatch: getMaterialColor(primaryColor),
        ),
        home: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            return userProvider.isAuthenticated
                ? FutureBuilder(
                    future: Future.wait([
                      tutorService.fetchTutors(context),
                      studyRoomService.getUserRoom(context),
                      studyRoomService.fetchStudyRooms(context),
                      studyRoomService.getPendingChatRoomIds(context),
                      studyRoomService.getTuteeRequests(context),
                      studyRoomService.getMyRequests(context),
                      profileService.getUserApplication(context),
                      profileService.getMostSearchedTutorAndSubject(
                          context: context),
                      userProvider.getUserState(),
                    ]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SplashScreen();
                      }
                      return const HomeScreen();
                    },
                  )
                : FutureBuilder(
                    future: authService.autoLogin(context),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SplashScreen();
                      }

                      return const LoginScreen();
                    },
                  );
          },
        ));
  }
}
