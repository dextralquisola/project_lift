import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import './tutorial_screen.dart';

import '../../../constants/styles.dart';
import '../../../utils/utils.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text.dart';

import '../service/profile_service.dart';
import '../widgets/preview_image_screen.dart';
import '../widgets/profile_widgets.dart';

class AddSubjectScreenV2 extends StatefulWidget {
  const AddSubjectScreenV2({super.key});

  @override
  State<AddSubjectScreenV2> createState() => _AddSubjectScreenV2State();
}

class _AddSubjectScreenV2State extends State<AddSubjectScreenV2> {
  final profileService = ProfileService();
  final imagePicker = ImagePicker();
  XFile? selectedImage;

  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isLoading) {
          return await showCancelApplyDialog(context);
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Subject'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const TutorialScreen(isViewOnly: true),
                  ),
                );
              },
              icon: const Icon(Icons.help_outline),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                  text: "Add subject by uploading grades", textSize: 20),
              const SizedBox(height: 5),
              Row(
                children: [
                  const AppText(
                      text: "Select grade (from CvSU student portal)"),
                  PopupMenuButton(
                    icon: const Icon(Icons.info_outline, color: Colors.amber),
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: 0,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: AppText(
                              text:
                                  "The subject within your grades will be added automatically if the grades is atleast 1.75",
                              textColor: Colors.black,
                            ),
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
              TextButton(
                onPressed: () async {
                  XFile? pickedImage =
                      await imagePicker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    selectedImage = pickedImage;
                  });
                },
                child: AppText(
                  text: "Pick image",
                  textColor: primaryColor,
                ),
              ),
              selectedImage != null
                  ? GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return PrevieImageScreen(
                                imageFile: selectedImage,
                              );
                            },
                          ),
                        );
                      },
                      child: SizedBox(
                        height: 200,
                        child: Image.file(
                          File(selectedImage!.path),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    )
                  : const SizedBox(
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
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : AppButton(
                      wrapRow: true,
                      height: 50,
                      onPressed: () async {
                        if (selectedImage == null) {
                          showSnackBar(
                              context, "Please select an image first.");
                        }

                        setState(() {
                          _isLoading = true;
                        });

                        await profileService.addSubjectV2(
                          context: context,
                          image: selectedImage!,
                        );
                        setState(() {
                          _isLoading = false;
                        });
                        Navigator.of(context).pop();
                      },
                      text: "Submit",
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
