import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:project_lift/features/study_pool/service/study_pool_service.dart';
import 'package:project_lift/utils/utils.dart';
import 'package:project_lift/widgets/app_button.dart';
import 'package:project_lift/widgets/app_text.dart';
import 'package:project_lift/widgets/app_textfield.dart';
import 'package:provider/provider.dart';

import '../../../models/study_room.dart';
import '../../../models/user.dart';
import '../../../providers/current_room_provider.dart';
import '../../../providers/user_provider.dart';

class RateScreen extends StatefulWidget {
  final String? resBody;
  const RateScreen({super.key, required this.resBody});

  @override
  State<RateScreen> createState() => _RateScreenState();
}

class _RateScreenState extends State<RateScreen> {
  int _rating = 0;
  String rateText = '';

  var _isLoading = false;

  final feedback = TextEditingController();
  final studyRoomService = StudyPoolService();

  List<TextEditingController> _feedbackControllers = [];
  List<int> ratings = [];

  @override
  void dispose() {
    super.dispose();
    feedback.dispose();
    for (var i = 0; i < _feedbackControllers.length; i++) {
      _feedbackControllers[i].dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentStudyRoom = Provider.of<CurrentStudyRoomProvider>(context);

    final user = userProvider.user;
    final studyRoom = currentStudyRoom.studyRoom;

    List<dynamic> toRateParticipants = [];
    if (widget.resBody != null) {
      toRateParticipants = json.decode(widget.resBody!)['ratedParticipants'];
    }

    final size = MediaQuery.of(context).size;

    if (user.userId == studyRoom.roomOwner && widget.resBody != null) {
      print("toRateParticipants.length ${toRateParticipants.length}");
      for (var i = 0; i < toRateParticipants.length; i++) {
        _feedbackControllers.add(TextEditingController());
        ratings.add(0);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: AppText(
          text:
              user.userId == studyRoom.roomOwner ? 'Rate Tutees' : 'Rate Tutor',
          textColor: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: user.userId == studyRoom.roomOwner
            ? _contentBuilderForTutor(user, toRateParticipants)
            : _contentBuilder(
                feedback,
                size,
                user,
                studyRoom,
              ),
      ),
    );
  }

  Widget _contentBuilderForTutor(
    User user,
    List<dynamic> participants,
  ) {
    int index = 0;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          ...participants.map(
            (e) {
              final card = _rateParticipantsBuilder(e, index);
              index++;
              return card;
            },
          ).toList(),
          const SizedBox(height: 10),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : AppButton(
                  onPressed: () async {
                    if (validatedParticipantRatings(participants)) {
                      setState(() {
                        _isLoading = true;
                      });

                      var isSuccess = await studyRoomService.rateTutees(
                        context: context,
                        ratings: ratings,
                        feedbackControllers: _feedbackControllers,
                        participants: participants,
                      );

                      setState(() {
                        _isLoading = false;
                      });

                      if (isSuccess) {
                        await studyRoomService.leaveStudyRoom(context);
                      }
                    } else {
                      print("not validated");
                    }
                  },
                  text: "Submit",
                  wrapRow: true,
                  height: 50,
                ),
        ],
      ),
    );
  }

  Widget _rateParticipantsBuilder(Map<String, dynamic> participant, int index) {
    print("rateparticipantsbuilder");
    print(index);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              textSize: 20,
              text:
                  "${index + 1}. ${participant['firstName']} ${participant['lastName']}",
            ),
            const SizedBox(height: 10),
            RatingBar.builder(
              glow: false,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  ratings[index] = rating.toInt();
                });
              },
            ),
            const SizedBox(height: 10),
            AppTextField(
              controller: _feedbackControllers[index],
              labelText: 'Feedback',
              maxLines: 3,
              length: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _contentBuilder(
    TextEditingController feedback,
    Size size,
    User user,
    StudyRoom studyRoom,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        child: Column(
          children: [
            SizedBox(height: size.height * 0.11),
            AppText(
              text: "Rate your tutor's performance",
              textSize: 20,
            ),
            const SizedBox(height: 10),
            RatingBar.builder(
              glow: false,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: _onRatingChanged,
            ),
            const SizedBox(height: 10),
            AppText(
              text: rateText,
              textSize: 20,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: feedback,
                    labelText: 'Feedback',
                    hintText: 'Feedback',
                    maxLines: 5,
                    length: 200,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : AppButton(
                    onPressed: () async {
                      if (validate()) {
                        setState(() {
                          _isLoading = true;
                        });

                        var isSuccess = await studyRoomService.rateTutor(
                          context: context,
                          rating: _rating,
                          feedback: feedback.text,
                        );

                        setState(() {
                          _isLoading = false;
                        });

                        if (isSuccess) {
                          await studyRoomService.leaveStudyRoom(context);
                        }
                      } else {
                        showSnackBar(context, "Please fill up all fields");
                      }
                    },
                    wrapRow: true,
                    height: 50,
                    text: "Submit!",
                  ),
          ],
        ),
      ),
    );
  }

  bool validatedParticipantRatings(List<dynamic> participants) {
    for (var i = 0; i < participants.length; i++) {
      if (ratings[i] == 0 || _feedbackControllers[i].text.isEmpty) {
        return false;
      }
    }
    return true;
  }

  bool validate() {
    if (_rating == 0 || feedback.text.isEmpty) {
      return false;
    }
    return true;
  }

  void _onRatingChanged(double rating) {
    setState(() {
      _rating = rating.toInt();

      switch (_rating) {
        case 1:
          rateText = 'Poor 😥';
          break;
        case 2:
          rateText = 'Fair 🙁';
          break;
        case 3:
          rateText = 'Good 🙂';
          break;
        case 4:
          rateText = 'Very Good 😊';
          break;
        case 5:
          rateText = 'Excellent 😍';
          break;
        default:
          rateText = '';
      }
    });
  }
}
