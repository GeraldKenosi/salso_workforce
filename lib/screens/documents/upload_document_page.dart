import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../../services/sharepoint_upload_service.dart';
import '../../services/document_service.dart';
import '../../state/session_provider.dart';
import '../../utils/display_labels.dart';

class UploadDocumentPage extends StatefulWidget {
  const UploadDocumentPage({super.key});

  @override
  State<UploadDocumentPage> createState() => _UploadDocumentPageState();
}

class _UploadDocumentPageState extends State<UploadDocumentPage> {
  String _docType = 'id';
  PlatformFile? _file;
  bool _working = false;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final uploader = context.read<SharePointUploadService>();
    final docs = context.read<DocumentService>();

    final fullName = (session.profile?.fullName ?? '').trim();
    final email = (session.profile?.email ?? '').trim();
    final uid = session.firebaseUser?.uid ?? '';

    final department = DisplayLabels.departmentLabel(session.profile?.programmeId);
    final project = DisplayLabels.projectLabel(session.profile?.teamId);

    final canUpload = !_working && _file != null && uid.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Document')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _docType,
              items: const [
                DropdownMenuItem(value: 'id', child: Text('ID Document')),
                DropdownMenuItem(value: 'cv', child: Text('CV')),
                DropdownMenuItem(value: 'proofOfBank', child: Text('Proof of Banking')),
                DropdownMenuItem(value: 'contract', child: Text('Signed Contract')),
              ],
              onChanged: _working ? null : (v) => setState(() => _docType = v ?? 'id'),
              decoration: const InputDecoration(labelText: 'Document Type'),
            ),
            const SizedBox(height: 16),

            OutlinedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: Text(_file == null ? 'Choose File' : 'Change File'),
              onPressed: _working ? null : _pickFile,
            ),

            const SizedBox(height: 10),

            if (_file != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selected: ${_file!.name} (${_file!.size} bytes)',
                  style: const TextStyle(color: Colors.black54),
                ),
              ),

            const Spacer(),

            if (_working) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 10),
              const Text('Uploading… please wait', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canUpload ? () => _uploadNow(
                  uploader: uploader,
                  docs: docs,
                  fullName: fullName,
                  email: email,
                  uid: uid,
                  department: department,
                  project: project,
                ) : null,
                child: Text(_working ? 'Uploading…' : 'Upload Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(withData: true);
      if (result == null || result.files.isEmpty) return;
      setState(() => _file = result.files.first);
    } catch (e) {
      _snack('File picker failed: $e');
    }
  }

  Future<void> _uploadNow({
    required SharePointUploadService uploader,
    required DocumentService docs,
    required String fullName,
    required String email,
    required String uid,
    required String department,
    required String project,
  }) async {
    setState(() => _working = true);

    try {
      if (_file == null) throw Exception('No file selected.');
      if (_file!.bytes == null) throw Exception('File bytes not loaded. Choose the file again.');
      if (uid.isEmpty) throw Exception('User not signed in.');

      final docFolder = DisplayLabels.docTypeLabel(_docType).replaceAll(' ', '');
      final employeeFolder = _employeeFolder(fullName, uid);

      final sharePointPath =
          'salso_workforce/HR/$department/$project/'
          'Employees/$employeeFolder/Documents/$docFolder/'
          '${_file!.name}';

      // Visible debug (so we can trace what happens)
      // ignore: avoid_print
      print('[UPLOAD] sharePointPath=$sharePointPath');
      // ignore: avoid_print
      print('[UPLOAD] file=${_file!.name} size=${_file!.size} bytes');

      // 1) Upload to SharePoint (timeout to avoid “nothing happens”)
      final result = await uploader
          .uploadToDocumentsLibrary(
            sharePointPath: sharePointPath,
            bytes: Uint8List.fromList(_file!.bytes!),
          )
          .timeout(const Duration(minutes: 3));

      if (result.webUrl.isEmpty) {
        throw Exception('Upload finished but SharePoint URL was empty.');
      }

      // 2) Save metadata as UPLOADED (not queued)
      await docs.createUploadedDocument(
        docType: _docType,
        originalFileName: _file!.name,
        originalFileSizeBytes: _file!.size,
        sharePointPath: sharePointPath,
        sharePointFileUrl: result.webUrl,
        uploadedByName: fullName.isEmpty ? 'Unknown uploader' : fullName,
        uploadedByEmail: email,
      );

      if (!mounted) return;
      _snack('Uploaded successfully ✅');
      Navigator.pop(context);
    } on TimeoutException {
      _snack('Upload timed out. Try again.');
    } catch (e) {
      _snack('Upload failed: $e');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  String _employeeFolder(String fullName, String uid) {
    final name = fullName.trim();
    if (name.isEmpty) return 'Unknown ($uid)';

    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return '${parts.first} ($uid)';

    final first = parts.first;
    final rest = parts.sublist(1).join(' ');
    return '$rest, $first ($uid)';
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg.replaceAll('Exception: ', ''))),
    );
  }
}