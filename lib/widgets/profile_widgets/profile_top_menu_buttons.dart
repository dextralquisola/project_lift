import 'package:flutter/material.dart';

import '../../features/profile/screens/edit_availability_screen.dart';
import '../../features/profile/screens/profile_edit_screen.dart';
import '../../features/profile/screens/select_avatar_screen.dart';
import '../../features/profile/widgets/profile_widgets.dart';
import '../app_text.dart';

class ProfileTopMenuButtons extends StatelessWidget {
  final VoidCallback updateState;
  final bool isTutor;
  const ProfileTopMenuButtons({
    super.key,
    required this.updateState,
    required this.isTutor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          constraints: const BoxConstraints(),
          onPressed: () async {
            await logoutDialog(context);
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
                  children: const [
                    Icon(Icons.edit, color: Colors.green),
                    SizedBox(width: 5),
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
                  children: const [
                    Icon(Icons.edit, color: Colors.green),
                    SizedBox(width: 5),
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
                    children: const [
                      Icon(Icons.edit, color: Colors.green),
                      SizedBox(width: 5),
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
              updateState();
            } else if (value == 1) {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SelectAvatarScreen(),
                ),
              );
              updateState();
            } else if (value == 2) {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EditAvailabilityScreen(),
                ),
              );
              updateState();
            }
          },
        ),
      ],
    );
  }
}
