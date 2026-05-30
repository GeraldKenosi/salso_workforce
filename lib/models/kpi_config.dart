class KpiMetricConfig {
  final String metric;
  final String label;
  final String unit; // count | percent | rating | hours
  final double target;
  final double weight; // 0-100, sum per role = 100
  final String? autoSource; // reports | attendance | register | null (manual)

  KpiMetricConfig({
    required this.metric,
    required this.label,
    required this.unit,
    required this.target,
    required this.weight,
    this.autoSource,
  });

  Map<String, dynamic> toMap() => {
    'metric': metric, 'label': label, 'unit': unit,
    'target': target, 'weight': weight, 'autoSource': autoSource,
  };

  factory KpiMetricConfig.fromMap(Map<String, dynamic> m) => KpiMetricConfig(
    metric: m['metric'] ?? '',
    label: m['label'] ?? '',
    unit: m['unit'] ?? 'count',
    target: _toDouble(m['target']),
    weight: _toDouble(m['weight']),
    autoSource: m['autoSource'],
  );

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

class KpiConfig {
  final String id;
  final String roleGroup; // volunteer | teamLeader | coordinator_{prog} | manager_{prog} | admin | executiveDirector
  final String quarter; // 2026-Q2
  final String? programmeId;
  final List<KpiMetricConfig> metrics;
  final String createdBy;
  final int createdAtMs;

  KpiConfig({
    required this.id,
    required this.roleGroup,
    required this.quarter,
    this.programmeId,
    required this.metrics,
    required this.createdBy,
    required this.createdAtMs,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'roleGroup': roleGroup, 'quarter': quarter,
    'programmeId': programmeId,
    'metrics': metrics.map((m) => m.toMap()).toList(),
    'createdBy': createdBy, 'createdAtMs': createdAtMs,
  };

  factory KpiConfig.fromMap(Map<String, dynamic> m) {
    final rawMetrics = m['metrics'];
    return KpiConfig(
      id: m['id'] ?? '',
      roleGroup: m['roleGroup'] ?? '',
      quarter: m['quarter'] ?? '',
      programmeId: m['programmeId'],
      metrics: rawMetrics is List ? rawMetrics.map((e) => KpiMetricConfig.fromMap(Map<String, dynamic>.from(e))).toList() : [],
      createdBy: m['createdBy'] ?? '',
      createdAtMs: m['createdAtMs'] ?? 0,
    );
  }
}
