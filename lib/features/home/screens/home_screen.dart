import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../providers/current_room_provider.dart';
import '../../../providers/study_room_providers.dart';
import '../../../providers/tutors_provider.dart';
import '../../../providers/user_requests_provider.dart';
import '../../find_tutor/screens/find_tutor_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../profile/service/profile_service.dart';
import '../../study_pool/screens/study_pool_screen.dart';
import '../../../widgets/app_text.dart';

import '../../../providers/app_state_provider.dart';
import '../../../providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int pageIndex = 0;
  var pages = [
    const FindTutorScreen(),
    const StudyPoolScreen(),
    const ProfileScreen(),
  ];

  final profileService = ProfileService();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final appStateProvider = Provider.of<AppStateProvider>(context);

    pageIndex = appStateProvider.currentHomePageIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (appStateProvider.getNotif != null) {
        showAlertDialog(context, appStateProvider.getNotif);
      }

      if (appStateProvider.getNotifLogout != null) {
        showLogoutDialog(context, appStateProvider.getNotifLogout);
      }
    });

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: SafeArea(child: pages[pageIndex]),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: pageIndex,
          onTap: (index) => _updatePage(index, appStateProvider),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          selectedIconTheme: const IconThemeData(color: Colors.black),
          unselectedIconTheme: const IconThemeData(color: Colors.black54),
          selectedLabelStyle: const TextStyle(color: Colors.black),
          unselectedLabelStyle: const TextStyle(color: Colors.black54),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              activeIcon: Icon(
                Icons.home_outlined,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.group,
              ),
              activeIcon: Icon(
                Icons.group_outlined,
              ),
              label: 'Chat Room',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
              ),
              activeIcon: Icon(
                Icons.person_outlined,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  void _updatePage(int index, AppStateProvider appStateProvider) async {
    if (index == 2) {
      await profileService.fetchUser(context);
    }
    setState(() {
      pageIndex = index;
      appStateProvider.setCurrentHomePageIndex(index, false);
    });
  }

  Future<bool> onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const AppText(text: 'Are you sure?'),
            content: const AppText(text: 'Do you want to exit LFT?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const AppText(text: 'No'),
              ),
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: const AppText(text: 'Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  void showLogoutDialog(BuildContext context, dynamic data) {
    final appStateProvider =
        Provider.of<AppStateProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final tutorsProvider = Provider.of<TutorProvider>(context, listen: false);
    final userRequestsProvider =
        Provider.of<UserRequestsProvider>(context, listen: false);
    final studyPoolProvider =
        Provider.of<StudyRoomProvider>(context, listen: false);
    final currentStudyRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const AppText(
            text: 'Notice!',
            fontWeight: FontWeight.w600,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(text: data['message']),
            ],
          ),
          actions: [
            TextButton(
              child: const AppText(text: 'OK'),
              onPressed: () async {
                appStateProvider.dismissNotifLogout();
                await userProvider.logout();
                tutorsProvider.clearTutors();
                userRequestsProvider.clearRequests();
                studyPoolProvider.clearStudyRooms();
                currentStudyRoomProvider.clearRoom();

                if (mounted) Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showAlertDialog(BuildContext context, dynamic data) {
    final appStateProvider =
        Provider.of<AppStateProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const AppText(
            text: 'Reported!',
            fontWeight: FontWeight.w600,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(text: 'You have been reported!'),
              const SizedBox(height: 10),
              AppText(text: 'Category: ${data['category']}'),
              AppText(text: 'Reason: ${data['content']}'),
            ],
          ),
          actions: [
            TextButton(
              child: const AppText(text: 'OK'),
              onPressed: () {
                appStateProvider.dismissNotif();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
