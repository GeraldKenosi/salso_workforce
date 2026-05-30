import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/salso_app_bar.dart';
import '../../widgets/salso_card.dart';
import '../../models/sop_form_config.dart';
import '../../app/theme.dart';
import 'sop_request_detail_page.dart';
import 'sop_form_page.dart';

class MyRequestsPage extends StatelessWidget {
  const MyRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: SalsoAppBar(title: const Text('My Requests', style: TextStyle(color: Colors.white))),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('workflowRequests')
            .where('filerUid', isEqualTo: uid)
            .orderBy('createdAtMs', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final requests = snapshot.data!.docs;
          if (requests.isEmpty) return const Center(child: Text('No requests yet.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (_, i) {
              final d = requests[i].data() as Map<String, dynamic>;
              final id = requests[i].id;
              final data = d['data'] is Map ? Map<String, dynamic>.from(d['data']) : d;
              final type = d['type'] ?? 'general';
              final cfg = SopFormConfig.fromType(type);
              final typeLabel = cfg?.label ?? type;
              final title = data['title'] ?? 'No title';
              final status = d['currentStatus'] ?? 'pending';

              return SalsoCard(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => SopRequestDetailPage(requestData: {'id': id, ...d}),
                )),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(typeLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                        ],
                      ),
                    ),
                    _statusChip(status),
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
    Color color;
    switch (status) {
      case 'pending': color = Colors.orange; break;
      case 'approved': color = Colors.green; break;
      case 'rejected': color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
      child: Text(status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
