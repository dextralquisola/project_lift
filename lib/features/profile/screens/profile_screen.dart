import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/service/auth_service.dart';

import '../../../widgets/profile_widgets/user_ratings_builder.dart';
import '../../../widgets/app_text.dart';
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
            const SizedBox(height: 80),
            AppText(
              text: "${user.firstName} ${user.lastName}",
              textSize: 24,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 5),
            AppText(
              text: user.email,
              textColor: Colors.grey,
              textSize: 14,
            ),
            const SizedBox(height: 20),
            if (userProvider.isTutor)
              Column(
                children: [
                  TutorScreen(
                    animationController: animationController,
                    updateState: () => setState(() {}),
                    user: user,
                  ),
                  const SizedBox(height: 20),
                  UserRatingsBuilder(user: user, title: "Tutor ratings"),
                  const SizedBox(height: 20),
                  UserRatingsBuilder(user: user, title: "Tutee ratings"),
                ],
              ),
            if (!userProvider.isTutor)
              Column(
                children: [
                  UserRatingsBuilder(user: user, title: "Tutee ratings"),
                  const SizedBox(height: 20),
                  TuteeScreen(
                    tutorApplication: userRequestsProvider.tutorApplication,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
