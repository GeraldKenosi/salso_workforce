import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../widgets/salso_app_bar.dart';
import '../../../widgets/salso_card.dart';
import '../../../services/pdf_generator_service.dart';
import '../../../services/narrative_report_service.dart';
import '../../../app/theme.dart';
import 'narrative_report_stepper.dart';

class NarrativeReportDetailPage extends StatefulWidget {
  final String reportId;
  final Map<String, dynamic> reportData;
  const NarrativeReportDetailPage({super.key, required this.reportId, required this.reportData});

  @override
  State<NarrativeReportDetailPage> createState() => _NarrativeReportDetailPageState();
}

class _NarrativeReportDetailPageState extends State<NarrativeReportDetailPage> {
  bool _generating = false;

  Future<void> _generatePdf() async {
    setState(() => _generating = true);
    try {
      final pdfService = PdfGeneratorService();
      final bytes = await pdfService.generateNarrativeReportPdf(widget.reportData);
      final ref = FirebaseStorage.instance.ref('reports/narrative/${widget.reportId}.pdf');
      await ref.putData(bytes);
      final url = await ref.getDownloadURL();
      await FirebaseFirestore.instance.collection('narrativeReports').doc(widget.reportId).update({'pdfUrl': url});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF generated.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.reportData;
    final status = d['status'] ?? 'draft';
    final activity = d['activityName'] ?? '';
    final location = d['location'] ?? '';
    final dateMs = d['dateMs'] ?? 0;
    final date = dateMs > 0 ? DateTime.fromMillisecondsSinceEpoch(dateMs) : null;
    final showEdit = status == 'draft';

    return Scaffold(
      appBar: SalsoAppBar(
        title: Text(activity, style: const TextStyle(color: Colors.white)),
        actions: [
          if (showEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (_) => NarrativeReportStepper(existingDraftId: widget.reportId),
              )),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          _section('Activity', activity),
          _section('Location', location),
          _section('Date', date != null ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}' : ''),
          _section('Status', status.toUpperCase()),
          _section('Attendance Method', d['attendanceMethod'] ?? ''),

          if ((d['totalParticipants'] ?? 0) > 0) ...[
            const SizedBox(height: 16),
            const Text('Attendance', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            _section('Total', '${d['totalParticipants']}'),
            _section('Male', '${d['maleCount'] ?? 0}'),
            _section('Female', '${d['femaleCount'] ?? 0}'),
            _section('Youth', '${d['youthCount'] ?? 0}'),
            _section('Adults', '${d['adultsCount'] ?? 0}'),
            _section('Children', '${d['childrenCount'] ?? 0}'),
          ],

          if ((d['topicsCovered'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Programme Content', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            _section('Topics', d['topicsCovered']),
            if ((d['materialsUsed'] ?? '').isNotEmpty) _section('Materials', d['materialsUsed']),
            if ((d['activitiesConducted'] ?? '').isNotEmpty) _section('Activities', d['activitiesConducted']),
          ],

          if ((d['objectivesMet'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Outcomes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            _section('Objectives', d['objectivesMet']),
            if ((d['outcomesObserved'] ?? '').isNotEmpty) _section('Outcomes', d['outcomesObserved']),
            if ((d['beneficiaryImpact'] ?? '').isNotEmpty) _section('Impact', d['beneficiaryImpact']),
          ],

          if ((d['challengesFaced'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Challenges & Lessons', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            _section('Challenges', d['challengesFaced']),
            if ((d['lessonsLearned'] ?? '').isNotEmpty) _section('Lessons', d['lessonsLearned']),
          ],

          if ((d['beneficiaryFeedback'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Feedback', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            _section('Feedback', d['beneficiaryFeedback']),
            if ((d['recommendations'] ?? '').isNotEmpty) _section('Recommendations', d['recommendations']),
          ],

          if (d['photoUrls'] is List && (d['photoUrls'] as List).isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Photos', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: (d['photoUrls'] as List).length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(d['photoUrls'][i], width: 100, height: 100, fit: BoxFit.cover),
                ),
              ),
            ),
          ],

          if ((d['filerSignatureUrl'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Filer Signature', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(d['filerSignatureUrl'], height: 60, fit: BoxFit.contain),
            ),
          ],

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: _generating
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.picture_as_pdf),
              label: Text(_generating ? 'Generating...' : 'Generate PDF'),
              onPressed: _generating ? null : _generatePdf,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _section(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
