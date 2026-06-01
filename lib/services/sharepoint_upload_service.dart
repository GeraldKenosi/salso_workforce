import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import 'api_config.dart';

class SharePointUploadResult {
  final String webUrl;
  final String itemId;

  SharePointUploadResult({
    required this.webUrl,
    required this.itemId,
  });
}

class SharePointUploadService {
  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  SharePointUploadService(this._storage);

  Future<SharePointUploadResult> uploadToDocumentsLibrary({
    required String sharePointPath,
    required Uint8List bytes,
  }) async {
    final parts = _splitPath(sharePointPath);
    final fileName = parts.fileName;
    final storagePath = 'sharepoint-transfers/${_uuid.v4()}/$fileName';

    final ref = _storage.ref().child(storagePath);
    await ref.putData(bytes, SettableMetadata(contentType: 'application/octet-stream'));
    await ref.getDownloadURL();

    final resp = await http.post(
      Uri.parse(ApiConfig.fileTransferSharePoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'storagePath': storagePath,
        'sharePointPath': sharePointPath,
        'fileName': fileName,
      }),
    ).timeout(const Duration(minutes: 5));

    if (resp.statusCode != 200) {
      final body = resp.body;
      throw Exception('Server upload failed: ${resp.statusCode} $body');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final sharePointUrl = (data['sharePointUrl'] ?? '').toString();

    return SharePointUploadResult(
      webUrl: sharePointUrl.isNotEmpty ? sharePointUrl : 'Uploaded to SharePoint',
      itemId: '',
    );
  }

  _PathParts _splitPath(String path) {
    final parts = path.split('/').where((e) => e.isNotEmpty).toList();
    if (parts.length < 2) throw Exception('Invalid sharePointPath: $path');
    return _PathParts(
      folderPath: parts.sublist(0, parts.length - 1).join('/'),
      fileName: parts.last,
    );
  }
}

class _PathParts {
  final String folderPath;
  final String fileName;

  _PathParts({required this.folderPath, required this.fileName});
}
