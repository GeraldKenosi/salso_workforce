class AppResource {
  final String id;
  final String title;
  final String category;
  final String description;
  final String url;
  final int createdAtMs;

  AppResource({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.url,
    required this.createdAtMs,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'category': category,
    'description': description,
    'url': url,
    'createdAtMs': createdAtMs,
  };

  factory AppResource.fromMap(Map<String, dynamic> map) => AppResource(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    category: map['category'] ?? '',
    description: map['description'] ?? '',
    url: map['url'] ?? '',
    createdAtMs: map['createdAtMs'] ?? 0,
  );
}
