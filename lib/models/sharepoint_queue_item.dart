class SharePointQueueItem {
  final String id;
  final String reportId;
  final String sharePointPath;
  final String status; // queued | uploading | uploaded | failed
  final int createdAtMs;
  final String? error;

  SharePointQueueItem({
    required this.id,
    required this.reportId,
    required this.sharePointPath,
    required this.status,
    required this.createdAtMs,
    this.error,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reportId': reportId,
      'sharePointPath': sharePointPath,
      'status': status,
      'createdAtMs': createdAtMs,
      'error': error,
    };
  }

  factory SharePointQueueItem.fromMap(Map<String, dynamic> map) {
    return SharePointQueueItem(
      id: map['id'],
      reportId: map['reportId'],
      sharePointPath: map['sharePointPath'],
      status: map['status'],
      createdAtMs: map['createdAtMs'],
      error: map['error'],
    );
  }
}