class Announcement {
  final String id;
  final String title;
  final String body;
  final String authorName;
  final int createdAtMs;

  Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.authorName,
    required this.createdAtMs,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'body': body,
    'authorName': authorName,
    'createdAtMs': createdAtMs,
  };

  factory Announcement.fromMap(Map<String, dynamic> map) => Announcement(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    body: map['body'] ?? '',
    authorName: map['authorName'] ?? '',
    createdAtMs: map['createdAtMs'] ?? 0,
  );
}
