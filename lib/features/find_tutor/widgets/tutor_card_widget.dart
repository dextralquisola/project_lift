import 'package:flutter/material.dart';

import 'package:badges/badges.dart' as badges;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../utils/find_tutor_utitls.dart';
import '../../../widgets/report_widget.dart';
import '../../../services/global_services.dart';
import '../../../utils/date_time_utils.dart';
import '../../../widgets/app_button.dart';
import '../../../constants/styles.dart';
import '../../../widgets/app_text.dart';
import '../../../models/user.dart';

import '../../study_pool/screens/create_room_screen.dart';
import '../screens/view_tutor_screen.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class TutorCard extends StatelessWidget {
  final User tutor;
  final bool isPendingRequest;
  final bool isEnabled;

  final globalService = GlobalService();

  TutorCard({
    super.key,
    required this.tutor,
    required this.isPendingRequest,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    bool isAvailable = isAvailableAtCurrentDate(tutor);
    final formattedName =
        "${tutor.firstName.split(' ').map((e) => e.capitalize()).join(' ')} ${tutor.lastName.capitalize()}";
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onLongPress: () {
          //report tutor
          showReportDialog(
            context: context,
            user: tutor,
          );
        },
        onTap: () {
          //_showDialog(context: context, tutor: tutor, isAvailable: isAvailable);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return ViewTutorScreen(
                tutor: tutor,
                isEnabled: isEnabled,
                isPendingRequest: isPendingRequest,
              );
            }),
          );
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
                                ? Container(
                                    color: Colors.green,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            FontAwesomeIcons.chalkboardUser,
                                            color: Colors.white,
                                            size: 50,
                                          ),
                                        ],
                                      ),
                                    ),
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
                              text: formattedName,
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
                    isEnabled: isAvailable &&
                        isEnabled &&
                        isPendingRequest &&
                        !tutor.hasRoom,
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
                    text: tutor.hasRoom
                        ? "Currently in session"
                        : !isAvailable
                            ? "Not Available"
                            : "Ask Help",
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
}
