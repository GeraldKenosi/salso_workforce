import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class SharePointUploadResult {
  final String webUrl;

  SharePointUploadResult({required this.webUrl});
}

class SharePointUploadService {
  Future<SharePointUploadResult> uploadToDocumentsLibrary({
    required String sharePointPath,
    required Uint8List bytes,
  }) async {
    final parts = _splitPath(sharePointPath);
    final fileName = parts.fileName;

    final resp = await http.post(
      Uri.parse(ApiConfig.fileTransferSharePoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sharePointPath': sharePointPath,
        'fileName': fileName,
        'fileBase64': base64Encode(bytes),
      }),
    ).timeout(const Duration(minutes: 5));

    if (resp.statusCode != 200) {
      throw Exception('Upload failed: ${resp.statusCode} ${resp.body}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return SharePointUploadResult(
      webUrl: (data['sharePointUrl'] ?? '').toString(),
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
