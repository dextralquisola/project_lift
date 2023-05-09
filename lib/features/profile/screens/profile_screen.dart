import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_lift/constants/styles.dart';
import 'package:project_lift/features/auth/service/auth_service.dart';
import 'package:project_lift/main.dart';
import 'package:project_lift/providers/current_room_provider.dart';
import 'package:project_lift/providers/study_room_providers.dart';
import 'package:project_lift/utils/utils.dart';
import 'package:project_lift/widgets/app_text.dart';
import 'package:provider/provider.dart';

import '../../../providers/tutors_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/user_requests_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/background_cover.dart';
import 'add_subject_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

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
    final authService = AuthService();
    final userProvider = Provider.of<UserProvider>(context);
    final tutorsProvider = Provider.of<TutorProvider>(context, listen: false);
    final userRequestsProvider = Provider.of<UserRequestsProvider>(context);
    final studyPoolProvider =
        Provider.of<StudyRoomProvider>(context, listen: false);
    final currentStudyRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context, listen: false);
    final user = userProvider.user;
    final ratingAsTutor = user.getRating(isTutor: true);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const SizedBox(
                    child: BackgroundCover(hasBgImage: false),
                  ),
                  Positioned(
                    bottom: -75,
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: Colors.white, width: 5),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(105),
                              child: Container(
                                color: Colors.deepPurple,
                              ),
                            ),
                            if (userProvider.isTutor)
                              Positioned(
                                bottom: -5,
                                left: 1,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    color: primaryColor,
                                    child: const Icon(
                                      FontAwesomeIcons.graduationCap,
                                      color: Colors.amber,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom: 0,
                              right: -15,
                              child: AppText(
                                text: '⭐️ $ratingAsTutor',
                                textSize: 20,
                                textColor: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Row(
                      children: [
                        IconButton(
                          constraints: const BoxConstraints(),
                          onPressed: () async {
                            var isLogoutSuccess =
                                await authService.logout(context);
                            if (isLogoutSuccess) {
                              tutorsProvider.clearTutors();
                              studyPoolProvider.clearStudyRooms();
                              currentStudyRoomProvider.leaveStudyRoom();
                              userRequestsProvider.clearRequests();
                              await userProvider.logout();
                            } else {
                              showSnackBar(context, "Something went wrong");
                            }
                          },
                          icon: const Icon(Icons.exit_to_app,
                              color: Colors.white),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(),
                          onPressed: () {},
                          icon:
                              const Icon(Icons.more_vert, color: Colors.white),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 80),
            if (userProvider.isTutor)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppText(
                      text: "${user.firstName} ${user.lastName}",
                      textSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Column(
                        children: [
                          ExpansionTile(
                            initiallyExpanded: true,
                            title: AppText(
                              text: "Subjects I can help with",
                              fontWeight: FontWeight.w600,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AddSubjectScreen(),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.add, color: primaryColor),
                                ),
                                AnimatedIcon(
                                  icon: AnimatedIcons.menu_close,
                                  progress: animationController,
                                ),
                              ],
                            ),
                            children: [
                              if (userProvider.user.subjects.isEmpty)
                                ListTile(
                                  title: AppText(text: "No subjects yet"),
                                ),
                              ...user.subjects.map((e) {
                                return ListTile(
                                  title: AppText(text: e.subjectCode),
                                  subtitle: AppText(text: e.description),
                                );
                              }).toList(),
                            ],
                            onExpansionChanged: (value) {
                              if (value) {
                                animationController.forward();
                              } else {
                                animationController.reverse();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            // profile body
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: AppText(text: 'Be a tutor!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                  text:
                      "Beware this cannot be undo, being a tutor can still be a tutee. Being a tutor can have the ff:"),
              const SizedBox(height: 10),
              AppText(text: "1. Badge"),
              AppText(text: "2. Rated by tutee"),
              AppText(text: "3. Setup schedule"),
              AppText(text: "4. Create tutor session"),
              const SizedBox(height: 10),
              AppButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                height: 50,
                wrapRow: true,
                text: "Be a tutor!",
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: AppText(
                  text: "Maybe next time...",
                  textColor: Colors.grey,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
