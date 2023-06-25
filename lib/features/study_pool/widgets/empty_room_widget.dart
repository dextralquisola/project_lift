import 'package:flutter/material.dart';

import '../../../widgets/app_text.dart';

class EmptyMsgWidget extends StatelessWidget {
  const EmptyMsgWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Align(
        alignment: Alignment.center,
        child: AppText(
          text: "Send hello to get started! 😊",
          textSize: 20,
        ),
      ),
    );
  }
}
