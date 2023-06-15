import 'package:flutter/material.dart';
import 'package:project_lift/widgets/report_user_screen.dart';

import '../utils/find_tutor_utitls.dart';
import '../../../utils/date_time_utils.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text.dart';
import '../../../widgets/profile_widgets/profile_name_builder.dart';
import '../../../widgets/profile_widgets/profile_top_builder.dart';
import '../../../widgets/profile_widgets/user_ratings_builder.dart';

import '../../../models/user.dart';
import '../../study_pool/screens/create_room_screen.dart';

class ViewTutorScreen extends StatefulWidget {
  final User tutor;
  final bool isPendingRequest;
  final bool isEnabled;
  const ViewTutorScreen({
    super.key,
    required this.tutor,
    required this.isPendingRequest,
    required this.isEnabled,
  });

  @override
  State<ViewTutorScreen> createState() => _ViewTutorScreenState();
}

class _ViewTutorScreenState extends State<ViewTutorScreen> {
  @override
  Widget build(BuildContext context) {
    final user = widget.tutor;
    bool isAvailable = isAvailableAtCurrentDate(user);
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          text: "View Tutor",
          textColor: Colors.white,
          textSize: 20,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0.0,
        actions: [
          IconButton(
            onPressed: () {
              //report tutor
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return ReportUserScreen(user: user);
                }),
              );
            },
            icon: const Icon(
              Icons.warning_amber_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileTopBuilder(user: user, isView: true),
            NameBuilder(user: user),
            //? top part
            const SizedBox(height: 10),
            // AppText(text: "Schedule", textSize: 17),
            // const SizedBox(height: 5),
            AppText(
              text: dateTimeAvailabilityFormatter(
                  context, user.dateTimeAvailability),
              textSize: 14,
            ),
            UserRatingsBuilder(user: user), // default is tutor
            _subjectsBuilder(user),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: AppButton(
                  isEnabled: widget.isEnabled &&
                      widget.isPendingRequest &&
                      isAvailable &&
                      !user.hasRoom,
                  height: 50,
                  wrapRow: true,
                  onPressed: () async {
                    var result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CreateStudyRoomScreen(
                          isAskHelp: true,
                          tutor: user,
                        ),
                      ),
                    ) as bool?;

                    if (result != null && result) {
                      Navigator.of(context).pop();
                    }
                  },
                  text: user.hasRoom
                      ? "Currently in session"
                      : !isAvailable
                          ? "Not Available"
                          : "Ask Help"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _subjectsBuilder(User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Card(
        child: Column(
          children: [
            ExpansionTile(
              initiallyExpanded: true,
              title: const AppText(
                text: "Subjects I can help with",
                fontWeight: FontWeight.w600,
              ),
              children: [
                if (user.subjects.isEmpty)
                  const ListTile(
                    title: AppText(text: "No subjects yet"),
                  ),
                ...user.subjects.map((e) {
                  return ListTile(
                    title: AppText(text: e.subjectCode),
                    subtitle: AppText(
                      text: e.description,
                      textOverflow: TextOverflow.ellipsis,
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
}
