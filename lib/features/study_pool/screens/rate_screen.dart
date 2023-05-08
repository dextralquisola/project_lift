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
  const RateScreen({super.key});

  @override
  State<RateScreen> createState() => _RateScreenState();
}

class _RateScreenState extends State<RateScreen> {
  int _rating = 0;
  String rateText = '';

  var _isLoading = false;

  final feedback = TextEditingController();

  final studyRoomService = StudyPoolService();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentStudyRoom = Provider.of<CurrentStudyRoomProvider>(context);

    final user = userProvider.user;
    final studyRoom = currentStudyRoom.studyRoom;

    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: AppText(
          text: user.userId == studyRoom.roomOwner
              ? 'Rate Tutees'
              : 'Rate Tutor',
          textColor: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: _contentBuilder(
          feedback,
          size,
          user,
          studyRoom,
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
              text: user.userId == studyRoom.roomOwner
                  ? "Rate your participant's performance"
                  : "Rate your tutor's performance",
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

                        var isSuccess = await studyRoomService.rateUsers(
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
