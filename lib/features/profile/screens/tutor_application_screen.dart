import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_lift/widgets/app_button.dart';
import 'package:project_lift/widgets/app_textfield.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_requests_provider.dart';
import '../../../widgets/app_text.dart';
import '../service/profile_service.dart';

class TutotApplicationScreen extends StatefulWidget {
  const TutotApplicationScreen({super.key});

  @override
  State<TutotApplicationScreen> createState() => _TutotApplicationScreenState();
}

class _TutotApplicationScreenState extends State<TutotApplicationScreen> {
  final profileService = ProfileService();

  final briefIntroController = TextEditingController();
  final teachingExperienceController = TextEditingController();
  final imagePicker = ImagePicker();
  XFile? selectedImage;

  var _isLoading = false;
  var _isEnabledForEditing = true;
  var _isEdit = false;

  @override
  Widget build(BuildContext context) {
    final userRequestProvider = Provider.of<UserRequestsProvider>(context);
    final tutorApplication = userRequestProvider.tutorApplication;
    final hasTutorApplication = tutorApplication.id.isNotEmpty;

    if (hasTutorApplication && _isEnabledForEditing) {
      _isEnabledForEditing = false;
      briefIntroController.text = tutorApplication.briefIntro;
      teachingExperienceController.text = tutorApplication.teachingExperience;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutor Application'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AppText(
                      text:
                          "Hi! 👋 If you have submitted previous application and now its gone, it means that your application has been rejected.",
                      textColor: Colors.black,
                    ),
                  ),
                ),
              ];
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  if (hasTutorApplication)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppText(
                        text: "Status: ${tutorApplication.status}",
                        textSize: 20,
                        textColor: Colors.amber,
                      ),
                    ),
                  const SizedBox(height: 10),
                  AppTextField(
                    hintText: 'e.g I am a 2nd year college student in CvSU',
                    labelText: "Brief Introduction",
                    controller: briefIntroController,
                    isEnabled: _isEnabledForEditing || _isEdit,
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    hintText: 'e.g I have been teaching for 2 years',
                    labelText: "Teaching Experience",
                    maxLines: 3,
                    controller: teachingExperienceController,
                    isEnabled: _isEnabledForEditing || _isEdit,
                  ),
                  const SizedBox(height: 10),
                  if (_isEnabledForEditing || _isEdit)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        children: [
                          AppText(
                            textSize: 20,
                            text: "Select Grade",
                          ),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: () async {
                              var pickedImage = await imagePicker.pickImage(
                                  source: ImageSource.gallery);
                              setState(() {
                                selectedImage = pickedImage!;
                              });
                            },
                            child: const Text("Pick image"),
                          )
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  if (selectedImage != null || hasTutorApplication)
                    Column(
                      children: [
                        AppText(text: "Preview", textSize: 20),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 150,
                          width: 150,
                          child: (_isEdit || _isEnabledForEditing) &&
                                  selectedImage != null
                              ? Image.file(
                                  File(selectedImage!.path),
                                )
                              : CachedNetworkImage(
                                  imageUrl: tutorApplication.grades,
                                  fit: BoxFit.cover,
                                  progressIndicatorBuilder:
                                      (context, url, progress) {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: progress.progress,
                                      ),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                ],
              ),
              if (!_isEnabledForEditing && !_isEdit)
                AppButton(
                  height: 50,
                  wrapRow: true,
                  onPressed: () {
                    setState(() {
                      _isEdit = true;
                    });
                    print("pressed!");
                    print(_isEnabledForEditing);
                  },
                  text: "Edit Applicaton",
                ),
              if (hasTutorApplication && _isEdit)
                Container(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : AppButton(
                          height: 50,
                          wrapRow: true,
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            await profileService.updateTutorApplication(
                              context: context,
                              gradePath: selectedImage != null
                                  ? selectedImage!.path
                                  : tutorApplication.grades,
                              briefIntro: briefIntroController.text,
                              teachingExperience:
                                  teachingExperienceController.text,
                            );
                            setState(() {
                              _isLoading = false;
                            });
                            Navigator.pop(context);
                          },
                          text: "Update Application",
                        ),
                ),
              if (_isEnabledForEditing && !hasTutorApplication)
                Container(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : AppButton(
                          height: 50,
                          wrapRow: true,
                          onPressed: () async {
                            if (validateForm()) {
                              setState(() {
                                _isLoading = true;
                              });
      
                              await profileService.submitTutorApplication(
                                context: context,
                                gradePath: selectedImage!.path,
                                briefIntro: briefIntroController.text,
                                teachingExperience:
                                    teachingExperienceController.text,
                              );
      
                              setState(() {
                                _isLoading = false;
                              });
      
                              Navigator.pop(context);
                            }
                          },
                          text: "Submit",
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool validateForm() {
    if (briefIntroController.text.isEmpty) {
      return false;
    }
    if (teachingExperienceController.text.isEmpty) {
      return false;
    }
    if (selectedImage == null) {
      return false;
    }
    return true;
  }
}
