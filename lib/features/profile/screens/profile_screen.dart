import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/service/auth_service.dart';

import '../../../widgets/profile_widgets/profile_name_builder.dart';
import '../../../widgets/profile_widgets/user_ratings_builder.dart';
import '../../../widgets/profile_widgets/profile_top_builder.dart';
import '../widgets/profile_tutee_screen.dart';
import '../widgets/profile_tutor_screen.dart';

import '../../../providers/user_requests_provider.dart';
import '../../../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  final authService = AuthService();

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userRequestsProvider = Provider.of<UserRequestsProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileTopBuilder(
              user: user,
              updateState: () => setState(() {}),
            ),
            NameBuilder(user: user),
            if (!userProvider.isTutor)
              Column(
                children: [
                  UserRatingsBuilder(user: user, isTuteeBuilder: true),
                  const SizedBox(height: 20),
                  TuteeScreen(
                    tutorApplication: userRequestsProvider.tutorApplication,
                  ),
                ],
              ),
            if (userProvider.isTutor)
              Column(
                children: [
                  TutorScreen(
                    animationController: animationController,
                    updateState: () => setState(() {}),
                    user: user,
                  ),
                  const SizedBox(height: 20),
                  UserRatingsBuilder(
                    user: user,
                    isTuteeBuilder: true,
                  ),
                  const SizedBox(height: 20),
                  UserRatingsBuilder(user: user),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
