class NarrativeReport {
  final String id;
  final String userId;
  final String programmeId;
  final String teamId;
  final String status; // draft | submitted | approved | signed_off

  // Page 1: Basic Activity Information
  final String activityName;
  final String activityType;
  final int startDateMs;
  final int endDateMs;
  final String location;
  final String organiser;
  final bool planned;
  final String attendanceMethod; // digital | physical | both
  final String? linkedRegisterId;

  // Page 2: People Reached
  final int totalParticipants;
  final int men;
  final int women;
  final int otherGender;
  final int under18;
  final int age18to35;
  final int age36to59;
  final int age60plus;
  final String participantOrigins;
  final bool hasVulnerableGroups;
  final String vulnerableGroupDescription;
  final int salsoVolunteersInvolved;
  final int outsidePartners;

  // Page 3: What You Did
  final String activityDescription;
  final String mainGoal;
  final String topicsCovered;
  final String materialsUsed;
  final bool hadPartnerOrgs;
  final String partnerDetails;

  // Page 4: Results and Impact
  final String whatWentWell;
  final String whatDidNotGoWell;
  final String participantChanges;
  final String participantStory;
  final bool hasFeedback;
  final String feedbackSummary;
  final double satisfactionScore;

  // Page 5: Money and Resources
  final double totalCost;
  final String fundingSource;
  final bool hasDonations;
  final String donationDetails;
  final double estimatedDonationValue;
  final double costPerPerson;

  // Page 6: Photos and Documents
  final List<String> photoUrls;
  final List<String> registerUrls;
  final List<String> feedbackFormUrls;
  final List<String> supportingDocUrls;

  // Page 7: Final Reflections
  final String wouldRunAgain;
  final String changesWithMoreResources;
  final String nextSteps;
  final String additionalInfo;

  // Signature
  final String? filerSignatureUrl;
  final String? filerSignatureName;

  // Approval fields
  final String? reviewedBy;
  final int? reviewedAtMs;
  final String? decisionReason;
  final String? signedOffBy;
  final int? signedOffAtMs;
  final String? signOffComment;
  final String? signOffSignatureUrl;
  final String? pdfUrl;

  // Timestamps
  final int createdAtMs;
  final int updatedAtMs;

  NarrativeReport({
    required this.id,
    required this.userId,
    this.programmeId = '',
    this.teamId = '',
    required this.status,
    required this.activityName,
    required this.activityType,
    required this.startDateMs,
    required this.endDateMs,
    required this.location,
    this.organiser = '',
    this.planned = true,
    this.attendanceMethod = 'digital',
    this.linkedRegisterId,
    this.totalParticipants = 0,
    this.men = 0,
    this.women = 0,
    this.otherGender = 0,
    this.under18 = 0,
    this.age18to35 = 0,
    this.age36to59 = 0,
    this.age60plus = 0,
    this.participantOrigins = '',
    this.hasVulnerableGroups = false,
    this.vulnerableGroupDescription = '',
    this.salsoVolunteersInvolved = 0,
    this.outsidePartners = 0,
    this.activityDescription = '',
    this.mainGoal = '',
    this.topicsCovered = '',
    this.materialsUsed = '',
    this.hadPartnerOrgs = false,
    this.partnerDetails = '',
    this.whatWentWell = '',
    this.whatDidNotGoWell = '',
    this.participantChanges = '',
    this.participantStory = '',
    this.hasFeedback = false,
    this.feedbackSummary = '',
    this.satisfactionScore = 0,
    this.totalCost = 0,
    this.fundingSource = '',
    this.hasDonations = false,
    this.donationDetails = '',
    this.estimatedDonationValue = 0,
    this.costPerPerson = 0,
    this.photoUrls = const [],
    this.registerUrls = const [],
    this.feedbackFormUrls = const [],
    this.supportingDocUrls = const [],
    this.wouldRunAgain = '',
    this.changesWithMoreResources = '',
    this.nextSteps = '',
    this.additionalInfo = '',
    this.filerSignatureUrl,
    this.filerSignatureName,
    this.reviewedBy,
    this.reviewedAtMs,
    this.decisionReason,
    this.signedOffBy,
    this.signedOffAtMs,
    this.signOffComment,
    this.signOffSignatureUrl,
    this.pdfUrl,
    required this.createdAtMs,
    required this.updatedAtMs,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'userId': userId, 'programmeId': programmeId, 'teamId': teamId,
    'status': status, 'activityName': activityName, 'activityType': activityType,
    'startDateMs': startDateMs, 'endDateMs': endDateMs, 'location': location,
    'organiser': organiser, 'planned': planned, 'attendanceMethod': attendanceMethod,
    'linkedRegisterId': linkedRegisterId,
    'totalParticipants': totalParticipants, 'men': men, 'women': women,
    'otherGender': otherGender, 'under18': under18, 'age18to35': age18to35,
    'age36to59': age36to59, 'age60plus': age60plus,
    'participantOrigins': participantOrigins,
    'hasVulnerableGroups': hasVulnerableGroups,
    'vulnerableGroupDescription': vulnerableGroupDescription,
    'salsoVolunteersInvolved': salsoVolunteersInvolved,
    'outsidePartners': outsidePartners,
    'activityDescription': activityDescription, 'mainGoal': mainGoal,
    'topicsCovered': topicsCovered, 'materialsUsed': materialsUsed,
    'hadPartnerOrgs': hadPartnerOrgs, 'partnerDetails': partnerDetails,
    'whatWentWell': whatWentWell, 'whatDidNotGoWell': whatDidNotGoWell,
    'participantChanges': participantChanges, 'participantStory': participantStory,
    'hasFeedback': hasFeedback, 'feedbackSummary': feedbackSummary,
    'satisfactionScore': satisfactionScore, 'totalCost': totalCost,
    'fundingSource': fundingSource, 'hasDonations': hasDonations,
    'donationDetails': donationDetails, 'estimatedDonationValue': estimatedDonationValue,
    'costPerPerson': costPerPerson,
    'photoUrls': photoUrls, 'registerUrls': registerUrls,
    'feedbackFormUrls': feedbackFormUrls, 'supportingDocUrls': supportingDocUrls,
    'wouldRunAgain': wouldRunAgain, 'changesWithMoreResources': changesWithMoreResources,
    'nextSteps': nextSteps, 'additionalInfo': additionalInfo,
    'filerSignatureUrl': filerSignatureUrl, 'filerSignatureName': filerSignatureName,
    'reviewedBy': reviewedBy, 'reviewedAtMs': reviewedAtMs,
    'decisionReason': decisionReason, 'signedOffBy': signedOffBy,
    'signedOffAtMs': signedOffAtMs, 'signOffComment': signOffComment,
    'signOffSignatureUrl': signOffSignatureUrl, 'pdfUrl': pdfUrl,
    'createdAtMs': createdAtMs, 'updatedAtMs': updatedAtMs,
  };

  factory NarrativeReport.fromMap(Map<String, dynamic> m) => NarrativeReport(
    id: m['id'] ?? '', userId: m['userId'] ?? '',
    programmeId: m['programmeId'] ?? '', teamId: m['teamId'] ?? '',
    status: m['status'] ?? 'draft',
    activityName: m['activityName'] ?? '', activityType: m['activityType'] ?? '',
    startDateMs: _toInt(m['startDateMs']), endDateMs: _toInt(m['endDateMs']),
    location: m['location'] ?? '', organiser: m['organiser'] ?? '',
    planned: m['planned'] ?? true, attendanceMethod: m['attendanceMethod'] ?? 'digital',
    linkedRegisterId: m['linkedRegisterId'],
    totalParticipants: _toInt(m['totalParticipants']), men: _toInt(m['men']),
    women: _toInt(m['women']), otherGender: _toInt(m['otherGender']),
    under18: _toInt(m['under18']), age18to35: _toInt(m['age18to35']),
    age36to59: _toInt(m['age36to59']), age60plus: _toInt(m['age60plus']),
    participantOrigins: m['participantOrigins'] ?? '',
    hasVulnerableGroups: m['hasVulnerableGroups'] ?? false,
    vulnerableGroupDescription: m['vulnerableGroupDescription'] ?? '',
    salsoVolunteersInvolved: _toInt(m['salsoVolunteersInvolved']),
    outsidePartners: _toInt(m['outsidePartners']),
    activityDescription: m['activityDescription'] ?? '',
    mainGoal: m['mainGoal'] ?? '', topicsCovered: m['topicsCovered'] ?? '',
    materialsUsed: m['materialsUsed'] ?? '',
    hadPartnerOrgs: m['hadPartnerOrgs'] ?? false,
    partnerDetails: m['partnerDetails'] ?? '',
    whatWentWell: m['whatWentWell'] ?? '',
    whatDidNotGoWell: m['whatDidNotGoWell'] ?? '',
    participantChanges: m['participantChanges'] ?? '',
    participantStory: m['participantStory'] ?? '',
    hasFeedback: m['hasFeedback'] ?? false,
    feedbackSummary: m['feedbackSummary'] ?? '',
    satisfactionScore: _toDouble(m['satisfactionScore']),
    totalCost: _toDouble(m['totalCost']), fundingSource: m['fundingSource'] ?? '',
    hasDonations: m['hasDonations'] ?? false,
    donationDetails: m['donationDetails'] ?? '',
    estimatedDonationValue: _toDouble(m['estimatedDonationValue']),
    costPerPerson: _toDouble(m['costPerPerson']),
    photoUrls: _toStrList(m['photoUrls']),
    registerUrls: _toStrList(m['registerUrls']),
    feedbackFormUrls: _toStrList(m['feedbackFormUrls']),
    supportingDocUrls: _toStrList(m['supportingDocUrls']),
    wouldRunAgain: m['wouldRunAgain'] ?? '',
    changesWithMoreResources: m['changesWithMoreResources'] ?? '',
    nextSteps: m['nextSteps'] ?? '', additionalInfo: m['additionalInfo'] ?? '',
    filerSignatureUrl: m['filerSignatureUrl'],
    filerSignatureName: m['filerSignatureName'],
    reviewedBy: m['reviewedBy'], reviewedAtMs: _toIntOrNull(m['reviewedAtMs']),
    decisionReason: m['decisionReason'], signedOffBy: m['signedOffBy'],
    signedOffAtMs: _toIntOrNull(m['signedOffAtMs']),
    signOffComment: m['signOffComment'],
    signOffSignatureUrl: m['signOffSignatureUrl'],
    pdfUrl: m['pdfUrl'],
    createdAtMs: _toInt(m['createdAtMs']), updatedAtMs: _toInt(m['updatedAtMs']),
  );

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static int? _toIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static List<String> _toStrList(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }
}
