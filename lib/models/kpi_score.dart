class MetricScore {
  final double value;
  final double target;
  final double percentage;
  final String? comment;

  MetricScore({
    required this.value,
    required this.target,
    this.percentage = 0,
    this.comment,
  });

  Map<String, dynamic> toMap() => {
    'value': value, 'target': target, 'percentage': percentage, 'comment': comment,
  };

  factory MetricScore.fromMap(Map<String, dynamic> m) => MetricScore(
    value: _toDouble(m['value']),
    target: _toDouble(m['target']),
    percentage: _toDouble(m['percentage']),
    comment: m['comment'],
  );

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

class KpiOneOnOne {
  final bool scheduled;
  final int? meetingDateMs;
  final String? meetingNotes;
  final bool completed;

  const KpiOneOnOne({
    this.scheduled = false,
    this.meetingDateMs,
    this.meetingNotes,
    this.completed = false,
  });

  Map<String, dynamic> toMap() => {
    'scheduled': scheduled, 'meetingDateMs': meetingDateMs,
    'meetingNotes': meetingNotes, 'completed': completed,
  };

  factory KpiOneOnOne.fromMap(Map<String, dynamic> m) => KpiOneOnOne(
    scheduled: m['scheduled'] ?? false,
    meetingDateMs: m['meetingDateMs'],
    meetingNotes: m['meetingNotes'],
    completed: m['completed'] ?? false,
  );
}

class KpiScore {
  final String id;
  final String userId;
  final String quarter;
  final String? programmeId;
  final String? roleGroup;
  final Map<String, MetricScore> scores;
  final double overallPercentage;
  final String rating; // fails | below | meets | exceeds | outstanding
  final String? reviewerId;
  final String? reviewerName;
  final int? reviewDateMs;
  final bool finalized;
  final KpiOneOnOne oneOnOne;
  final int createdAtMs;
  final int updatedAtMs;

  KpiScore({
    required this.id,
    required this.userId,
    required this.quarter,
    this.programmeId,
    this.roleGroup,
    this.scores = const {},
    this.overallPercentage = 0,
    this.rating = 'meets',
    this.reviewerId,
    this.reviewerName,
    this.reviewDateMs,
    this.finalized = false,
    this.oneOnOne = const KpiOneOnOne(),
    required this.createdAtMs,
    required this.updatedAtMs,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'userId': userId, 'quarter': quarter,
    'programmeId': programmeId, 'roleGroup': roleGroup,
    'scores': scores.map((k, v) => MapEntry(k, v.toMap())),
    'overallPercentage': overallPercentage, 'rating': rating,
    'reviewerId': reviewerId, 'reviewerName': reviewerName,
    'reviewDateMs': reviewDateMs, 'finalized': finalized,
    'oneOnOne': oneOnOne.toMap(),
    'createdAtMs': createdAtMs, 'updatedAtMs': updatedAtMs,
  };

  factory KpiScore.fromMap(Map<String, dynamic> m) {
    final rawScores = m['scores'];
    final parsedScores = <String, MetricScore>{};
    if (rawScores is Map) {
      rawScores.forEach((k, v) {
        if (v is Map) parsedScores[k] = MetricScore.fromMap(Map<String, dynamic>.from(v));
      });
    }
    return KpiScore(
      id: m['id'] ?? '', userId: m['userId'] ?? '', quarter: m['quarter'] ?? '',
      programmeId: m['programmeId'], roleGroup: m['roleGroup'],
      scores: parsedScores, overallPercentage: _toDouble(m['overallPercentage']),
      rating: m['rating'] ?? 'meets',
      reviewerId: m['reviewerId'], reviewerName: m['reviewerName'],
      reviewDateMs: m['reviewDateMs'], finalized: m['finalized'] ?? false,
      oneOnOne: m['oneOnOne'] is Map ? KpiOneOnOne.fromMap(Map<String, dynamic>.from(m['oneOnOne'])) : KpiOneOnOne(),
      createdAtMs: m['createdAtMs'] ?? 0, updatedAtMs: m['updatedAtMs'] ?? 0,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
