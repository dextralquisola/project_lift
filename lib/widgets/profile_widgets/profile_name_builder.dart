import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../app_text.dart';

class NameBuilder extends StatelessWidget {
  final User user;
  const NameBuilder({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 80),
        AppText(
          text: "${user.firstName} ${user.lastName}",
          textSize: 24,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 5),
        AppText(
          text: user.email,
          textColor: Colors.grey,
          textSize: 14,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
