import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../services/resource_service.dart';
import '../../models/app_resource.dart';
import '../../widgets/salso_card.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ResourceService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Resources & Library')),
      body: StreamBuilder<List<AppResource>>(
        stream: service.streamResources(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final resources = snap.data ?? [];
          if (resources.isEmpty) {
            return const SalsoEmptyState(
              icon: Icons.library_books_outlined,
              title: 'No Resources Yet',
              subtitle: 'Training manuals, guides, and bursary info will appear here.',
            );
          }

          final categories = resources.map((r) => r.category).toSet().toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: categories.map((cat) {
              final items = resources.where((r) => r.category == cat).toList();
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(cat, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                    ...items.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: SalsoCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(r.description, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
