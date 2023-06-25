import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageMethods {
  Future<String> uploadFile({
    required String filePath,
    required String fileName,
  }) async {
    final ref = FirebaseStorage.instance.ref().child(fileName);

    UploadTask uploadTask = ref.putFile(File(filePath));

    TaskSnapshot snap = await uploadTask;
    String fileUrl = await snap.ref.getDownloadURL();

    return fileUrl;
  }
}
