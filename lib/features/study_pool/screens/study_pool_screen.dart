import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:project_lift/constants/styles.dart';
import 'package:project_lift/features/study_pool/widgets/study_card_widget.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';

class StudyPoolScreen extends StatelessWidget {
  const StudyPoolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
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
      floatingActionButton: userProvider.isTutor
          ? SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              animatedIconTheme: const IconThemeData(size: 22.0),
              backgroundColor: primaryColor,
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.add),
                  label: 'Create Study Room',
                  onTap: () {},
                ),
                SpeedDialChild(
                  child: const Icon(Icons.list),
                  label: 'Tutee Requests',
                  onTap: () {},
                ),
              ],
            )
          : null,
    );
  }
}
