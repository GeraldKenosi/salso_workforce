import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../../services/report_service.dart';
import '../../state/session_provider.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  String _type = 'daily';
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  List<String> _photoPaths = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null && result.paths.isNotEmpty) {
      setState(() {
        _photoPaths = result.paths.where((p) => p != null).cast<String>().toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<ReportService>();
    final session = context.watch<SessionProvider>();

    final programmeId = session.profile?.programmeId ?? '';
    final teamId = session.profile?.teamId ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Create Report')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _type,
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Daily Activity')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly Programme')),
                DropdownMenuItem(value: 'incident', child: Text('Incident')),
              ],
              onChanged: (v) => setState(() => _type = v ?? 'daily'),
              decoration: const InputDecoration(labelText: 'Report Type'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentCtrl,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_a_photo),
                  label: Text(_photoPaths.isEmpty ? 'Add Photos' : 'Change Photos'),
                  onPressed: _pickPhotos,
                ),
                if (_photoPaths.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text('${_photoPaths.length} selected', style: const TextStyle(color: Colors.black54)),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => setState(() => _photoPaths = []),
                    child: const Text('Clear'),
                  ),
                ],
              ],
            ),
            if (_photoPaths.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photoPaths.length,
                  itemBuilder: (ctx, i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(_photoPaths[i]), width: 80, height: 80, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await service.createReport(
                    reportType: _type,
                    title: _titleCtrl.text,
                    content: _contentCtrl.text,
                    periodStart: DateTime.now(),
                    periodEnd: DateTime.now(),
                    programmeId: programmeId,
                    teamId: teamId,
                    photoUrls: _photoPaths,
                  );
                  if (!mounted) return;
                  Navigator.pop(context);
                },
                child: const Text('Save Draft'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
