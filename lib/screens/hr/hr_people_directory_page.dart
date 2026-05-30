import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'hr_person_profile_page.dart';

class HrPeopleDirectoryPage extends StatefulWidget {
  const HrPeopleDirectoryPage({super.key});

  @override
  State<HrPeopleDirectoryPage> createState() => _HrPeopleDirectoryPageState();
}

class _HrPeopleDirectoryPageState extends State<HrPeopleDirectoryPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(title: const Text('People Directory')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                labelText: 'Search (name, email, role)',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('fullName')
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load users: ${snap.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final docs = snap.data?.docs ?? [];

                final filtered = docs.where((d) {
                  final data = d.data();
                  final fullName = (data['fullName'] ?? '').toString().toLowerCase();
                  final email = (data['email'] ?? '').toString().toLowerCase();
                  final role = (data['roleTemplateId'] ?? data['role'] ?? '').toString().toLowerCase();
                  if (query.isEmpty) return true;
                  return fullName.contains(query) || email.contains(query) || role.contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No matching people found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final doc = filtered[i];
                    final data = doc.data();

                    final fullName = (data['fullName'] ?? 'Unknown').toString();
                    final email = (data['email'] ?? '').toString();
                    final role = (data['roleTemplateId'] ?? data['role'] ?? 'unknown').toString();
                    final authProvisioned = (data['authProvisioned'] == true);

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(fullName),
                        subtitle: Text(email.isEmpty ? role : '$role • $email'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!authProvisioned)
                              const _Chip(text: 'LOGIN PENDING', color: Colors.orange),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HrPersonProfilePage(
                                userId: doc.id,
                                userData: data,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;

  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}