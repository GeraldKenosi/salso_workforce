import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'microsoft_auth_service.dart';

class SharePointUploadResult {
  final String webUrl;
  final String itemId;

  SharePointUploadResult({
    required this.webUrl,
    required this.itemId,
  });
}

class SharePointUploadService {
  static const String _graphBase = 'https://graph.microsoft.com/v1.0';
  static const String _hostname = 'salsoza.sharepoint.com';
  static const String _sitePath = '/sites/salso-workforce-hub';
  static const String _libraryName = 'Documents';

  final MicrosoftAuthService _auth;

  SharePointUploadService(this._auth);

  // ✅ Method name matches UploadDocumentPage expectation
  Future<SharePointUploadResult> uploadToDocumentsLibrary({
    required String sharePointPath,
    required Uint8List bytes,
  }) async {
    final token = await _auth.getAccessToken();

    final siteId = await _getSiteId(token);
    final driveId = await _getDocumentsDriveId(token, siteId);

    final parts = _splitPath(sharePointPath);
    await _ensureFolders(token, driveId, parts.folderPath);

    final item = await _uploadFile(
      token: token,
      driveId: driveId,
      folderPath: parts.folderPath,
      fileName: parts.fileName,
      bytes: bytes,
    );

    return SharePointUploadResult(
      webUrl: (item['webUrl'] ?? '').toString(),
      itemId: (item['id'] ?? '').toString(),
    );
  }

  Future<String> _getSiteId(String token) async {
    final url = Uri.parse('$_graphBase/sites/$_hostname:/${_sitePath.substring(1)}');
    final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (res.statusCode != 200) {
      throw Exception('Failed to get siteId: ${res.statusCode} ${res.body}');
    }

    return (jsonDecode(res.body) as Map<String, dynamic>)['id'].toString();
  }

  Future<String> _getDocumentsDriveId(String token, String siteId) async {
    final url = Uri.parse('$_graphBase/sites/$siteId/drives');
    final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (res.statusCode != 200) {
      throw Exception('Failed to list drives: ${res.statusCode} ${res.body}');
    }

    final drives = (jsonDecode(res.body) as Map<String, dynamic>)['value'] as List<dynamic>;
    for (final d in drives) {
      final m = d as Map<String, dynamic>;
      final name = (m['name'] ?? '').toString();
      if (name.toLowerCase() == _libraryName.toLowerCase()) {
        return (m['id'] ?? '').toString();
      }
    }

    throw Exception('Documents library not found');
  }

  Future<void> _ensureFolders(String token, String driveId, String folderPath) async {
    final segments = folderPath.split('/').where((e) => e.trim().isNotEmpty).toList();
    String current = '';

    for (final seg in segments) {
      current = current.isEmpty ? seg : '$current/$seg';
      final exists = await _exists(token, driveId, current);
      if (!exists) {
        await _createFolder(token, driveId, current);
      }
    }
  }

  Future<bool> _exists(String token, String driveId, String path) async {
    final safe = Uri.encodeComponent(path).replaceAll('%2F', '/');
    final url = Uri.parse('$_graphBase/drives/$driveId/root:/$safe');

    final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (res.statusCode == 200) return true;
    if (res.statusCode == 404) return false;

    throw Exception('Folder check failed ($path): ${res.statusCode} ${res.body}');
  }

  Future<void> _createFolder(String token, String driveId, String path) async {
    final parent = path.contains('/') ? path.substring(0, path.lastIndexOf('/')) : '';
    final name = path.split('/').last;

    final endpoint = parent.isEmpty
        ? '$_graphBase/drives/$driveId/root/children'
        : '$_graphBase/drives/$driveId/root:/$parent:/children';

    final res = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'folder': {},
        '@microsoft.graph.conflictBehavior': 'fail',
      }),
    );

    if (res.statusCode != 201 && res.statusCode != 409) {
      throw Exception('Create folder failed ($path): ${res.statusCode} ${res.body}');
    }
  }

  Future<Map<String, dynamic>> _uploadFile({
    required String token,
    required String driveId,
    required String folderPath,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final safeFolder = Uri.encodeComponent(folderPath).replaceAll('%2F', '/');
    final safeFile = Uri.encodeComponent(fileName);

    final sessionUrl = Uri.parse(
      '$_graphBase/drives/$driveId/root:/$safeFolder/$safeFile:/createUploadSession',
    );

    final sessionRes = await http.post(
      sessionUrl,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'item': {'@microsoft.graph.conflictBehavior': 'replace'}
      }),
    );

    if (sessionRes.statusCode < 200 || sessionRes.statusCode >= 300) {
      throw Exception('CreateUploadSession failed: ${sessionRes.statusCode} ${sessionRes.body}');
    }

    final uploadUrl =
        (jsonDecode(sessionRes.body) as Map<String, dynamic>)['uploadUrl'].toString();

    final putRes = await http.put(
      Uri.parse(uploadUrl),
      headers: {
        'Content-Length': bytes.length.toString(),
        'Content-Range': 'bytes 0-${bytes.length - 1}/${bytes.length}',
      },
      body: bytes,
    );

    if (putRes.statusCode != 200 && putRes.statusCode != 201) {
      throw Exception('Upload failed: ${putRes.statusCode} ${putRes.body}');
    }

    return jsonDecode(putRes.body) as Map<String, dynamic>;
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