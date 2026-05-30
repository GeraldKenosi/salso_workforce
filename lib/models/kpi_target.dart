class KpiTarget {
  final String id;
  final String userId;
  final String metric;
  final double targetValue;
  final double currentValue;
  final String period;
  final int periodStartMs;
  final int periodEndMs;

  KpiTarget({
    required this.id,
    required this.userId,
    required this.metric,
    required this.targetValue,
    this.currentValue = 0,
    required this.period,
    required this.periodStartMs,
    required this.periodEndMs,
  });

  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0, 1) : 0;

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'metric': metric,
    'targetValue': targetValue,
    'currentValue': currentValue,
    'period': period,
    'periodStartMs': periodStartMs,
    'periodEndMs': periodEndMs,
  };

  factory KpiTarget.fromMap(Map<String, dynamic> map) => KpiTarget(
    id: map['id'] ?? '',
    userId: map['userId'] ?? '',
    metric: map['metric'] ?? '',
    targetValue: (map['targetValue'] ?? 0).toDouble(),
    currentValue: (map['currentValue'] ?? 0).toDouble(),
    period: map['period'] ?? '',
    periodStartMs: map['periodStartMs'] ?? 0,
    periodEndMs: map['periodEndMs'] ?? 0,
  );
}
