import 'dart:io';

import 'package:flutter/material.dart';
import 'package:project_lift/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import './tutorial_screen.dart';
import '../../../providers/user_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_textfield.dart';
import '../../../providers/user_requests_provider.dart';
import '../../../widgets/app_text.dart';
import '../service/profile_service.dart';
import '../widgets/preview_image_screen.dart';
import '../widgets/profile_widgets.dart';

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
    final userProvider = Provider.of<UserProvider>(context);
    final userRequestProvider = Provider.of<UserRequestsProvider>(context);
    final tutorApplication = userRequestProvider.tutorApplication;
    final hasTutorApplication = tutorApplication.id.isNotEmpty;

    if (hasTutorApplication && _isEnabledForEditing) {
      _isEnabledForEditing = false;
      briefIntroController.text = tutorApplication.briefIntro;
      teachingExperienceController.text = tutorApplication.teachingExperience;
    }

    return WillPopScope(
      onWillPop: () async {
        if (_isLoading) {
          return await showCancelApplyDialog(context);
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tutor Application'),
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: 0,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
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
                    // if (hasTutorApplication)
                    //   Align(
                    //     alignment: Alignment.centerLeft,
                    //     child: AppButton(
                    //       wrapRow: true,
                    //       height: 50,
                    //       bgColor: Colors.amberAccent,
                    //       textColor: Colors.black,
                    //       onPressed: () {},
                    //       text: "Status: ${tutorApplication.status}",
                    //       textSize: 20,
                    //     ),
                    //   ),
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
                        child: Column(
                          children: [
                            const AppText(
                              textSize: 18,
                              text: "Select grade (from CvSU student portal)",
                              textOverflow: TextOverflow.clip,
                            ),
                            const SizedBox(width: 10),
                            TextButton(
                              onPressed: () async {
                                if (!userProvider.isTutorialDoNotShow) {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TutorialScreen(),
                                    ),
                                  );
                                }
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
                    if (selectedImage == null && !hasTutorApplication) ...[
                      const SizedBox(
                        height: 150,
                        child: Card(
                          child: Center(
                            child: AppText(
                              text: "No image selected",
                              textColor: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (selectedImage != null || hasTutorApplication)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const AppText(text: "Preview", textSize: 18),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PrevieImageScreen(
                                    imageFile: selectedImage,
                                    imageUrl: tutorApplication.grades,
                                  ),
                                ),
                              );
                            },
                            child: SizedBox(
                              height: 150,
                              child: (_isEdit || _isEnabledForEditing) &&
                                      selectedImage != null
                                  ? Image.file(
                                      File(selectedImage!.path),
                                      fit: BoxFit.fitWidth,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: tutorApplication.grades,
                                      fit: BoxFit.fitWidth,
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
                      printLog("pressed!");
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
