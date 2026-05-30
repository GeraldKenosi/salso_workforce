import 'package:flutter/material.dart';
import '../../widgets/salso_app_bar.dart';

class SopDetailPage extends StatelessWidget {
  final String title;
  final String category;
  final String content;

  const SopDetailPage({
    super.key,
    required this.title,
    required this.category,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SalsoAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(category, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(content, style: const TextStyle(fontSize: 14, height: 1.6)),
          ],
        ),
      ),
    );
  }
}
