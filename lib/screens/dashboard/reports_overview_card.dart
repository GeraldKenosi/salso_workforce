import 'package:flutter/material.dart';
import 'package:salso_workforce/screens/reports/reports_menu_page.dart';

class ReportsOverviewCard extends StatelessWidget {
  const ReportsOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text(
          'Reports Overview',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Tap to open reports menu'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReportsMenuPage()),
          );
        },
      ),
    );
  }
}