class UserProfile {
  final String uid;
  final String email;
  final String fullName;
  final String roleTemplateId;
  final String status;

  final String? teamId;
  final String? programmeId;

  final String? phoneNumber;
  final String? physicalAddress;
  final String? idNumber;
  final String? nextOfKinName;
  final String? nextOfKinRelationship;
  final String? nextOfKinPhone;
  final String? signatureUrl;

  UserProfile({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.roleTemplateId,
    required this.status,
    this.teamId,
    this.programmeId,
    this.phoneNumber,
    this.physicalAddress,
    this.idNumber,
    this.nextOfKinName,
    this.nextOfKinRelationship,
    this.nextOfKinPhone,
    this.signatureUrl,
  });

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    final role = (data['roleTemplateId'] ??
            data['roleTemplateID'] ??
            data['role'] ??
            '')
        .toString()
        .trim();

    return UserProfile(
      uid: uid,
      email: (data['email'] ?? '').toString().trim(),
      fullName: (data['fullName'] ?? '').toString().trim(),
      roleTemplateId: role,
      status: (data['status'] ?? 'inactive').toString().trim(),
      teamId: data['teamId']?.toString(),
      programmeId: data['programmeId']?.toString(),
      phoneNumber: data['phoneNumber']?.toString(),
      physicalAddress: data['physicalAddress']?.toString(),
      idNumber: data['idNumber']?.toString(),
      nextOfKinName: data['nextOfKinName']?.toString(),
      nextOfKinRelationship: data['nextOfKinRelationship']?.toString(),
      nextOfKinPhone: data['nextOfKinPhone']?.toString(),
      signatureUrl: data['signatureUrl']?.toString(),
    );
  }
}
