import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/salso_app_bar.dart';
import '../../widgets/salso_card.dart';

class KpiOneOnOnePage extends StatefulWidget {
  const KpiOneOnOnePage({super.key});

  @override
  State<KpiOneOnOnePage> createState() => _KpiOneOnOnePageState();
}

class _KpiOneOnOnePageState extends State<KpiOneOnOnePage> {
  final _quarter = '${DateTime.now().year}-Q${((DateTime.now().month - 1) ~/ 3) + 1}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SalsoAppBar(title: const Text('One-on-One Meetings', style: TextStyle(color: Colors.white))),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('kpiScores')
            .where('quarter', isEqualTo: _quarter)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final docs = snapshot.data?.docs ?? [];

          final meetings = <Map<String, dynamic>>[];
          for (final doc in docs) {
            final d = doc.data() as Map<String, dynamic>;
            final ooo = d['oneOnOne'] as Map<String, dynamic>?;
            if (ooo != null) {
              meetings.add({
                'userId': d['userId'] ?? '',
                ...ooo,
              });
            }
          }

          if (meetings.isEmpty) return const Center(child: Text('No one-on-one meetings scheduled.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: meetings.length,
            itemBuilder: (_, i) {
              final m = meetings[i];
              final userId = m['userId'] ?? '';
              final notes = m['meetingNotes'] ?? '';
              final completed = m['completed'] == true;
              final scheduled = m['scheduled'] == true;
              final meetingDateMs = m['meetingDateMs'];
              final date = meetingDateMs != null
                  ? DateTime.fromMillisecondsSinceEpoch(meetingDateMs as int)
                  : null;

              return SalsoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(completed ? Icons.check_circle : Icons.pending,
                          color: completed ? Colors.green : Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(userId, style: const TextStyle(fontWeight: FontWeight.w700))),
                        Text(completed ? 'Done' : (scheduled ? 'Scheduled' : 'Pending'),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                            color: completed ? Colors.green : Colors.orange)),
                      ],
                    ),
                    if (date != null) ...[
                      const SizedBox(height: 4),
                      Text('${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                    if (notes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(notes, style: const TextStyle(fontSize: 13)),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
