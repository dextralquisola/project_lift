import 'package:flutter/material.dart';
import 'package:project_lift/features/study_pool/service/study_pool_service.dart';
import 'package:project_lift/widgets/app_button.dart';
import 'package:project_lift/widgets/app_text.dart';
import 'package:project_lift/widgets/app_textfield.dart';
import '../../../constants/constants.dart';
import '../../../constants/styles.dart';

class CreateStudyRoomScreen extends StatefulWidget {
  CreateStudyRoomScreen({super.key});

  @override
  State<CreateStudyRoomScreen> createState() => _CreateStudyRoomScreenState();
}

class _CreateStudyRoomScreenState extends State<CreateStudyRoomScreen> {
  final studyPoolService = StudyPoolService();
  final studyNameController = TextEditingController();
  var studyRoomStatus = StudyRoomStatus.public;
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Study Room'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppTextField(
              controller: studyNameController,
              labelText: "Study Room Name",
            ),
            const SizedBox(height: 10),
            RadioListTile(
              title: AppText(text: "Public"),
              value: StudyRoomStatus.public,
              groupValue: studyRoomStatus,
              onChanged: (value) {
                setState(() {
                  studyRoomStatus = value!;
                });
              },
            ),
            RadioListTile(
              title: AppText(text: "Private"),
              value: StudyRoomStatus.private,
              groupValue: studyRoomStatus,
              onChanged: (value) {
                setState(() {
                  studyRoomStatus = value!;
                });
              },
            ),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : AppButton(
                    wrapRow: true,
                    height: 50,
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      await studyPoolService.createStudyPool(
                        context: context,
                        studyPoolName: studyNameController.text,
                        status: studyRoomStatus,
                      );
                      setState(() => _isLoading = false);
                      Navigator.of(context).pop();
                    },
                    text: "Create Study Room",
                  )
          ],
        ),
      ),
    );
  }
}
