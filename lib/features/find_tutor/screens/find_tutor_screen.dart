import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_lift/features/find_tutor/widgets/background_cover.dart';
import 'package:project_lift/widgets/app_text.dart';

import '../widgets/tutor_card_widget.dart';

class FindTutorScreen extends StatefulWidget {
  const FindTutorScreen({super.key});

  @override
  State<FindTutorScreen> createState() => _FindTutorScreenState();
}

class _FindTutorScreenState extends State<FindTutorScreen> {
  // spacing for title should be 26% of the biggest height of appbar
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 240,
              floating: true,
              snap: true,
              pinned: true,
              flexibleSpace: LayoutBuilder(builder: (context, constraints) {
                var top = constraints.biggest.height;
                return FlexibleSpaceBar(
                  title: top ==
                              MediaQuery.of(context).padding.top +
                                  kToolbarHeight ||
                          constraints.biggest.height > 56 &&
                              constraints.biggest.height <= 76
                      ? AppText(
                          text: "Find your tutor",
                          textColor: Colors.white,
                          textSize: 24,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AppText(
                                text: 'Find your',
                                textColor: Colors.white,
                                textSize: 24),
                            AppText(
                              text: 'Kabsuhenyos Tutor',
                              textColor: Colors.white,
                              textSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                  titlePadding: const EdgeInsets.only(left: 10.0, bottom: 16.0),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      const BackgroundCover(),
                      Column(
                        children: [
                          const SizedBox(height: 10.0),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                16.0, 6.0, 16.0, 16.0),
                            child: SizedBox(
                              height: 36.0,
                              width: double.infinity,
                              child: CupertinoTextField(
                                keyboardType: TextInputType.text,
                                placeholder: 'Search for a tutor',
                                placeholderStyle: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14.0,
                                  fontFamily: 'Brutal',
                                ),
                                prefix: const Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(9.0, 6.0, 9.0, 6.0),
                                  child: Icon(
                                    Icons.search,
                                    color: Colors.black54,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
          body: ListView.separated(
            itemBuilder: (context, index) => const TutorCard(),
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemCount: 30,
          ),
        ),
      ),
    );
  }
}
