class AttendanceRegister {
  final String id;
  final String formattedName;
  final String? activityId;
  final String? reportId;
  final String status; // open | closed | late_additions
  final String activityName;
  final int activityDateMs;
  final String location;
  final String registerManagerName;
  final String attendanceMethod; // digital | physical | both
  final int totalParticipants;
  final int totalMen;
  final int totalWomen;
  final int totalPreferNotToSay;
  final int totalUnder18;
  final int total18to35;
  final int total36to59;
  final int total60plus;
  final int totalFirstTime;
  final int totalConsentGiven;
  final int createdAtMs;
  final String createdBy;
  final String createdByName;
  final int? closedAtMs;
  final String? closedBy;
  final int? lateAdditionsDeadlineMs;
  final String? qrCodeUrl;
  final String programmeId;
  final String teamId;

  AttendanceRegister({
    required this.id,
    required this.formattedName,
    this.activityId,
    this.reportId,
    required this.status,
    required this.activityName,
    required this.activityDateMs,
    required this.location,
    required this.registerManagerName,
    required this.attendanceMethod,
    this.totalParticipants = 0,
    this.totalMen = 0,
    this.totalWomen = 0,
    this.totalPreferNotToSay = 0,
    this.totalUnder18 = 0,
    this.total18to35 = 0,
    this.total36to59 = 0,
    this.total60plus = 0,
    this.totalFirstTime = 0,
    this.totalConsentGiven = 0,
    required this.createdAtMs,
    required this.createdBy,
    required this.createdByName,
    this.closedAtMs,
    this.closedBy,
    this.lateAdditionsDeadlineMs,
    this.qrCodeUrl,
    this.programmeId = '',
    this.teamId = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'formattedName': formattedName,
    'activityId': activityId,
    'reportId': reportId,
    'status': status,
    'activityName': activityName,
    'activityDateMs': activityDateMs,
    'location': location,
    'registerManagerName': registerManagerName,
    'attendanceMethod': attendanceMethod,
    'totalParticipants': totalParticipants,
    'totalMen': totalMen,
    'totalWomen': totalWomen,
    'totalPreferNotToSay': totalPreferNotToSay,
    'totalUnder18': totalUnder18,
    'total18to35': total18to35,
    'total36to59': total36to59,
    'total60plus': total60plus,
    'totalFirstTime': totalFirstTime,
    'totalConsentGiven': totalConsentGiven,
    'createdAtMs': createdAtMs,
    'createdBy': createdBy,
    'createdByName': createdByName,
    'closedAtMs': closedAtMs,
    'closedBy': closedBy,
    'lateAdditionsDeadlineMs': lateAdditionsDeadlineMs,
    'qrCodeUrl': qrCodeUrl,
    'programmeId': programmeId,
    'teamId': teamId,
  };

  factory AttendanceRegister.fromMap(Map<String, dynamic> m) => AttendanceRegister(
    id: m['id'] ?? '',
    formattedName: m['formattedName'] ?? '',
    activityId: m['activityId'],
    reportId: m['reportId'],
    status: m['status'] ?? 'open',
    activityName: m['activityName'] ?? '',
    activityDateMs: m['activityDateMs'] ?? 0,
    location: m['location'] ?? '',
    registerManagerName: m['registerManagerName'] ?? '',
    attendanceMethod: m['attendanceMethod'] ?? 'digital',
    totalParticipants: _toInt(m['totalParticipants']),
    totalMen: _toInt(m['totalMen']),
    totalWomen: _toInt(m['totalWomen']),
    totalPreferNotToSay: _toInt(m['totalPreferNotToSay']),
    totalUnder18: _toInt(m['totalUnder18']),
    total18to35: _toInt(m['total18to35']),
    total36to59: _toInt(m['total36to59']),
    total60plus: _toInt(m['total60plus']),
    totalFirstTime: _toInt(m['totalFirstTime']),
    totalConsentGiven: _toInt(m['totalConsentGiven']),
    createdAtMs: m['createdAtMs'] ?? 0,
    createdBy: m['createdBy'] ?? '',
    createdByName: m['createdByName'] ?? '',
    closedAtMs: m['closedAtMs'],
    closedBy: m['closedBy'],
    lateAdditionsDeadlineMs: m['lateAdditionsDeadlineMs'],
    qrCodeUrl: m['qrCodeUrl'],
    programmeId: m['programmeId'] ?? '',
    teamId: m['teamId'] ?? '',
  );

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}

class RegisterParticipant {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String gender; // man | woman | prefer_not_to_say
  final String ageGroup; // under_18 | 18_35 | 36_59 | 60_plus
  final String area;
  final bool firstTimeAtSALSO;
  final bool consentToContact;
  final int confirmedAtMs;
  final String registeredBy; // self | volunteer | qr
  final int registeredAtMs;
  final String? educationLevel;
  final String? employed;
  final String? trainingGoals;
  final bool? healthReferral;
  final bool? chronicIllness;
  final String? parentName;
  final String? parentPhone;

  RegisterParticipant({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.gender,
    required this.ageGroup,
    required this.area,
    required this.firstTimeAtSALSO,
    required this.consentToContact,
    required this.confirmedAtMs,
    required this.registeredBy,
    required this.registeredAtMs,
    this.educationLevel,
    this.employed,
    this.trainingGoals,
    this.healthReferral,
    this.chronicIllness,
    this.parentName,
    this.parentPhone,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'gender': gender,
    'ageGroup': ageGroup,
    'area': area,
    'firstTimeAtSALSO': firstTimeAtSALSO,
    'consentToContact': consentToContact,
    'confirmedAtMs': confirmedAtMs,
    'registeredBy': registeredBy,
    'registeredAtMs': registeredAtMs,
    'educationLevel': educationLevel,
    'employed': employed,
    'trainingGoals': trainingGoals,
    'healthReferral': healthReferral,
    'chronicIllness': chronicIllness,
    'parentName': parentName,
    'parentPhone': parentPhone,
  };

  factory RegisterParticipant.fromMap(Map<String, dynamic> m) => RegisterParticipant(
    id: m['id'] ?? '',
    fullName: m['fullName'] ?? '',
    phoneNumber: m['phoneNumber'] ?? '',
    gender: m['gender'] ?? 'prefer_not_to_say',
    ageGroup: m['ageGroup'] ?? '18_35',
    area: m['area'] ?? '',
    firstTimeAtSALSO: m['firstTimeAtSALSO'] ?? false,
    consentToContact: m['consentToContact'] ?? false,
    confirmedAtMs: m['confirmedAtMs'] ?? 0,
    registeredBy: m['registeredBy'] ?? 'volunteer',
    registeredAtMs: m['registeredAtMs'] ?? 0,
    educationLevel: m['educationLevel'],
    employed: m['employed'],
    trainingGoals: m['trainingGoals'],
    healthReferral: m['healthReferral'],
    chronicIllness: m['chronicIllness'],
    parentName: m['parentName'],
    parentPhone: m['parentPhone'],
  );
}
