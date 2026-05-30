class EmployeeDocument {
  final String id;
  final String userId; // owner of the document record (usually the employee)

  // cv | id | proofOfBank | contract
  final String docType;

  // metadata only (no Firebase Storage)
  final String originalFileName;
  final int originalFileSizeBytes;

  // SharePoint destination + status
  final String sharePointPath;
  final String sharePointStatus; // queued | uploaded | failed
  final String? sharePointFileUrl;

  // ✅ Audit (Option 1: show real uploader in the app)
  final String uploadedByUid;
  final String uploadedByName;
  final String uploadedByEmail;
  final int uploadedAtMs;

  final int createdAtMs;
  final int updatedAtMs;

  EmployeeDocument({
    required this.id,
    required this.userId,
    required this.docType,
    required this.originalFileName,
    required this.originalFileSizeBytes,
    required this.sharePointPath,
    required this.sharePointStatus,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.uploadedByUid,
    required this.uploadedByName,
    required this.uploadedByEmail,
    required this.uploadedAtMs,
    this.sharePointFileUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'docType': docType,
      'originalFileName': originalFileName,
      'originalFileSizeBytes': originalFileSizeBytes,
      'sharePointPath': sharePointPath,
      'sharePointStatus': sharePointStatus,
      'sharePointFileUrl': sharePointFileUrl,
      'createdAtMs': createdAtMs,
      'updatedAtMs': updatedAtMs,

      // Audit fields
      'uploadedByUid': uploadedByUid,
      'uploadedByName': uploadedByName,
      'uploadedByEmail': uploadedByEmail,
      'uploadedAtMs': uploadedAtMs,
    };
  }

  factory EmployeeDocument.fromMap(Map<String, dynamic> map) {
    // Backward compatible defaults for existing docs already stored.
    final createdAt = (map['createdAtMs'] ?? 0) as int;

    return EmployeeDocument(
      id: (map['id'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      docType: (map['docType'] ?? '').toString(),
      originalFileName: (map['originalFileName'] ?? '').toString(),
      originalFileSizeBytes: (map['originalFileSizeBytes'] ?? 0) as int,
      sharePointPath: (map['sharePointPath'] ?? '').toString(),
      sharePointStatus: (map['sharePointStatus'] ?? 'queued').toString(),
      sharePointFileUrl: map['sharePointFileUrl']?.toString(),
      createdAtMs: createdAt,
      updatedAtMs: (map['updatedAtMs'] ?? createdAt) as int,

      uploadedByUid: (map['uploadedByUid'] ?? map['userId'] ?? '').toString(),
      uploadedByName:
          (map['uploadedByName'] ?? 'Unknown uploader').toString(),
      uploadedByEmail:
          (map['uploadedByEmail'] ?? '').toString(),
      uploadedAtMs: (map['uploadedAtMs'] ?? createdAt) as int,
    );
  }
}