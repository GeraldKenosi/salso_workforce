import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class FileUploadService {
  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  FileUploadService(this._storage);

  Future<String> uploadFile({
    required Uint8List bytes,
    required String folder,
    required String fileName,
    String contentType = 'image/jpeg',
  }) async {
    final path = '$folder/$fileName';
    final ref = _storage.ref().child(path);
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    return await ref.getDownloadURL();
  }

  Future<String> uploadFileWithUid({
    required Uint8List bytes,
    required String userId,
    required String subfolder,
    String? extension,
    String contentType = 'image/jpeg',
  }) async {
    final ext = extension ?? 'jpg';
    final name = '${_uuid.v4()}.$ext';
    final path = 'uploads/$userId/$subfolder/$name';
    return uploadFile(bytes: bytes, folder: 'uploads/$userId/$subfolder', fileName: name, contentType: contentType);
  }

  Future<List<String>> uploadMultipleFiles({
    required List<Uint8List> files,
    required String userId,
    required String subfolder,
    String contentType = 'image/jpeg',
  }) async {
    final urls = <String>[];
    for (final bytes in files) {
      final url = await uploadFileWithUid(bytes: bytes, userId: userId, subfolder: subfolder, contentType: contentType);
      urls.add(url);
    }
    return urls;
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {}
  }
}
