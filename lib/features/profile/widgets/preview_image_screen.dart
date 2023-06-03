import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PrevieImageScreen extends StatelessWidget {
  final String imageUrl;
  final XFile? imageFile;
  const PrevieImageScreen({
    super.key,
    this.imageUrl = "",
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Image'),
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: SizedBox(
          child: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: imageFile != null
                ? FileImage(File(imageFile!.path))
                : Image.network(imageUrl).image,
            initialScale: PhotoViewComputedScale.contained * 0.8,
          );
        },
        itemCount: 1,
        loadingBuilder: (context, event) => const Center(
          child: SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(),
          ),
        ),
      )),
    );
  }
}
