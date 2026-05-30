class Reimbursement {
  final String id;
  final String userId;
  final double amount;
  final String description;
  final String status;
  final String? reviewedBy;
  final int? reviewedAtMs;
  final String? decisionReason;
  final int createdAtMs;

  Reimbursement({
    required this.id,
    required this.userId,
    required this.amount,
    required this.description,
    required this.status,
    required this.createdAtMs,
    this.reviewedBy,
    this.reviewedAtMs,
    this.decisionReason,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'amount': amount,
    'description': description,
    'status': status,
    'reviewedBy': reviewedBy,
    'reviewedAtMs': reviewedAtMs,
    'decisionReason': decisionReason,
    'createdAtMs': createdAtMs,
  };

  factory Reimbursement.fromMap(Map<String, dynamic> map) => Reimbursement(
    id: map['id'] ?? '',
    userId: map['userId'] ?? '',
    amount: (map['amount'] ?? 0).toDouble(),
    description: map['description'] ?? '',
    status: map['status'] ?? 'pending',
    reviewedBy: map['reviewedBy'],
    reviewedAtMs: map['reviewedAtMs'],
    decisionReason: map['decisionReason'],
    createdAtMs: map['createdAtMs'] ?? 0,
  );
}
