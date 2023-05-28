import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../models/rating.dart';
import '../app_text.dart';

class UserRatingsBuilder extends StatelessWidget {
  final User user;
  final bool isTuteeBuilder;
  const UserRatingsBuilder({
    super.key,
    required this.user,
    this.isTuteeBuilder = false,
  });

  @override
  Widget build(BuildContext context) {
    var ratingsAsTutor = user.ratingAsTutor;
    var ratingsAsTutee = user.ratingAsTutee;

    ratingsAsTutee.sort((a, b) => b.rating.compareTo(a.rating));
    ratingsAsTutor.sort(
        (a, b) => b.averageSubjectsRating.compareTo(a.averageSubjectsRating));

    //var totalRatings = user.parsedRating(isTutor);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: isTuteeBuilder
          ? _tuteeRatingsBuilder(ratingsAsTutee)
          : _tutorRatingsBuilder(ratingsAsTutor),
    );
  }

  Widget _tuteeRatingsBuilder(
    List<TuteeRating> ratingsAsTutee,
  ) {
    var totalRatings = user.parsedRating();
    return Card(
      child: Column(
        children: [
          ExpansionTile(
            initiallyExpanded: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  text: "Tutee Rating ⭐️ $totalRatings",
                  fontWeight: FontWeight.w600,
                ),
                AppText(
                  text: "(${ratingsAsTutee.length})",
                  textColor: Colors.grey,
                )
              ],
            ),
            children: [
              if (ratingsAsTutee.isEmpty)
                ListTile(
                  title: AppText(text: "No ratings yet"),
                ),
              ..._tuteeRatingBuilder(ratingsAsTutee),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _tuteeRatingBuilder(List<TuteeRating> tuteeRatings) {
    return [
      ...tuteeRatings
          .map((e) {
            return ListTile(
              title:
                  AppText(text: "${e.firstName} ${e.lastName}: ${e.rating} ⭐️"),
              subtitle: AppText(
                text: "Comment: ${e.feedback}",
              ),
            );
          })
          .toList()
          .take(5),
    ];
  }

  Widget _tutorRatingsBuilder(List<TutorRating> tutorRatings) {
    return Card(
      child: ExpansionTile(
          title: AppText(
            text: "Tutor Rating ⭐️ ${user.parsedRating(true)}",
            fontWeight: FontWeight.w600,
          ),
          childrenPadding: const EdgeInsets.all(0),
          children: [
            if (tutorRatings.isEmpty)
              ListTile(
                title: AppText(text: "No ratings yet"),
              ),
            ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tutorRatings.length,
              itemBuilder: (context, index) {
                var rating = tutorRatings[index];
                return Card(
                  child: ExpansionTile(
                    title: AppText(
                        text:
                            "${rating.subjectCode} ⭐️ ${rating.averageSubjectsRating}"),
                    childrenPadding: const EdgeInsets.all(0),
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: rating.subTopicRatings.length,
                        itemBuilder: (context, index) {
                          var subTopicRating = rating.subTopicRatings[index];
                          return ExpansionTile(
                            title: _subTopicNameBuilder(subTopicRating),
                            childrenPadding: const EdgeInsets.all(0),
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: subTopicRating.ratings.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: AppText(
                                        text:
                                            "${subTopicRating.ratings[index].firstName} ${subTopicRating.ratings[index].lastName} ⭐️ ${subTopicRating.ratings[index].rating}"),
                                    subtitle: AppText(
                                      text:
                                          "Comment: ${subTopicRating.ratings[index].feedback}",
                                    ),
                                  );
                                },
                              )
                            ],
                          );
                        },
                      )
                    ],
                  ),
                );
              },
            ),
          ]),
    );
  }

  Widget _subTopicNameBuilder(SubTopicRating subTopicRating) {
    if (subTopicRating.name == "") {
      return AppText(
        text: "General ratings ⭐️ ${subTopicRating.averageSubtopicsRating}",
      );
    }
    return AppText(
      text:
          "${subTopicRating.name} ⭐️ ${subTopicRating.averageSubtopicsRating}",
    );
  }
}
