import 'package:flutter/material.dart';
import 'package:project_lift/widgets/app_text.dart';

import '../../../constants/styles.dart';

class FindTutorScreen extends StatefulWidget {
  const FindTutorScreen({super.key});

  @override
  State<FindTutorScreen> createState() => _FindTutorScreenState();
}

class _FindTutorScreenState extends State<FindTutorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          expandedHeight: 240,
          flexibleSpace: FlexibleSpaceBar(
            title: AppText(text: 'Find a Tutor'),
            background: Container(color: primaryColor),
          ),
          floating: true,
          snap: true,
        ),
      ],
      body: ListView.separated(
        itemBuilder: (context, index) => ListTile(
          title: Text('Item $index'),
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemCount: 30,
      ),
    ));
  }
}
