import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import './profile_top_menu_buttons.dart';
import '../app_text.dart';
import '../background_cover.dart';

import '../../models/user.dart';
import '../../constants/styles.dart';

class ProfileTopBuilder extends StatelessWidget {
  final User user;
  final VoidCallback? updateState;

  final bool isView;

  const ProfileTopBuilder({
    super.key,
    required this.user,
    this.updateState,
    this.isView = false,
  });

  @override
  Widget build(BuildContext context) {
    var isTutor = user.role == "tutor";
    //var ratingList = isTutor ? user.tutorRatings : user.tuteeRatings;
    var rating = isTutor ? user.parsedRating(true) : user.parsedRating();

    return SizedBox(
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
                      child: _userAvatarBuilder(),
                    ),
                    //paste here
                    _badgeBuilder(isTutor),
                    Positioned(
                      bottom: 1,
                      right: -10,
                      child: AppText(
                        text: '⭐️ $rating',
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
          if (!isView)
            Positioned(
              top: 0,
              right: 0,
              child: ProfileTopMenuButtons(
                updateState: updateState!,
                isTutor: isTutor,
              ),
            )
        ],
      ),
    );
  }

  Widget _userAvatarBuilder() {
    return user.avatar != ""
        ? SizedBox(
            height: 150,
            width: 150,
            child: CachedNetworkImage(
              imageUrl: user.avatar,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.green,
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 100,
                  ),
                ),
              ),
            ),
          )
        : Container(
            color: Colors.green,
            child: const Center(
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 100,
              ),
            ),
          );
  }

  Widget _badgeBuilder(
    bool isTutor,
  ) {
    return isTutor
        ? Positioned(
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
          )
        : const SizedBox();
  }
}
