import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../widgets/salso_app_bar.dart';
import '../../../services/narrative_report_service.dart';
import '../../../services/register_service.dart';
import '../../../services/file_upload_service.dart';
import '../../../widgets/signature_pad.dart';

class NarrativeReportStepper extends StatefulWidget {
  final String? existingDraftId;
  const NarrativeReportStepper({super.key, this.existingDraftId});

  @override
  State<NarrativeReportStepper> createState() => _NarrativeReportStepperState();
}

class _NarrativeReportStepperState extends State<NarrativeReportStepper> {
  int _currentStep = 0;
  bool _saving = false;
  bool _savingDraft = false;
  final _pageCtrl = PageController();

  // Page 1
  final _activityCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  String _attendanceMethod = 'physical'; // physical | digital | both
  String? _linkedRegisterId;

  // Page 2
  final _totalCtrl = TextEditingController();
  final _maleCtrl = TextEditingController();
  final _femaleCtrl = TextEditingController();
  final _youthCtrl = TextEditingController();
  final _adultsCtrl = TextEditingController();
  final _childrenCtrl = TextEditingController();

  // Page 3
  final _topicsCtrl = TextEditingController();
  final _materialsCtrl = TextEditingController();
  final _activitiesCtrl = TextEditingController();

  // Page 4
  final _objectivesCtrl = TextEditingController();
  final _outcomesCtrl = TextEditingController();
  final _impactCtrl = TextEditingController();

  // Page 5
  final _challengesCtrl = TextEditingController();
  final _lessonsCtrl = TextEditingController();

  // Page 6
  final _feedbackCtrl = TextEditingController();
  final _recommendationsCtrl = TextEditingController();

  // Page 7
  final List<String> _photoUrls = [];
  bool _uploadingPhoto = false;
  String? _filerSignatureUrl;
  final _additionalNotesCtrl = TextEditingController();

  @override
  void dispose() {
    _pageCtrl.dispose();
    _activityCtrl.dispose();
    _locationCtrl.dispose();
    _totalCtrl.dispose();
    _maleCtrl.dispose();
    _femaleCtrl.dispose();
    _youthCtrl.dispose();
    _adultsCtrl.dispose();
    _childrenCtrl.dispose();
    _topicsCtrl.dispose();
    _materialsCtrl.dispose();
    _activitiesCtrl.dispose();
    _objectivesCtrl.dispose();
    _outcomesCtrl.dispose();
    _impactCtrl.dispose();
    _challengesCtrl.dispose();
    _lessonsCtrl.dispose();
    _feedbackCtrl.dispose();
    _recommendationsCtrl.dispose();
    _additionalNotesCtrl.dispose();
    super.dispose();
  }

  bool get _allPagesValid {
    if (_activityCtrl.text.trim().isEmpty || _locationCtrl.text.trim().isEmpty) return false;
    if (_totalCtrl.text.trim().isEmpty) return false;
    if (_topicsCtrl.text.trim().isEmpty) return false;
    if (_objectivesCtrl.text.trim().isEmpty) return false;
    if (_challengesCtrl.text.trim().isEmpty) return false;
    if (_feedbackCtrl.text.trim().isEmpty) return false;
    return _filerSignatureUrl != null;
  }

  Future<void> _saveDraft() async {
    setState(() => _savingDraft = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final service = NarrativeReportService(FirebaseFirestore.instance, FirebaseAuth.instance);
      final data = _buildReportData(user.uid);
      data['status'] = 'draft';
      data['savedAsDraftAtMs'] = DateTime.now().millisecondsSinceEpoch;
      data['filerSignatureUrl'] = _filerSignatureUrl;

      await service.saveDraft(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saved.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _savingDraft = false);
    }
  }

  Future<void> _submit() async {
    if (!_allPagesValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete all required fields and sign before submitting.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final firestore = FirebaseFirestore.instance;
      final service = NarrativeReportService(firestore, FirebaseAuth.instance);
      final data = _buildReportData(user.uid);

      // Create linked register if method is digital or both
      if (_attendanceMethod != 'physical' && _linkedRegisterId == null) {
        final registerService = RegisterService(firestore, FirebaseAuth.instance);
        final regId = await registerService.createRegister(
          activityName: _activityCtrl.text.trim(),
          activityDateMs: _date.millisecondsSinceEpoch,
          location: _locationCtrl.text.trim(),
          registerManagerName: user.displayName ?? user.email ?? '',
          attendanceMethod: _attendanceMethod,
        );
        _linkedRegisterId = regId;
        data['linkedRegisterId'] = regId;
      }

      await service.submitReport(
        data: data,
        filerSignatureUrl: _filerSignatureUrl ?? '',
        filerSignatureName: user.displayName ?? user.email ?? '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted.')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Map<String, dynamic> _buildReportData(String uid) {
    return {
      'filerUid': uid,
      'activityName': _activityCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'dateMs': _date.millisecondsSinceEpoch,
      'attendanceMethod': _attendanceMethod,
      'linkedRegisterId': _linkedRegisterId,
      'totalParticipants': int.tryParse(_totalCtrl.text) ?? 0,
      'maleCount': int.tryParse(_maleCtrl.text) ?? 0,
      'femaleCount': int.tryParse(_femaleCtrl.text) ?? 0,
      'youthCount': int.tryParse(_youthCtrl.text) ?? 0,
      'adultsCount': int.tryParse(_adultsCtrl.text) ?? 0,
      'childrenCount': int.tryParse(_childrenCtrl.text) ?? 0,
      'topicsCovered': _topicsCtrl.text.trim(),
      'materialsUsed': _materialsCtrl.text.trim(),
      'activitiesConducted': _activitiesCtrl.text.trim(),
      'objectivesMet': _objectivesCtrl.text.trim(),
      'outcomesObserved': _outcomesCtrl.text.trim(),
      'beneficiaryImpact': _impactCtrl.text.trim(),
      'challengesFaced': _challengesCtrl.text.trim(),
      'lessonsLearned': _lessonsCtrl.text.trim(),
      'beneficiaryFeedback': _feedbackCtrl.text.trim(),
      'recommendations': _recommendationsCtrl.text.trim(),
      'photoUrls': _photoUrls,
      'additionalNotes': _additionalNotesCtrl.text.trim(),
    };
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (file == null) return;

    setState(() => _uploadingPhoto = true);
    try {
      final bytes = await file.readAsBytes();
      final uploadService = FileUploadService(FirebaseStorage.instance);
      final url = await uploadService.uploadFile(
        bytes: bytes,
        folder: 'narrativePhotos',
        fileName: '${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      setState(() => _photoUrls.add(url));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload error: $e')));
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _showSignaturePad() async {
    Uint8List? signatureBytes;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: SignaturePad(
          onSign: (bytes) => signatureBytes = bytes,
        ),
      ),
    );
    if (signatureBytes == null) return;
    try {
      final uploadService = FileUploadService(FirebaseStorage.instance);
      final url = await uploadService.uploadFile(
        bytes: signatureBytes!,
        folder: 'signatures',
        fileName: 'report_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      setState(() => _filerSignatureUrl = url);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signature upload error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SalsoAppBar(
        title: const Text('Narrative Report', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: _savingDraft ? null : _saveDraft,
            child: _savingDraft
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save Draft', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _currentStep < 6
            ? () => setState(() => _currentStep++)
            : _submit,
        onStepCancel: _currentStep > 0
            ? () => setState(() => _currentStep--)
            : null,
        controlsBuilder: (ctx, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                if (_currentStep < 6)
                  ElevatedButton(
                    onPressed: _saving ? null : details.onStepContinue,
                    child: _saving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_currentStep == 6 ? 'Submit' : 'Continue'),
                  )
                else
                  ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Submit'),
                  ),
                const SizedBox(width: 12),
                if (_currentStep > 0)
                  TextButton(onPressed: details.onStepCancel, child: const Text('Back')),
              ],
            ),
          );
        },
        steps: [
          Step(title: const Text('Basic Info'), isActive: _currentStep >= 0, content: _page1()),
          Step(title: const Text('Attendance'), isActive: _currentStep >= 1, content: _page2()),
          Step(title: const Text('Content'), isActive: _currentStep >= 2, content: _page3()),
          Step(title: const Text('Outcomes'), isActive: _currentStep >= 3, content: _page4()),
          Step(title: const Text('Challenges'), isActive: _currentStep >= 4, content: _page5()),
          Step(title: const Text('Feedback'), isActive: _currentStep >= 5, content: _page6()),
          Step(title: const Text('Photos & Sign'), isActive: _currentStep >= 6, content: _page7()),
        ],
      ),
    );
  }

  Widget _page1() {
    return Column(
      children: [
        TextField(controller: _activityCtrl, decoration: const InputDecoration(labelText: 'Activity Name *')),
        const SizedBox(height: 12),
        TextField(controller: _locationCtrl, decoration: const InputDecoration(labelText: 'Location *')),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Date: ${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2030));
            if (picked != null) setState(() => _date = picked);
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _attendanceMethod,
          decoration: const InputDecoration(labelText: 'Attendance Method'),
          items: const [
            DropdownMenuItem(value: 'physical', child: Text('Physical')),
            DropdownMenuItem(value: 'digital', child: Text('Digital (Register)')),
            DropdownMenuItem(value: 'both', child: Text('Both')),
          ],
          onChanged: (v) => setState(() => _attendanceMethod = v ?? 'physical'),
        ),
      ],
    );
  }

  Widget _page2() {
    return Column(
      children: [
        TextField(controller: _totalCtrl, decoration: const InputDecoration(labelText: 'Total Participants *'), keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        TextField(controller: _maleCtrl, decoration: const InputDecoration(labelText: 'Male'), keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        TextField(controller: _femaleCtrl, decoration: const InputDecoration(labelText: 'Female'), keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        TextField(controller: _youthCtrl, decoration: const InputDecoration(labelText: 'Youth (18-35)'), keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        TextField(controller: _adultsCtrl, decoration: const InputDecoration(labelText: 'Adults (36+)'), keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        TextField(controller: _childrenCtrl, decoration: const InputDecoration(labelText: 'Children (<18)'), keyboardType: TextInputType.number),
      ],
    );
  }

  Widget _page3() {
    return Column(
      children: [
        TextField(controller: _topicsCtrl, decoration: const InputDecoration(labelText: 'Topics Covered *'), maxLines: 3),
        const SizedBox(height: 12),
        TextField(controller: _materialsCtrl, decoration: const InputDecoration(labelText: 'Materials Used'), maxLines: 3),
        const SizedBox(height: 12),
        TextField(controller: _activitiesCtrl, decoration: const InputDecoration(labelText: 'Activities Conducted'), maxLines: 3),
      ],
    );
  }

  Widget _page4() {
    return Column(
      children: [
        TextField(controller: _objectivesCtrl, decoration: const InputDecoration(labelText: 'Objectives Met *'), maxLines: 3),
        const SizedBox(height: 12),
        TextField(controller: _outcomesCtrl, decoration: const InputDecoration(labelText: 'Outcomes Observed'), maxLines: 3),
        const SizedBox(height: 12),
        TextField(controller: _impactCtrl, decoration: const InputDecoration(labelText: 'Beneficiary Impact'), maxLines: 3),
      ],
    );
  }

  Widget _page5() {
    return Column(
      children: [
        TextField(controller: _challengesCtrl, decoration: const InputDecoration(labelText: 'Challenges Faced *'), maxLines: 4),
        const SizedBox(height: 12),
        TextField(controller: _lessonsCtrl, decoration: const InputDecoration(labelText: 'Lessons Learned'), maxLines: 4),
      ],
    );
  }

  Widget _page6() {
    return Column(
      children: [
        TextField(controller: _feedbackCtrl, decoration: const InputDecoration(labelText: 'Beneficiary Feedback *'), maxLines: 4),
        const SizedBox(height: 12),
        TextField(controller: _recommendationsCtrl, decoration: const InputDecoration(labelText: 'Recommendations'), maxLines: 4),
      ],
    );
  }

  Widget _page7() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Photos', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (_photoUrls.isNotEmpty) ...[
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _photoUrls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(_photoUrls[i], width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 0, right: 0,
                    child: GestureDetector(
                      onTap: () => setState(() => _photoUrls.removeAt(i)),
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          icon: _uploadingPhoto
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.camera_alt),
          label: Text(_uploadingPhoto ? 'Uploading...' : 'Add Photo'),
          onPressed: _uploadingPhoto ? null : _pickPhoto,
        ),
        const SizedBox(height: 12),
        TextField(controller: _additionalNotesCtrl, decoration: const InputDecoration(labelText: 'Additional Notes'), maxLines: 3),
        const SizedBox(height: 12),
        const Text('Filer Signature *', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (_filerSignatureUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(_filerSignatureUrl!, height: 60, fit: BoxFit.contain),
          ),
          TextButton(
            onPressed: () => setState(() => _filerSignatureUrl = null),
            child: const Text('Clear & Re-sign'),
          ),
        ] else
          ElevatedButton.icon(
            icon: const Icon(Icons.draw),
            label: const Text('Sign Now'),
            onPressed: _showSignaturePad,
          ),
      ],
    );
  }
}
