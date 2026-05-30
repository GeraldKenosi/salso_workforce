class Report {
  final String id;
  final String userId;

  // ✅ Added for filtering
  final String programmeId;
  final String teamId;

  final String reportType; // daily | weekly | incident
  final String title;
  final String content;
  final int periodStartMs;
  final int periodEndMs;
  final String status; // draft | submitted | approved
  final int createdAtMs;
  final int updatedAtMs;

  // Photo evidence
  final List<String> photoUrls;

  // SharePoint integration (skeleton)
  final String sharePointPath;
  final String sharePointStatus; // pending | queued | uploaded | failed
  final String? sharePointFileUrl;

  // Approval audit fields
  final String? reviewedBy;
  final int? reviewedAtMs;
  final String? decisionReason;

  Report({
    required this.id,
    required this.userId,
    this.programmeId = '',
    this.teamId = '',
    required this.reportType,
    required this.title,
    required this.content,
    required this.periodStartMs,
    required this.periodEndMs,
    required this.status,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.photoUrls = const [],
    required this.sharePointPath,
    required this.sharePointStatus,
    this.sharePointFileUrl,
    this.reviewedBy,
    this.reviewedAtMs,
    this.decisionReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'programmeId': programmeId,
      'teamId': teamId,
      'reportType': reportType,
      'title': title,
      'content': content,
      'periodStartMs': periodStartMs,
      'periodEndMs': periodEndMs,
      'status': status,
      'createdAtMs': createdAtMs,
      'updatedAtMs': updatedAtMs,
      'photoUrls': photoUrls,
      'sharePointPath': sharePointPath,
      'sharePointStatus': sharePointStatus,
      'sharePointFileUrl': sharePointFileUrl,
      'reviewedBy': reviewedBy,
      'reviewedAtMs': reviewedAtMs,
      'decisionReason': decisionReason,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return Report(
      id: (map['id'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      programmeId: (map['programmeId'] ?? '').toString(),
      teamId: (map['teamId'] ?? '').toString(),
      reportType: (map['reportType'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      content: (map['content'] ?? '').toString(),
      periodStartMs: _toInt(map['periodStartMs']),
      periodEndMs: _toInt(map['periodEndMs']),
      status: (map['status'] ?? '').toString(),
      createdAtMs: _toInt(map['createdAtMs']),
      updatedAtMs: _toInt(map['updatedAtMs']),
      photoUrls: (map['photoUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
      sharePointPath: (map['sharePointPath'] ?? '').toString(),
      sharePointStatus: (map['sharePointStatus'] ?? '').toString(),
      sharePointFileUrl: map['sharePointFileUrl']?.toString(),
      reviewedBy: map['reviewedBy']?.toString(),
      reviewedAtMs: _toInt(map['reviewedAtMs']),
      decisionReason: map['decisionReason']?.toString(),
    );
  }
}