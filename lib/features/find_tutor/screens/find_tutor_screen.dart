import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_lift/features/find_tutor/screens/find_tutor_search_screen.dart';
import 'package:project_lift/widgets/background_cover.dart';
import 'package:project_lift/widgets/app_text.dart';
import 'package:provider/provider.dart';

import '../../../providers/tutors_provider.dart';
import '../service/tutor_service.dart';
import '../widgets/tutor_card_widget.dart';

class FindTutorScreen extends StatefulWidget {
  const FindTutorScreen({super.key});

  @override
  State<FindTutorScreen> createState() => _FindTutorScreenState();
}

class _FindTutorScreenState extends State<FindTutorScreen>
    with SingleTickerProviderStateMixin {
  // spacing for title should be 26% of the biggest height of appbar
  var _scrollControllerTutors = ScrollController();
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween(begin: 1, end: 0).animate(_animationController);
    _scrollControllerTutors = ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListenerTutors);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollControllerTutors.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tutorsProvider = Provider.of<TutorProvider>(context);
    final tutors = tutorsProvider.tutors;
    return SafeArea(
      child: Scaffold(
        body: NestedScrollView(
          controller: _scrollControllerTutors,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 240,
              floating: true,
              snap: true,
              pinned: true,
              flexibleSpace: LayoutBuilder(builder: (context, constraints) {
                var top = constraints.biggest.height;
                if (constraints.biggest.height == 56) {
                  _animationController.reverse();
                } else if (constraints.biggest.height > 76) {
                  _animationController.forward();
                }
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
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
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
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const FindTutorSearchScreen(),
                                    ),
                                  );
                                },
                                readOnly: true,
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
          body: tutors.isEmpty
              ? Center(
                  child: AppText(text: "There is no tutor available."),
                )
              : ListView.separated(
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: FadeTransition(
                              opacity: _animationController,
                              child: const SizedBox(
                                height: 75,
                                child: BackgroundCover(isBottomBg: true),
                              ),
                            ),
                          ),
                          if (tutors[index].subjects.isNotEmpty)
                            TutorCard(tutor: tutors[index])
                        ],
                      );
                    }
                    return TutorCard(tutor: tutors[index]);
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemCount: tutors.length,
                ),
        ),
      ),
    );
  }

  _scrollListenerTutors() async {
    if (_scrollControllerTutors.offset >=
            _scrollControllerTutors.position.maxScrollExtent &&
        !_scrollControllerTutors.position.outOfRange) {
      setState(() {
        _isLoading = true;
      });

      if (_isLoading) {
        //call fetch tutors
        await TutorService().fetchTutors(context);
      }

      setState(() {
        _isLoading = false;
      });
    }
  }
}
