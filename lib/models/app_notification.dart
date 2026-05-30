class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final bool read;
  final String? relatedEntityId;
  final String? relatedEntityType;
  final int createdAtMs;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.read = false,
    this.relatedEntityId,
    this.relatedEntityType,
    required this.createdAtMs,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'title': title,
    'body': body,
    'type': type,
    'read': read,
    'relatedEntityId': relatedEntityId,
    'relatedEntityType': relatedEntityType,
    'createdAtMs': createdAtMs,
  };

  factory AppNotification.fromMap(Map<String, dynamic> map) => AppNotification(
    id: map['id'] ?? '',
    userId: map['userId'] ?? '',
    title: map['title'] ?? '',
    body: map['body'] ?? '',
    type: map['type'] ?? '',
    read: map['read'] ?? false,
    relatedEntityId: map['relatedEntityId'],
    relatedEntityType: map['relatedEntityType'],
    createdAtMs: map['createdAtMs'] ?? 0,
  );
}
