import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../app_text.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class NameBuilder extends StatelessWidget {
  final User user;
  const NameBuilder({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final formattedName =
        "${user.firstName.split(' ').map((e) => e.capitalize()).join(' ')} ${user.lastName.capitalize()}";
    return Column(
      children: [
        const SizedBox(height: 80),
        AppText(
          text: formattedName,
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
