import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadBytes({
    required String path,
    required Uint8List bytes,
  }) async {
    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putData(bytes);
    return uploadTask.ref.getDownloadURL();
  }
}
