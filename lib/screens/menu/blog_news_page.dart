import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../services/announcement_service.dart';
import '../../models/announcement.dart';

class BlogNewsPage extends StatelessWidget {
  const BlogNewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AnnouncementService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: StreamBuilder<List<Announcement>>(
        stream: service.streamAnnouncements(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.red)),
            );
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(
              child: Text(
                'No announcements yet.\nCheck back later for updates.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (ctx, i) {
              final a = list[i];
              final date = DateFormat('dd MMM yyyy, HH:mm').format(
                DateTime.fromMillisecondsSinceEpoch(a.createdAtMs),
              );
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        a.body,
                        style: const TextStyle(height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$date • by ${a.authorName}',
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
