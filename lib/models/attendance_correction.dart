class AttendanceCorrection {
  final String id;
  final String userId;
  final String clockInEventId;
  final String clockInEventFirestoreId;
  final int proposedClockOutMs;
  final String reason;
  final String status; // pending | under_review | approved | rejected
  final String? reviewedBy;
  final int createdAtMs;
  final int? reviewedAtMs;
  final String? decisionReason;

  // NEW: original event snapshot
  final Map<String, dynamic>? originalEvent;

  // NEW: correction applied details
  final String? newEventFirestoreId;
  final int? correctedTimestampMs;
  final int? appliedAtMs;
  final String? appliedBy;

  // NEW: embedded audit trail
  final List<Map<String, dynamic>> auditLog;

  // NEW: link to SOP workflow
  final String? workflowRequestId;

  AttendanceCorrection({
    required this.id,
    required this.userId,
    required this.clockInEventId,
    this.clockInEventFirestoreId = '',
    required this.proposedClockOutMs,
    required this.reason,
    required this.status,
    required this.createdAtMs,
    this.reviewedBy,
    this.reviewedAtMs,
    this.decisionReason,
    this.originalEvent,
    this.newEventFirestoreId,
    this.correctedTimestampMs,
    this.appliedAtMs,
    this.appliedBy,
    this.auditLog = const [],
    this.workflowRequestId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'clockInEventId': clockInEventId,
      'clockInEventFirestoreId': clockInEventFirestoreId,
      'proposedClockOutMs': proposedClockOutMs,
      'reason': reason,
      'status': status,
      'reviewedBy': reviewedBy,
      'createdAtMs': createdAtMs,
      'reviewedAtMs': reviewedAtMs,
      'decisionReason': decisionReason,
      'originalEvent': originalEvent,
      'newEventFirestoreId': newEventFirestoreId,
      'correctedTimestampMs': correctedTimestampMs,
      'appliedAtMs': appliedAtMs,
      'appliedBy': appliedBy,
      'auditLog': auditLog,
      'workflowRequestId': workflowRequestId,
    };
  }

  factory AttendanceCorrection.fromMap(Map<String, dynamic> map) {
    return AttendanceCorrection(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      clockInEventId: map['clockInEventId'] ?? '',
      clockInEventFirestoreId: map['clockInEventFirestoreId'] ?? '',
      proposedClockOutMs: map['proposedClockOutMs'] ?? 0,
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'pending',
      reviewedBy: map['reviewedBy'],
      createdAtMs: map['createdAtMs'] ?? 0,
      reviewedAtMs: map['reviewedAtMs'],
      decisionReason: map['decisionReason'],
      originalEvent: map['originalEvent'] is Map ? Map<String, dynamic>.from(map['originalEvent']) : null,
      newEventFirestoreId: map['newEventFirestoreId'],
      correctedTimestampMs: map['correctedTimestampMs'],
      appliedAtMs: map['appliedAtMs'],
      appliedBy: map['appliedBy'],
      auditLog: map['auditLog'] is List
          ? (map['auditLog'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList()
          : [],
      workflowRequestId: map['workflowRequestId'],
    );
  }
}
