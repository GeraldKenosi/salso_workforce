import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../widgets/salso_app_bar.dart';
import '../../widgets/signature_pad.dart';
import '../../services/workflow_service.dart';
import '../../services/file_upload_service.dart';
import '../../models/sop_form_config.dart';

class SopFormPage extends StatefulWidget {
  final String type;
  const SopFormPage({super.key, required this.type});

  @override
  State<SopFormPage> createState() => _SopFormPageState();
}

class _SopFormPageState extends State<SopFormPage> {
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _additionalCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  String? _filerSignatureUrl;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _amountCtrl.dispose();
    _dateCtrl.dispose();
    _locationCtrl.dispose();
    _additionalCtrl.dispose();
    super.dispose();
  }

  String _formHint(String field) {
    switch (widget.type) {
      case 'leave': return field == 'title' ? 'Leave type (Annual/Sick/Personal)' : 'Reason for leave and dates';
      case 'reimbursement': return field == 'title' ? 'Expense description' : 'Amount and receipts attached?';
      case 'travel': return field == 'title' ? 'Destination and purpose' : 'Travel dates and estimated cost';
      case 'procurement': return field == 'title' ? 'Item to procure' : 'Quantity, specifications, budget code';
      case 'activityProposal': return field == 'title' ? 'Activity name' : 'Describe the activity objectives and plan';
      case 'venueBooking': return field == 'title' ? 'Venue name' : 'Capacity, date, equipment needs';
      case 'equipmentRequest': return field == 'title' ? 'Equipment needed' : 'Why and for how long?';
      case 'itSupport': return field == 'title' ? 'Issue summary' : 'Describe the IT issue in detail';
      case 'trainingNomination': return field == 'title' ? 'Training course name' : 'Staff member, cost, dates';
      case 'incidentReport': return field == 'title' ? 'Incident type' : 'Date, location, description, people involved';
      case 'vehicleRequest': return field == 'title' ? 'Vehicle needed for' : 'Date, destination, driver, passengers';
      case 'budgetTransfer': return field == 'title' ? 'Transfer from/to budget lines' : 'Amount and reason for transfer';
      case 'newPosition': return field == 'title' ? 'Position title' : 'Duties, reporting line, budget, justification';
      case 'termination': return field == 'title' ? 'Employee name' : 'Reason, last working day, handover plan';
      case 'disciplinary': return field == 'title' ? 'Staff member name' : 'Nature of issue, evidence attached';
      case 'partnershipProposal': return field == 'title' ? 'Partner/org name' : 'Proposal details and expected outcomes';
      case 'mediaRequest': return field == 'title' ? 'Type of media support' : 'Event, audience, platform, deadline';
      case 'volunteerPlacement': return field == 'title' ? 'Volunteer name' : 'Site, duration, supervision, tasks';
      case 'attendanceCorrection': return field == 'title' ? 'Date of correction' : 'Correct clock-out time and reason';
      default: return field == 'title' ? 'Request title' : 'Describe your request in detail';
    }
  }

  List<String> get _showAmounts => ['reimbursement', 'travel', 'vehicleRequest', 'budgetTransfer', 'procurement'];
  List<String> get _showDates => ['travel', 'leave', 'trainingNomination', 'incidentReport', 'vehicleRequest', 'attendanceCorrection'];
  List<String> get _showLocations => ['travel', 'venueBooking', 'incidentReport', 'vehicleRequest', 'activityProposal', 'volunteerPlacement'];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_filerSignatureUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign before submitting.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final service = WorkflowService(FirebaseFirestore.instance, FirebaseAuth.instance);

      // Build approval steps as List<String>
      final List<String> steps;
      switch (widget.type) {
        case 'leave':
          steps = ['teamLeader_approval', 'manager_approval', 'ed_approval'];
          break;
        case 'termination': case 'disciplinary': case 'partnershipProposal': case 'newPosition':
          steps = ['manager_review', 'ed_approval', 'admin_processing'];
          break;
        case 'reimbursement': case 'procurement':
          steps = ['manager_approval', 'ed_approval', 'finance_processing'];
          break;
        case 'attendanceCorrection':
          steps = ['tl_review', 'manager_approval'];
          break;
        default:
          steps = ['tl_review', 'manager_approval'];
      }

      final requestData = {
        'description': _descriptionCtrl.text.trim(),
        'date': _dateCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'additionalInfo': _additionalCtrl.text.trim(),
        'type': widget.type,
        'filerName': user.displayName ?? user.email ?? '',
        'filerSignatureUrl': _filerSignatureUrl,
      };

      await service.createRequest(
        sopCategory: 'standard',
        sopType: widget.type,
        title: _titleCtrl.text.trim(),
        data: requestData,
        approvalSteps: steps,
        amount: double.tryParse(_amountCtrl.text) ?? 0,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
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
        fileName: 'sop_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      setState(() => _filerSignatureUrl = url);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signature upload error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfg = SopFormConfig.fromType(widget.type);
    final label = cfg?.label ?? widget.type;
    final showAmount = _showAmounts.contains(widget.type);
    final showDate = _showDates.contains(widget.type);
    final showLocation = _showLocations.contains(widget.type);

    return Scaffold(
      appBar: SalsoAppBar(title: Text('New $label', style: const TextStyle(color: Colors.white))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('${cfg?.description ?? ''} — fields marked * are required.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 16),

            TextFormField(
              controller: _titleCtrl,
              decoration: InputDecoration(labelText: '* ${_formHint('title')}'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _descriptionCtrl,
              decoration: InputDecoration(labelText: '* ${_formHint('description')}'),
              maxLines: 4,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            if (showAmount) ...[
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(labelText: 'Amount (ZAR)', prefixText: 'R '),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
            ],
            if (showDate) ...[
              TextFormField(
                controller: _dateCtrl,
                decoration: const InputDecoration(labelText: 'Date(s)', hintText: 'YYYY-MM-DD or range'),
              ),
              const SizedBox(height: 12),
            ],
            if (showLocation) ...[
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 12),
            ],

            TextFormField(
              controller: _additionalCtrl,
              decoration: const InputDecoration(labelText: 'Additional Information'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            const Text('Your Signature *', style: TextStyle(fontWeight: FontWeight.w600)),
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
                label: const Text('Sign & Submit'),
                onPressed: _showSignaturePad,
              ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Submit Request'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
