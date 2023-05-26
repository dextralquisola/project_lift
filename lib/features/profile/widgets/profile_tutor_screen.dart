import 'package:flutter/material.dart';

import '../../../constants/styles.dart';
import '../../../models/user.dart';
import '../../../widgets/app_text.dart';
import '../screens/add_subject_screen.dart';

class TutorScreen extends StatelessWidget {
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
                          builder: (context) => const AddSubjectScreen(),
                        ),
                      );
                      updateState();
                    },
                    icon: Icon(Icons.add, color: primaryColor),
                  ),
                  AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: animationController,
                  ),
                ],
              ),
              children: [
                if (user.subjects.isEmpty)
                  ListTile(
                    title: AppText(text: "No subjects yet"),
                  ),
                ...user.subjects.map((e) {
                  return ListTile(
                      title: AppText(text: e.subjectCode),
                      subtitle: AppText(text: e.description),
                      trailing: IconButton(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddSubjectScreen(
                                subject: e,
                              ),
                            ),
                          );
                          updateState();
                        },
                        icon: const Icon(Icons.edit, color: Colors.green),
                      ));
                }).toList(),
              ],
              onExpansionChanged: (value) {
                if (value) {
                  animationController.forward();
                } else {
                  animationController.reverse();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
