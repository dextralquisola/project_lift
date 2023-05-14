import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_lift/widgets/app_button.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';
import '../../../utils/storage_utils.dart';
import '../service/profile_service.dart';

class SelectAvatarScreen extends StatefulWidget {
  const SelectAvatarScreen({super.key});

  @override
  State<SelectAvatarScreen> createState() => _SelectAvatarScreenState();
}

class _SelectAvatarScreenState extends State<SelectAvatarScreen> {
  final storageMethods = StorageMethods();
  final profileService = ProfileService();

  final imagePicker = ImagePicker();
  XFile? selectedImage;

  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Avatar'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 100,
        ),
        child: Column(
          children: [
            Expanded(
              child: user.avatar.isNotEmpty && selectedImage == null
                  ? CachedNetworkImage(
                      imageUrl: user.avatar,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Center(
                        child: CircularProgressIndicator(
                          value: downloadProgress.progress,
                        ),
                      ),
                    )
                  : Card(
                      child: selectedImage == null
                          ? const Placeholder()
                          : Image.file(
                              File(selectedImage!.path),
                            ),
                    ),
            ),
            const SizedBox(height: 20),
            if (selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppButton(
                  wrapRow: true,
                  height: 50,
                  onPressed: () => setState(() => selectedImage = null),
                  bgColor: Colors.redAccent,
                  text: "Clear Image",
                ),
              ),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : AppButton(
                    wrapRow: true,
                    height: 50,
                    onPressed: selectedImage == null
                        ? () async {
                            var selectImage = await imagePicker.pickImage(
                              source: ImageSource.gallery,
                            );
                            setState(() {
                              selectedImage = selectImage;
                            });
                          }
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });
                            await profileService.uploadAvatar(
                              context: context,
                              avatarPath: selectedImage!.path,
                            );
                            setState(() {
                              _isLoading = false;
                            });
                            Navigator.of(context).pop();
                          },
                    text: selectedImage != null ? "Save" : "Select Image",
                  ),
          ],
        ),
      ),
    );
  }
}
