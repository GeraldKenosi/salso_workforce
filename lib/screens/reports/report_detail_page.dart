import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/report.dart';

class ReportDetailPage extends StatelessWidget {
  final Report report;

  const ReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    String fmt(int ms) {
      if (ms <= 0) return 'Unknown';
      return DateTime.fromMillisecondsSinceEpoch(ms).toLocal().toString();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Report Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            report.title.isEmpty ? '(Untitled)' : report.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            '${report.reportType.toUpperCase()} • ${report.status.toUpperCase()}',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Created: ${fmt(report.createdAtMs)}',
                      style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 6),
                  Text('Updated: ${fmt(report.updatedAtMs)}',
                      style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 10),
                  Text('Programme: ${report.programmeId.isEmpty ? "N/A" : report.programmeId}'),
                  const SizedBox(height: 6),
                  Text('Team: ${report.teamId.isEmpty ? "N/A" : report.teamId}'),
                  const SizedBox(height: 10),
                  Text('SharePoint Status: ${report.sharePointStatus}'),
                  if ((report.sharePointFileUrl ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text('SharePoint URL: ${report.sharePointFileUrl}'),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Text('Content', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            report.content.isEmpty ? 'No content.' : report.content,
            style: const TextStyle(height: 1.4),
          ),

          if (report.photoUrls.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Photo Evidence', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: report.photoUrls.map((path) {
                return GestureDetector(
                  onTap: () => _showPhoto(context, path),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _showPhoto(BuildContext context, String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(File(path), fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
