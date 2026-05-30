class AuditLog {
  final String id;
  final String userId;
  final String userName;
  final String action;
  final String entityType;
  final String entityId;
  final String details;
  final int createdAtMs;

  AuditLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.details,
    required this.createdAtMs,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'action': action,
    'entityType': entityType,
    'entityId': entityId,
    'details': details,
    'createdAtMs': createdAtMs,
  };

  factory AuditLog.fromMap(Map<String, dynamic> map) => AuditLog(
    id: map['id'] ?? '',
    userId: map['userId'] ?? '',
    userName: map['userName'] ?? '',
    action: map['action'] ?? '',
    entityType: map['entityType'] ?? '',
    entityId: map['entityId'] ?? '',
    details: map['details'] ?? '',
    createdAtMs: map['createdAtMs'] ?? 0,
  );
}
