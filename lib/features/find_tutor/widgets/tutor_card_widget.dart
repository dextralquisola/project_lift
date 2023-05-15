import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:badges/badges.dart' as badges;
import 'package:project_lift/constants/styles.dart';
import 'package:project_lift/utils/date_time_utils.dart';

import '../../study_pool/screens/create_room_screen.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text.dart';
import '../../../models/user.dart';

class TutorCard extends StatelessWidget {
  final User tutor;
  final bool isPendingRequest;
  final bool isEnabled;
  const TutorCard({
    super.key,
    required this.tutor,
    required this.isPendingRequest,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          _showDialog(context: context, tutor: tutor);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      badges.Badge(
                        position: badges.BadgePosition.topEnd(),
                        badgeStyle: badges.BadgeStyle(
                          shape: badges.BadgeShape.square,
                          badgeColor: primaryColor.withOpacity(0.8),
                        ),
                        badgeContent: AppText(
                          text: '⭐️ ${tutor.parsedRating(true)}',
                          textColor: Colors.white,
                        ),
                        badgeAnimation: const badges.BadgeAnimation.size(
                          animationDuration: Duration(seconds: 1),
                          colorChangeAnimationDuration: Duration(seconds: 1),
                          loopAnimation: false,
                          curve: Curves.fastOutSlowIn,
                          colorChangeAnimationCurve: Curves.easeInCubic,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: tutor.avatar == ""
                                ? CachedNetworkImage(
                                    imageUrl:
                                        "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80",
                                    fit: BoxFit.cover,
                                    progressIndicatorBuilder:
                                        (context, url, progress) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: progress.progress,
                                        ),
                                      );
                                    },
                                  )
                                : CachedNetworkImage(
                                    imageUrl: tutor.avatar,
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
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _textBuilder(
                              text: "${tutor.firstName} ${tutor.lastName}",
                              isName: true,
                            ),
                            const SizedBox(height: 5),
                            _textBuilder(text: "Specialization: "),
                            ...tutor.subjects
                                .map(
                                  (e) {
                                    return _textBuilder(
                                        text:
                                            '${e.subjectCode}: ${e.description}',
                                        textSize: 12);
                                  },
                                )
                                .toList()
                                .take(3)
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  _textBuilder(text: "Schedule"),
                  tutor.dateTimeAvailability.isEmpty
                      ? _textBuilder(text: "No schedule available")
                      : _textBuilder(
                          text: dateTimeAvailabilityFormatter(
                            context,
                            tutor.dateTimeAvailability,
                          ),
                        ),
                  const SizedBox(height: 20),
                  AppButton(
                    height: 50,
                    isEnabled: isEnabled && isPendingRequest && !tutor.hasRoom,
                    onPressed: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CreateStudyRoomScreen(
                            isAskHelp: true,
                            tutor: tutor,
                          ),
                        ),
                      );
                    },
                    wrapRow: true,
                    text: tutor.hasRoom ? "Currently in session" : "Ask Help",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textBuilder({
    required String text,
    bool isName = false,
    double textSize = 14,
  }) {
    return AppText(
      text: text,
      textSize: isName ? 18 : textSize,
      fontWeight: isName ? FontWeight.bold : FontWeight.w300,
      textOverflow: TextOverflow.ellipsis,
    );
  }

  void _showDialog({
    required BuildContext context,
    required User tutor,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            title: AppText(text: "${tutor.firstName} ${tutor.lastName}"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _textBuilder(text: "Specialization: "),
                ...tutor.subjects
                    .map(
                      (e) {
                        return _textBuilder(
                            text: '${e.subjectCode}: ${e.description}',
                            textSize: 12);
                      },
                    )
                    .toList()
                    .take(3),
                const SizedBox(height: 10),
                _textBuilder(text: "Schedule"),
                _textBuilder(text: "Monday - Friday: 8:00 AM - 5:00 PM"),
                const SizedBox(height: 20),
                AppButton(
                  height: 50,
                  isEnabled: isEnabled && isPendingRequest && !tutor.hasRoom,
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CreateStudyRoomScreen(
                          isAskHelp: true,
                          tutor: tutor,
                        ),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  wrapRow: true,
                  text: tutor.hasRoom ? "Currently in session" : "Ask Help",
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
