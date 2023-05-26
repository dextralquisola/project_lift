import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../features/profile/screens/edit_availability_screen.dart';
import '../../features/profile/screens/profile_edit_screen.dart';
import '../../features/profile/screens/select_avatar_screen.dart';

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
                      right: -0,
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
          Positioned(
            top: 0,
            right: 0,
            child: Row(
              children: [
                IconButton(
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    // TODO: implement logout
                    //! await logoutDialog(context, userProvider);
                  },
                  icon: const Icon(Icons.exit_to_app, color: Colors.white),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.edit, color: Colors.green),
                            const SizedBox(width: 5),
                            AppText(
                              text: "Edit profile details",
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.edit, color: Colors.green),
                            const SizedBox(width: 5),
                            AppText(
                              text: "Change avatar",
                            ),
                          ],
                        ),
                      ),
                      if (isTutor)
                        PopupMenuItem(
                          value: 2,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.edit, color: Colors.green),
                              const SizedBox(width: 5),
                              AppText(
                                text: "Change schedule/availability",
                                textSize: 12,
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
                          builder: (context) => const ProfileEditScreen(),
                        ),
                      );
                      updateState!();
                    } else if (value == 1) {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SelectAvatarScreen(),
                        ),
                      );
                      updateState!();
                    } else if (value == 2) {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const EditAvailabilityScreen(),
                        ),
                      );
                      updateState!();
                    }
                  },
                ),
              ],
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
