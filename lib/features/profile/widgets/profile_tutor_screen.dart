import 'package:flutter/material.dart';
import 'package:project_lift/features/profile/screens/add_subject_screen_v2.dart';
import 'package:project_lift/features/profile/service/profile_service.dart';

import '../../../constants/styles.dart';
import '../../../models/user.dart';
import '../../../widgets/app_text.dart';
import '../screens/add_subject_screen.dart';

class TutorScreen extends StatefulWidget {
  final User user;
  final AnimationController animationController;
  final VoidCallback updateState;
  const TutorScreen({
    super.key,
    required this.animationController,
    required this.updateState,
    required this.user,
  });

  @override
  State<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> {
  final profileService = ProfileService();
  @override
  Widget build(BuildContext context) {
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
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddSubjectScreenV2(),
                        ),
                      );
                      if (context.mounted) {
                        await profileService.fetchUser(context);
                        widget.updateState();
                      }
                    },
                    icon: Icon(Icons.add, color: primaryColor),
                  ),
                  AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: widget.animationController,
                  ),
                ],
              ),
              children: [
                if (widget.user.subjects.isEmpty)
                  ListTile(
                    title: AppText(text: "No subjects yet"),
                  ),
                ...widget.user.subjects.map((e) {
                  return ListTile(
                      title: AppText(text: e.subjectCode),
                      subtitle: AppText(
                        text: e.description,
                        textOverflow: TextOverflow.ellipsis,
                        textSize: 12,
                      ),
                      trailing: IconButton(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddSubjectScreen(
                                subject: e,
                              ),
                            ),
                          );
                          widget.updateState();
                        },
                        icon: const Icon(Icons.edit, color: Colors.green),
                      ));
                }).toList(),
              ],
              onExpansionChanged: (value) {
                if (value) {
                  widget.animationController.forward();
                } else {
                  widget.animationController.reverse();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
