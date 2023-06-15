import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../profile/service/profile_service.dart';
import '../../../providers/user_requests_provider.dart';
import '../../../widgets/background_cover.dart';
import '../../../widgets/app_text.dart';
import '../../../providers/current_room_provider.dart';
import '../../../providers/tutors_provider.dart';
import '../service/tutor_service.dart';
import '../widgets/tutor_card_widget.dart';
import '../widgets/no_tutor_widget.dart';
import '../widgets/search_widget.dart';

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

  final tutorService = TutorService();
  final profileService = ProfileService();

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
    final currentRoomProvider = Provider.of<CurrentStudyRoomProvider>(context);
    final userRequestsProvider = Provider.of<UserRequestsProvider>(context);
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
                      ? const AppText(
                          text: "Find your tutor",
                          textColor: Colors.white,
                          textSize: 24,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
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
                    children: const [BackgroundCover(), SearchBar()],
                  ),
                );
              }),
            ),
          ],
          body: tutors.isEmpty
              ? NoTutorWidget()
              : RefreshIndicator(
                  onRefresh: () async {
                    Future.wait([
                      tutorService.fetchTutors(context, true),
                      profileService.getMostSearchedTutorAndSubject(
                          context: context)
                    ]);
                  },
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      var isPendingRequest = userRequestsProvider
                          .isHasRequest(tutors[index].userId);
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
                            TutorCard(
                                tutor: tutors[index],
                                isPendingRequest: isPendingRequest,
                                isEnabled: currentRoomProvider.isEmpty)
                          ],
                        );
                      }

                      return TutorCard(
                          tutor: tutors[index],
                          isPendingRequest: isPendingRequest,
                          isEnabled: currentRoomProvider.isEmpty);
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemCount: tutors.length,
                  ),
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
