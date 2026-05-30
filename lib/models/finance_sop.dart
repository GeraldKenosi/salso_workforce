class FinanceSop {
  final String id;
  final String userId;
  final String sopType;
  final String title;
  final double amount;
  final String description;
  final String status;
  final String? managerApproval;
  final String? financeApproval;
  final String? edApproval;
  final String? reviewedBy;
  final int? reviewedAtMs;
  final String? decisionReason;
  final List<String> attachmentUrls;
  final int createdAtMs;

  FinanceSop({
    required this.id,
    required this.userId,
    required this.sopType,
    required this.title,
    required this.amount,
    required this.description,
    required this.status,
    this.managerApproval,
    this.financeApproval,
    this.edApproval,
    this.reviewedBy,
    this.reviewedAtMs,
    this.decisionReason,
    this.attachmentUrls = const [],
    required this.createdAtMs,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'sopType': sopType,
    'title': title,
    'amount': amount,
    'description': description,
    'status': status,
    'managerApproval': managerApproval,
    'financeApproval': financeApproval,
    'edApproval': edApproval,
    'reviewedBy': reviewedBy,
    'reviewedAtMs': reviewedAtMs,
    'decisionReason': decisionReason,
    'attachmentUrls': attachmentUrls,
    'createdAtMs': createdAtMs,
  };

  factory FinanceSop.fromMap(Map<String, dynamic> map) => FinanceSop(
    id: map['id'] ?? '',
    userId: map['userId'] ?? '',
    sopType: map['sopType'] ?? '',
    title: map['title'] ?? '',
    amount: (map['amount'] ?? 0).toDouble(),
    description: map['description'] ?? '',
    status: map['status'] ?? 'draft',
    managerApproval: map['managerApproval'],
    financeApproval: map['financeApproval'],
    edApproval: map['edApproval'],
    reviewedBy: map['reviewedBy'],
    reviewedAtMs: map['reviewedAtMs'],
    decisionReason: map['decisionReason'],
    attachmentUrls: (map['attachmentUrls'] as List<dynamic>?)?.cast<String>() ?? [],
    createdAtMs: map['createdAtMs'] ?? 0,
  );
}
