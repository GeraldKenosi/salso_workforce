import 'package:flutter/material.dart';
import 'hr_people_directory_page.dart';
import 'hr_create_user_page.dart';

class HrHomePage extends StatelessWidget {
  const HrHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HR')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_add_alt_1),
              title: const Text('Create Login'),
              subtitle: const Text('Create a new staff/volunteer login'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HrCreateUserPage()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('People Directory'),
              subtitle: const Text('View all staff and volunteers'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HrPeopleDirectoryPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}