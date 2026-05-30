import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/salso_app_bar.dart';
import '../../widgets/salso_card.dart';
import '../../services/analytics_service.dart';

class ReportAnalyticsPage extends StatefulWidget {
  const ReportAnalyticsPage({super.key});

  @override
  State<ReportAnalyticsPage> createState() => _ReportAnalyticsPageState();
}

class _ReportAnalyticsPageState extends State<ReportAnalyticsPage> {
  final _service = AnalyticsService(FirebaseFirestore.instance);
  int _year = DateTime.now().year;
  int _month = DateTime.now().month;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final startMs = DateTime(_year, _month, 1).millisecondsSinceEpoch;
    final endMs = DateTime(_year, _month + 1, 0, 23, 59, 59).millisecondsSinceEpoch;
    final stats = await _service.getMonthlyStats(startMs, endMs);
    if (mounted) setState(() => _stats = stats);
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_year, _month),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Select month',
    );
    if (picked != null) {
      setState(() {
        _year = picked.year;
        _month = picked.month;
        _stats = null;
      });
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = '${_year}-${_month.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: SalsoAppBar(title: const Text('Report Analytics', style: TextStyle(color: Colors.white))),
      body: _stats == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Month picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_month),
                  title: Text(monthLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                  trailing: const Icon(Icons.edit),
                  onTap: _pickMonth,
                ),
                const SizedBox(height: 8),

                // Summary cards
                Row(
                  children: [
                    Expanded(child: _statCard('Reports', '${_stats!['totalReports'] ?? 0}')),
                    const SizedBox(width: 8),
                    Expanded(child: _statCard('Participants', '${_stats!['totalParticipants'] ?? 0}')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _statCard('Approved', '${_stats!['approvedReports'] ?? 0}', color: Colors.green)),
                    const SizedBox(width: 8),
                    Expanded(child: _statCard('Pending', '${_stats!['pendingReports'] ?? 0}', color: Colors.orange)),
                  ],
                ),
                const SizedBox(height: 16),

                // Demographics
                const Text('Demographics', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 8),
                SalsoCard(
                  child: Column(
                    children: [
                      _bar('Male', (_stats!['maleCount'] ?? 0).toDouble(), (_stats!['totalParticipants'] ?? 1).toDouble()),
                      _bar('Female', (_stats!['femaleCount'] ?? 0).toDouble(), (_stats!['totalParticipants'] ?? 1).toDouble()),
                      _bar('Youth', (_stats!['youthCount'] ?? 0).toDouble(), (_stats!['totalParticipants'] ?? 1).toDouble()),
                      _bar('Adults', (_stats!['adultsCount'] ?? 0).toDouble(), (_stats!['totalParticipants'] ?? 1).toDouble()),
                      _bar('Children', (_stats!['childrenCount'] ?? 0).toDouble(), (_stats!['totalParticipants'] ?? 1).toDouble()),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Programme breakdown
                if (_stats!['programmeBreakdown'] is Map) ...[
                  const Text('By Programme', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 8),
                  SalsoCard(
                    child: Column(
                      children: (_stats!['programmeBreakdown'] as Map<String, dynamic>).entries.map((e) {
                        return _bar(e.key, (e.value as num).toDouble(), (_stats!['totalReports'] ?? 1).toDouble());
                      }).toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
    );
  }

  Widget _statCard(String label, String value, {Color? color}) {
    return SalsoCard(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: color ?? Colors.black87)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _bar(String label, double value, double total) {
    final pct = total > 0 ? value / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 13))),
              Text('${value.toInt()}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const Spacer(),
              Text('${(pct * 100).toStringAsFixed(0)}%', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: pct, minHeight: 8, backgroundColor: Colors.grey[200]),
          ),
        ],
      ),
    );
  }
}
