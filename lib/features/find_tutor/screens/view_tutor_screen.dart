import 'package:flutter/material.dart';
import 'package:project_lift/widgets/app_button.dart';
import 'package:project_lift/widgets/app_text.dart';
import 'package:project_lift/widgets/profile_widgets/profile_name_builder.dart';
import 'package:project_lift/widgets/profile_widgets/profile_top_builder.dart';
import 'package:project_lift/widgets/profile_widgets/user_ratings_builder.dart';

import '../../../models/user.dart';

class ViewTutorScreen extends StatefulWidget {
  final User tutor;
  const ViewTutorScreen({
    super.key,
    required this.tutor,
  });

  @override
  State<ViewTutorScreen> createState() => _ViewTutorScreenState();
}

class _ViewTutorScreenState extends State<ViewTutorScreen> {
  @override
  Widget build(BuildContext context) {
    final user = widget.tutor;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          text: "View Tutor",
          textColor: Colors.white,
          textSize: 20,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProfileTopBuilder(user: user, isView: true),
            NameBuilder(user: user),
            UserRatingsBuilder(user: user), // default is tutor
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: AppButton(
                height: 50,
                wrapRow: true,
                onPressed: () {},
                text: "Ask for help",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
