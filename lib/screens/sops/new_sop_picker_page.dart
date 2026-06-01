import 'package:flutter/material.dart';
import '../../models/sop_form_config.dart';
import '../../widgets/salso_card.dart';
import '../../app/theme.dart';
import 'sop_form_page.dart';

class NewSopPickerPage extends StatelessWidget {
  final String roleTemplateId;

  const NewSopPickerPage({super.key, required this.roleTemplateId});

  static const _categories = [
    ('Finance', Icons.account_balance, ['reimbursement', 'procurement', 'budgetTransfer']),
    ('Operations', Icons.build, ['travel', 'venueBooking', 'equipmentRequest', 'vehicleRequest', 'itSupport']),
    ('HR & Staff', Icons.people, ['leave', 'trainingNomination', 'newPosition', 'termination', 'disciplinary', 'volunteerPlacement']),
    ('Programmes', Icons.event, ['activityProposal', 'incidentReport', 'partnershipProposal', 'mediaRequest']),
    ('Other', Icons.more_horiz, ['attendanceCorrection', 'general']),
  ];

  bool _canSubmit(String submitterRole) {
    if (submitterRole == 'all') return true;
    return submitterRole == roleTemplateId;
  }

  IconData _parseIcon(String iconName) {
    switch (iconName) {
      case 'vacation': return Icons.beach_access;
      case 'receipt_long': return Icons.receipt_long;
      case 'flight': return Icons.flight;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'event': return Icons.event;
      case 'location_on': return Icons.location_on;
      case 'handyman': return Icons.handyman;
      case 'computer': return Icons.computer;
      case 'school': return Icons.school;
      case 'warning': return Icons.warning;
      case 'directions_car': return Icons.directions_car;
      case 'swap_horiz': return Icons.swap_horiz;
      case 'person_add': return Icons.person_add;
      case 'person_remove': return Icons.person_remove;
      case 'gavel': return Icons.gavel;
      case 'handshake': return Icons.handshake;
      case 'campaign': return Icons.campaign;
      case 'diversity_3': return Icons.diversity_3;
      case 'edit_calendar': return Icons.edit_calendar;
      default: return Icons.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: SalsoTheme.primary,
              borderRadius: BorderRadius.zero,
            ),
            padding: const EdgeInsets.fromLTRB(60, 48, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('New Request', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                        Text('Select a form type', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ..._categories.map((cat) {
            final name = cat.$1;
            final icon = cat.$2;
            final types = cat.$3;
            final items = types.map((t) => SopFormConfig.fromType(t)).where((c) => c != null && _canSubmit(c!.submitterRole)).cast<SopFormConfig>().toList();
            if (items.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.grey[800])),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...items.map((cfg) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: SalsoCard(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SopFormPage(type: cfg.type))),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: SalsoTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: Icon(_parseIcon(cfg.icon), color: SalsoTheme.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cfg.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                Text(cfg.description, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
