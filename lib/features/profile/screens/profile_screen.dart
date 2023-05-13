import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_lift/constants/styles.dart';
import 'package:project_lift/features/auth/service/auth_service.dart';
import 'package:project_lift/features/profile/screens/select_avatar_screen.dart';
import 'package:project_lift/features/profile/screens/tutor_application_screen.dart';
import 'package:project_lift/models/tutor_application.dart';
import 'package:project_lift/providers/current_room_provider.dart';
import 'package:project_lift/providers/study_room_providers.dart';
import 'package:project_lift/utils/utils.dart';
import 'package:project_lift/widgets/app_text.dart';
import 'package:provider/provider.dart';

import '../../../models/rating.dart';
import '../../../models/user.dart';
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
    final ratingAsTutor = user.parsedRating(true);
    final ratingAsTutee = user.parsedRating(false);

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
                              borderRadius: BorderRadius.circular(100),
                              child: user.avatar != ""
                                  ? SizedBox(
                                      height: 150,
                                      width: 150,
                                      child: CachedNetworkImage(
                                        imageUrl: user.avatar,
                                        fit: BoxFit.cover,
                                        progressIndicatorBuilder:
                                            (context, url, progress) {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: progress.progress,
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Container(
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
                              bottom: 1,
                              right: -0,
                              child: AppText(
                                text: userProvider.isTutor
                                    ? '⭐️ $ratingAsTutor'
                                    : '⭐️ $ratingAsTutee',
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
                            await logout(context, userProvider);
                          },
                          icon: const Icon(Icons.exit_to_app,
                              color: Colors.white),
                        ),
                        PopupMenuButton(
                          icon:
                              const Icon(Icons.more_vert, color: Colors.white),
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                value: 0,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.edit, color: Colors.black),
                                    const SizedBox(width: 5),
                                    AppText(
                                      text: "Edit Profile Picture",
                                    ),
                                  ],
                                ),
                              ),
                            ];
                          },
                          onSelected: (value) async {
                            if (value == 0) {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SelectAvatarScreen(),
                                ),
                              );

                              setState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
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
                  _tutorScreenBuilder(userProvider),
                  const SizedBox(height: 20),
                ],
              ),
            if (userProvider.isTutor)
              Column(
                children: [
                  _userRatingsBuilder(user, "Tutor ratings", true),
                  const SizedBox(height: 20),
                  _userRatingsBuilder(user, "Tutee ratings", false),
                ],
              ),
            if (!userProvider.isTutor)
              Column(
                children: [
                  _userRatingsBuilder(user, "Tutee ratings", false),
                  const SizedBox(height: 20),
                ],
              ),
            if (!userProvider.isTutor)
              _tuteeScreenBuilder(
                userProvider,
                userRequestsProvider,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context, UserProvider userProvider) async {
    final tutorsProvider = Provider.of<TutorProvider>(context, listen: false);
    final userRequestsProvider =
        Provider.of<UserRequestsProvider>(context, listen: false);
    final studyPoolProvider =
        Provider.of<StudyRoomProvider>(context, listen: false);
    final currentStudyRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context, listen: false);
    var isLogoutSuccess = await authService.logout(context);
    if (isLogoutSuccess) {
      tutorsProvider.clearTutors();
      studyPoolProvider.clearStudyRooms();
      currentStudyRoomProvider.leaveStudyRoom();
      userRequestsProvider.clearRequests();
      await userProvider.logout();
    } else {
      showSnackBar(context, "Something went wrong");
    }
  }

  Widget _tuteeScreenBuilder(
      UserProvider userProvider, UserRequestsProvider userRequestsProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          AppButton(
            onPressed: userRequestsProvider.tutorApplication.id.isNotEmpty
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TutotApplicationScreen(),
                      ),
                    );
                  }
                : () {
                    _showDialog(context);
                  },
            height: 50,
            wrapRow: true,
            text: userRequestsProvider.tutorApplication.id.isNotEmpty
                ? "View application"
                : "Be a tutor!",
          ),
        ],
      ),
    );
  }

  Widget _tutorScreenBuilder(UserProvider userProvider) {
    final user = userProvider.user;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
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
                          builder: (context) => const AddSubjectScreen(),
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
    );
  }

  Widget _userRatingsBuilder(User user, String title, bool isTutor) {
    var ratings = isTutor ? user.ratingAsTutor : user.ratingAsTutee;
    var totalRatings = user.parsedRating(isTutor);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        child: Column(
          children: [
            ExpansionTile(
              initiallyExpanded: true,
              title: AppText(
                text: "$title ⭐️ $totalRatings",
                fontWeight: FontWeight.w600,
              ),
              children: [
                if (ratings.isEmpty)
                  ListTile(
                    title: AppText(text: "No ratings yet"),
                  ),
                ...ratings.map((e) {
                  return ListTile(
                    title: Row(
                      children: [
                        AppText(text: "Anon user"),
                        const SizedBox(width: 10),
                        AppText(text: e.rating.toString()),
                      ],
                    ),
                    subtitle: AppText(
                      text: e.feedback,
                    ),
                  );
                }).toList(),
              ],
            ),
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
              AppText(text: "3. Create tutor session"),
              const SizedBox(height: 10),
              AppButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TutotApplicationScreen(),
                    ),
                  );
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
