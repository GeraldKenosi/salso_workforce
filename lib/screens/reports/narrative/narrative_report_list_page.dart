import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../widgets/salso_app_bar.dart';
import '../../../widgets/salso_card.dart';
import '../../../app/theme.dart';
import 'narrative_report_stepper.dart';
import 'narrative_report_detail_page.dart';

class NarrativeReportListPage extends StatelessWidget {
  const NarrativeReportListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: SalsoAppBar(title: const Text('Narrative Reports', style: TextStyle(color: Colors.white))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NarrativeReportStepper())),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('narrativeReports')
            .where('filerUid', isEqualTo: uid)
            .orderBy('dateMs', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final reports = snapshot.data!.docs;
          if (reports.isEmpty) return const Center(child: Text('No reports yet.'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (_, i) {
              final d = reports[i].data() as Map<String, dynamic>;
              final id = reports[i].id;
              final activity = d['activityName'] ?? '';
              final status = d['status'] ?? 'draft';
              final dateMs = d['dateMs'] ?? 0;
              final date = dateMs > 0 ? DateTime.fromMillisecondsSinceEpoch(dateMs) : null;
              final shortDate = date != null ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}' : '';
              final total = d['totalParticipants'] ?? 0;

              return SalsoCard(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => NarrativeReportDetailPage(reportId: id, reportData: d),
                )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(activity, style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        _statusChip(status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (shortDate.isNotEmpty) Text(shortDate, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    if (total > 0) Text('$total participants', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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
      case 'draft': color = Colors.grey; break;
      case 'submitted': color = SalsoTheme.primary; break;
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
