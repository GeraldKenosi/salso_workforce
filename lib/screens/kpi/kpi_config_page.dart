import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/salso_app_bar.dart';
import '../../widgets/salso_card.dart';
import '../../services/kpi_service.dart';
import '../../models/kpi_config.dart';
import '../../app/theme.dart';

class KpiConfigPage extends StatefulWidget {
  const KpiConfigPage({super.key});

  @override
  State<KpiConfigPage> createState() => _KpiConfigPageState();
}

class _KpiConfigPageState extends State<KpiConfigPage> {
  final _service = KpiService(FirebaseFirestore.instance, FirebaseAuth.instance);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SalsoAppBar(title: const Text('KPI Config', style: TextStyle(color: Colors.white))),
      body: StreamBuilder(
        stream: _service.streamAllConfigs(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final configs = snapshot.data!;
          if (configs.isEmpty) return const Center(child: Text('No KPI configs yet. Create one from admin.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: configs.length,
            itemBuilder: (_, i) {
              final cfg = configs[i];
              final metrics = cfg.metrics;
              return SalsoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text('${cfg.roleGroup} — ${cfg.quarter}', style: const TextStyle(fontWeight: FontWeight.w700))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Metrics:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ...metrics.map((m) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Icon(Icons.square, size: 8, color: SalsoTheme.primary),
                          const SizedBox(width: 8),
                          Expanded(child: Text('${m.label} (${m.unit})', style: const TextStyle(fontSize: 13))),
                          Text('target: ${m.target.toInt()}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    )),
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
