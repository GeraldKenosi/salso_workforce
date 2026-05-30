class ContactMessage {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String subject;
  final String message;
  final int createdAtMs;

  ContactMessage({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.subject,
    required this.message,
    required this.createdAtMs,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'userEmail': userEmail,
    'subject': subject,
    'message': message,
    'createdAtMs': createdAtMs,
  };

  factory ContactMessage.fromMap(Map<String, dynamic> map) => ContactMessage(
    id: map['id'] ?? '',
    userId: map['userId'] ?? '',
    userName: map['userName'] ?? '',
    userEmail: map['userEmail'] ?? '',
    subject: map['subject'] ?? '',
    message: map['message'] ?? '',
    createdAtMs: map['createdAtMs'] ?? 0,
  );
}
