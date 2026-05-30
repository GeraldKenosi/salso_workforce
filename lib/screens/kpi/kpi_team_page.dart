import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/salso_app_bar.dart';
import '../../widgets/salso_card.dart';
import '../../services/kpi_service.dart';
import '../../app/theme.dart';

class KpiTeamPage extends StatefulWidget {
  const KpiTeamPage({super.key});

  @override
  State<KpiTeamPage> createState() => _KpiTeamPageState();
}

class _KpiTeamPageState extends State<KpiTeamPage> {
  final _service = KpiService(FirebaseFirestore.instance, FirebaseAuth.instance);
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  final _quarter = '${DateTime.now().year}-Q${((DateTime.now().month - 1) ~/ 3) + 1}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SalsoAppBar(title: const Text('Team KPIs', style: TextStyle(color: Colors.white))),
      body: FutureBuilder(
        future: _loadTeamScores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final scores = snapshot.data as List? ?? [];
          if (scores.isEmpty) return const Center(child: Text('No team KPI data yet.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: scores.length,
            itemBuilder: (_, i) {
              final s = scores[i] as Map<String, dynamic>;
              final userId = s['userId'] ?? '';
              final pct = (s['overallPercentage'] ?? 0).toDouble();
              final scoresMap = s['scores'] as Map<String, dynamic>? ?? {};

              return SalsoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(userId, style: const TextStyle(fontWeight: FontWeight.w700))),
                        _scoreChip(pct.toInt()),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${pct.toStringAsFixed(0)}% overall', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: pct / 100, minHeight: 8, backgroundColor: Colors.grey[200]),
                    ),
                    if (scoresMap.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...scoresMap.entries.take(5).map((e) {
                        final metric = e.value is Map ? Map<String, dynamic>.from(e.value) : {};
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Expanded(child: Text(e.key, style: const TextStyle(fontSize: 12))),
                              Text('${metric['value'] ?? 0}/${metric['target'] ?? 1}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                        );
                      }),
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

  Future<List<dynamic>> _loadTeamScores() async {
    // Get team members (simplified: get users with same role)
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    final role = userDoc.data()?['roleTemplateId'] ?? '';
    final users = await FirebaseFirestore.instance
        .collection('users')
        .where('roleTemplateId', isEqualTo: role)
        .get();
    final uids = users.docs.map((d) => d.id).toList();
    if (uids.isEmpty) return [];

    final scores = await FirebaseFirestore.instance
        .collection('kpiScores')
        .where('userId', whereIn: uids.take(10).toList())
        .get();
    return scores.docs.map((d) => d.data()).toList();
  }

  Widget _scoreChip(int pct) {
    final color = pct >= 80 ? Colors.green : (pct >= 50 ? Colors.orange : Colors.red);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
      child: Text('$pct%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
