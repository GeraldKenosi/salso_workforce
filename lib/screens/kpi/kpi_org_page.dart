import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/salso_app_bar.dart';
import '../../widgets/salso_card.dart';
import '../../app/theme.dart';

class KpiOrgPage extends StatefulWidget {
  const KpiOrgPage({super.key});

  @override
  State<KpiOrgPage> createState() => _KpiOrgPageState();
}

class _KpiOrgPageState extends State<KpiOrgPage> {
  final _quarter = '${DateTime.now().year}-Q${((DateTime.now().month - 1) ~/ 3) + 1}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SalsoAppBar(title: const Text('Organisation KPIs', style: TextStyle(color: Colors.white))),
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
          if (docs.isEmpty) return const Center(child: Text('No KPI data yet. Auto-population runs daily.'));

          double totalPct = 0;
          final Map<String, List<double>> metricTotals = {};
          for (final doc in docs) {
            final d = doc.data() as Map<String, dynamic>;
            totalPct += (d['overallPercentage'] ?? 0).toDouble();
            final scoresMap = d['scores'] as Map<String, dynamic>? ?? {};
            for (final e in scoresMap.entries) {
              final metric = e.value is Map ? Map<String, dynamic>.from(e.value) : {};
              metricTotals.putIfAbsent(e.key, () => [0, 0]);
              metricTotals[e.key]![0] += (metric['value'] ?? 0).toDouble();
              metricTotals[e.key]![1] += (metric['target'] ?? 1).toDouble();
            }
          }
          final avgPct = docs.isNotEmpty ? (totalPct / docs.length) : 0.0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SalsoCard(
                child: Column(
                  children: [
                    const Text('Organisation Average', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('${avgPct.toStringAsFixed(0)}%', style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 40,
                      color: avgPct >= 80 ? Colors.green : (avgPct >= 50 ? Colors.orange : Colors.red),
                    )),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(value: avgPct / 100, minHeight: 12, backgroundColor: Colors.grey[200]),
                    ),
                    const SizedBox(height: 4),
                    Text('${docs.length} staff scored', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              if (metricTotals.isNotEmpty) ...[
                const Text('Metric Averages', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 8),
                SalsoCard(
                  child: Column(
                    children: metricTotals.entries.map((e) {
                      final pct = e.value[1] > 0 ? (e.value[0] / e.value[1] * 100) : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(child: Text(e.key, style: const TextStyle(fontSize: 13))),
                            Text('${pct.toStringAsFixed(0)}%', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 12),
              const Text('Staff Scores', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 8),
              ...docs.map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                final uid = d['userId'] ?? '';
                final pct = (d['overallPercentage'] ?? 0).toDouble();
                return SalsoCard(
                  child: Row(
                    children: [
                      Expanded(child: Text(uid, style: const TextStyle(fontSize: 13))),
                      _scoreChip(pct.toInt()),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
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
