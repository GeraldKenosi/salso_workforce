import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/kpi_service.dart';
import '../../models/kpi_target.dart';
import '../../widgets/salso_card.dart';
import '../../app/theme.dart';

class KpiDashboardScreen extends StatelessWidget {
  const KpiDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<KpiService>();

    return Scaffold(
      appBar: AppBar(title: const Text('My KPIs')),
      body: StreamBuilder<List<KpiTarget>>(
        stream: service.streamMyKpis(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final kpis = snap.data ?? [];
          if (kpis.isEmpty) {
            return const SalsoEmptyState(
              icon: Icons.track_changes_outlined,
              title: 'No KPIs Set',
              subtitle: 'Your manager will assign KPIs for your role.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SalsoCard(
                child: Column(
                  children: [
                    const Text('Overall Performance', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 16),
                    ...kpis.map((k) => _KpiProgressTile(kpi: k)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _KpiProgressTile extends StatelessWidget {
  final KpiTarget kpi;

  const _KpiProgressTile({required this.kpi});

  @override
  Widget build(BuildContext context) {
    final pct = (kpi.progress * 100).toStringAsFixed(0);
    final color = kpi.progress >= 1 ? SalsoTheme.success
        : kpi.progress >= 0.7 ? SalsoTheme.secondary
        : kpi.progress >= 0.4 ? SalsoTheme.warning
        : SalsoTheme.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(kpi.metric, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text('${kpi.currentValue.toStringAsFixed(0)} / ${kpi.targetValue.toStringAsFixed(0)} ($pct%)',
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: kpi.progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class KpiAdminScreen extends StatelessWidget {
  const KpiAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team KPIs')),
      body: const Center(child: Text('KPI management - assign targets, view team progress.')),
    );
  }
}
