import 'package:flutter/material.dart';
import 'package:project_lift/constants/styles.dart';
import 'package:project_lift/features/study_pool/widgets/study_card_widget.dart';

import '../../../widgets/app_text.dart';

class StudyPoolScreen extends StatelessWidget {
  const StudyPoolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Pool'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
        backgroundColor: primaryColor,
      ),
      body: ListView.separated(
        itemBuilder: (context, index) => const StudyPoolCard(),
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemCount: 10,
      ),
    );
  }
}
