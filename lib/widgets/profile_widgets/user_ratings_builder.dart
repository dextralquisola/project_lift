import 'package:flutter/material.dart';
import 'package:project_lift/models/user.dart';

import '../app_text.dart';

class UserRatingsBuilder extends StatelessWidget {
  final User user;
  final String title;
  const UserRatingsBuilder({
    super.key,
    required this.user,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    var isTutor = user.role == "tutor";
    var ratings = isTutor ? user.ratingAsTutor : user.ratingAsTutee;
    ratings
        .sort((a, b) => b.getSubjectRating().compareTo(a.getSubjectRating()));

    var totalRatings = user.parsedRating(isTutor);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        child: Column(
          children: [
            ExpansionTile(
              initiallyExpanded: true,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    text: "$title ⭐️ $totalRatings ",
                    fontWeight: FontWeight.w600,
                  ),
                  AppText(
                    text: "(${ratings.length})",
                    textColor: Colors.grey,
                  )
                ],
              ),
              children: [
                if (ratings.isEmpty)
                  ListTile(
                    title: AppText(text: "No ratings yet"),
                  ),
                // ...ratings
                //     .map((e) {
                //       return ListTile(
                //         title: AppText(
                //             text:
                //                 "${e.firstName} ${e.lastName}: ${e.rating} ⭐️"),
                //         subtitle: AppText(
                //           text: "Comment: ${e.feedback}",
                //         ),
                //       );
                //     })
                //     .toList()
                //     .take(5),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
