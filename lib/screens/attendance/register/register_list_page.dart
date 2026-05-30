import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../widgets/salso_card.dart';
import '../../../widgets/salso_app_bar.dart';
import '../../../app/theme.dart';
import 'create_register_page.dart';
import 'register_detail_page.dart';

class RegisterListPage extends StatelessWidget {
  const RegisterListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SalsoAppBar(title: const Text('Attendance Registers', style: TextStyle(color: Colors.white))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateRegisterPage())),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('attendanceRegisters').orderBy('dateMs', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final registers = snapshot.data!.docs;
          if (registers.isEmpty) return const Center(child: Text('No registers yet.'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: registers.length,
            itemBuilder: (_, i) {
              final d = registers[i].data() as Map<String, dynamic>;
              final id = registers[i].id;
              final name = d['name'] ?? '';
              final status = d['status'] ?? 'open';
              final count = d['participantCount'] ?? 0;
              final activity = d['activityName'] ?? '';
              final dateMs = d['dateMs'] ?? 0;
              final date = dateMs > 0 ? DateTime.fromMillisecondsSinceEpoch(dateMs) : null;
              final shortDate = date != null ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}' : '';

              return SalsoCard(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => RegisterDetailPage(registerId: id, registerData: d),
                )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        _statusChip(status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (shortDate.isNotEmpty) Text(shortDate, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    if (activity.isNotEmpty) Text(activity, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: SalsoTheme.primary),
                        const SizedBox(width: 4),
                        Text('$count participants', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = status == 'open' ? SalsoTheme.accent : (status == 'closed' ? Colors.orange : Colors.green);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
      child: Text(status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
