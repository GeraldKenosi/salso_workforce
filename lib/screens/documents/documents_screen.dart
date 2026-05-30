import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../services/document_service.dart';
import '../../state/session_provider.dart';
import '../../models/employee_document.dart';
import '../../utils/display_labels.dart';
import 'upload_document_page.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final docs = context.watch<DocumentService>();
    final session = context.watch<SessionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => session.signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Upload Document'),
              subtitle: const Text('Upload to SharePoint (CV, ID, banking, contract)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UploadDocumentPage(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: StreamBuilder<List<EmployeeDocument>>(
                stream: docs.streamMyDocuments(),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator();
                  }
                  if (snap.hasError) {
                    return Text(
                      'Failed to load documents: ${snap.error}',
                      style: const TextStyle(color: Colors.red),
                    );
                  }
                  final list = snap.data ?? [];
                  if (list.isEmpty) {
                    return const Text(
                      'No documents uploaded yet.',
                      style: TextStyle(color: Colors.black54),
                    );
                  }

                  final df = DateFormat('dd MMM yyyy, HH:mm');

                  return Column(
                    children: list.map((d) {
                      final label = DisplayLabels.docTypeLabel(d.docType);
                      final when = d.uploadedAtMs > 0
                          ? df.format(DateTime.fromMillisecondsSinceEpoch(d.uploadedAtMs))
                          : 'Unknown time';

                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(label),
                        subtitle: Text(
                          '${d.originalFileName}\n'
                          'Uploaded by: ${d.uploadedByName} • $when',
                        ),
                        trailing: Text(
                          d.sharePointStatus.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: d.sharePointStatus == 'uploaded'
                                ? Colors.green
                                : d.sharePointStatus == 'failed'
                                    ? Colors.red
                                    : Colors.orange,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}