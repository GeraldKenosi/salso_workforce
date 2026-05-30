class LeaveRequest {
  final String id;
  final String userId;
  final String leaveType;
  final int startDateMs;
  final int endDateMs;
  final String reason;
  final String status;
  final String? reviewedBy;
  final int? reviewedAtMs;
  final String? decisionReason;
  final int createdAtMs;

  LeaveRequest({
    required this.id,
    required this.userId,
    required this.leaveType,
    required this.startDateMs,
    required this.endDateMs,
    required this.reason,
    required this.status,
    required this.createdAtMs,
    this.reviewedBy,
    this.reviewedAtMs,
    this.decisionReason,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'leaveType': leaveType,
    'startDateMs': startDateMs,
    'endDateMs': endDateMs,
    'reason': reason,
    'status': status,
    'reviewedBy': reviewedBy,
    'reviewedAtMs': reviewedAtMs,
    'decisionReason': decisionReason,
    'createdAtMs': createdAtMs,
  };

  factory LeaveRequest.fromMap(Map<String, dynamic> map) => LeaveRequest(
    id: map['id'] ?? '',
    userId: map['userId'] ?? '',
    leaveType: map['leaveType'] ?? '',
    startDateMs: map['startDateMs'] ?? 0,
    endDateMs: map['endDateMs'] ?? 0,
    reason: map['reason'] ?? '',
    status: map['status'] ?? 'pending',
    reviewedBy: map['reviewedBy'],
    reviewedAtMs: map['reviewedAtMs'],
    decisionReason: map['decisionReason'],
    createdAtMs: map['createdAtMs'] ?? 0,
  );
}
