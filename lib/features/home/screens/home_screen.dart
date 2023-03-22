import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_lift/features/auth/screens/login_screen.dart';
import 'package:project_lift/widgets/app_button.dart';
import 'package:project_lift/widgets/app_text.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int pageIndex = 0;
  var pages = [
    Center(child: AppText(text: 'Home')),
    Center(child: AppText(text: 'Messages')),
    Center(child: AppText(text: 'Profile')),
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: SafeArea(child: pages[pageIndex]),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: pageIndex,
          onTap: _updatePage,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          selectedIconTheme: const IconThemeData(color: Colors.black),
          unselectedIconTheme: const IconThemeData(color: Colors.black54),
          selectedLabelStyle: const TextStyle(color: Colors.black),
          unselectedLabelStyle: const TextStyle(color: Colors.black54),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_outlined,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.mail_outline,
              ),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_outline,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  void _updatePage(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  Future<bool> onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: AppText(text: 'Are you sure?'),
            content: AppText(text: 'Do you want to exit LFT?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: AppText(text: 'No'),
              ),
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: AppText(text: 'Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }
}
