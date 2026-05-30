import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/attendance_register.dart';

class RegisterService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final _uuid = const Uuid();

  static const String collection = 'attendanceRegisters';

  RegisterService(this._db, this._auth);

  Future<String> createRegister({
    required String activityName,
    required int activityDateMs,
    required String location,
    required String registerManagerName,
    required String attendanceMethod,
    String? activityId,
    String? reportId,
    String programmeId = '',
    String teamId = '',
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final userDoc = await _db.collection('users').doc(user.uid).get();
    final displayName = (userDoc.data()?['fullName'] ?? user.email ?? '').toString();

    final dateStr = DateTime.fromMillisecondsSinceEpoch(activityDateMs);
    final formattedDate = '${dateStr.year}-${dateStr.month.toString().padLeft(2, '0')}-${dateStr.day.toString().padLeft(2, '0')}';
    final formattedName = '$formattedDate $activityName - $location';

    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final qrUrl = 'https://salso.org.za/r/$id';

    final reg = AttendanceRegister(
      id: id,
      formattedName: formattedName,
      activityId: activityId,
      reportId: reportId,
      status: 'open',
      activityName: activityName,
      activityDateMs: activityDateMs,
      location: location,
      registerManagerName: registerManagerName,
      attendanceMethod: attendanceMethod,
      createdAtMs: now,
      createdBy: user.uid,
      createdByName: displayName,
      qrCodeUrl: qrUrl,
      programmeId: programmeId,
      teamId: teamId,
    );

    await _db.collection(collection).doc(id).set(reg.toMap());
    return id;
  }

  Future<void> addParticipant({
    required String registerId,
    required String fullName,
    required String phoneNumber,
    required String gender,
    required String ageGroup,
    required String area,
    required bool firstTimeAtSALSO,
    required bool consentToContact,
    String registeredBy = 'volunteer',
    String? educationLevel,
    String? employed,
    String? trainingGoals,
    bool? healthReferral,
    bool? chronicIllness,
    String? parentName,
    String? parentPhone,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = _uuid.v4();

    final participant = RegisterParticipant(
      id: id,
      fullName: fullName,
      phoneNumber: phoneNumber,
      gender: gender,
      ageGroup: ageGroup,
      area: area,
      firstTimeAtSALSO: firstTimeAtSALSO,
      consentToContact: consentToContact,
      confirmedAtMs: now,
      registeredBy: registeredBy,
      registeredAtMs: now,
      educationLevel: educationLevel,
      employed: employed,
      trainingGoals: trainingGoals,
      healthReferral: healthReferral,
      chronicIllness: chronicIllness,
      parentName: parentName,
      parentPhone: parentPhone,
    );

    await _db.collection(collection).doc(registerId).collection('participants').doc(id).set(participant.toMap());
    await _incrementCounts(registerId, gender, ageGroup, firstTimeAtSALSO, consentToContact);
  }

  Future<void> _incrementCounts(String registerId, String gender, String ageGroup, bool firstTime, bool consent) async {
    final inc = <String, dynamic>{
      'totalParticipants': FieldValue.increment(1),
    };
    if (gender == 'man') inc['totalMen'] = FieldValue.increment(1);
    else if (gender == 'woman') inc['totalWomen'] = FieldValue.increment(1);
    else inc['totalPreferNotToSay'] = FieldValue.increment(1);

    if (ageGroup == 'under_18') inc['totalUnder18'] = FieldValue.increment(1);
    else if (ageGroup == '18_35') inc['total18to35'] = FieldValue.increment(1);
    else if (ageGroup == '36_59') inc['total36to59'] = FieldValue.increment(1);
    else inc['total60plus'] = FieldValue.increment(1);

    if (firstTime) inc['totalFirstTime'] = FieldValue.increment(1);
    if (consent) inc['totalConsentGiven'] = FieldValue.increment(1);

    await _db.collection(collection).doc(registerId).update(inc);
  }

  Future<void> closeRegister(String registerId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final deadline = now + 24 * 60 * 60 * 1000;
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection(collection).doc(registerId).update({
      'status': 'closed',
      'closedAtMs': now,
      'closedBy': user.uid,
      'lateAdditionsDeadlineMs': deadline,
    });
  }

  Future<void> reopenForLateAdditions(String registerId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final deadline = now + 24 * 60 * 60 * 1000;
    await _db.collection(collection).doc(registerId).update({
      'status': 'late_additions',
      'lateAdditionsDeadlineMs': deadline,
    });
  }

  Future<void> finalizeRegister(String registerId) async {
    await _db.collection(collection).doc(registerId).update({
      'status': 'closed',
      'lateAdditionsDeadlineMs': null,
    });
  }

  Future<void> linkToReport(String registerId, String reportId) async {
    await _db.collection(collection).doc(registerId).update({'reportId': reportId});
  }

  Stream<AttendanceRegister?> streamRegister(String id) {
    return _db.collection(collection).doc(id).snapshots()
        .map((s) => s.exists ? AttendanceRegister.fromMap(s.data()!) : null);
  }

  Stream<List<AttendanceRegister>> streamMyRegisters() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _db
        .collection(collection)
        .where('createdBy', isEqualTo: user.uid)
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => AttendanceRegister.fromMap(d.data())).toList());
  }

  Stream<List<AttendanceRegister>> streamActiveRegisters() {
    return _db
        .collection(collection)
        .where('status', whereIn: ['open', 'late_additions'])
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => AttendanceRegister.fromMap(d.data())).toList());
  }

  Stream<List<RegisterParticipant>> streamParticipants(String registerId) {
    return _db
        .collection(collection).doc(registerId)
        .collection('participants')
        .orderBy('registeredAtMs', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => RegisterParticipant.fromMap(d.data())).toList());
  }
}
