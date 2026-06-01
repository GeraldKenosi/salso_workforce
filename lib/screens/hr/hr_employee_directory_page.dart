import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../state/session_provider.dart';
import '../../utils/display_labels.dart';
import '../../widgets/salso_card.dart';
import '../../app/theme.dart';

class HrEmployeeDirectoryPage extends StatefulWidget {
  const HrEmployeeDirectoryPage({super.key});

  @override
  State<HrEmployeeDirectoryPage> createState() => _HrEmployeeDirectoryPageState();
}

class _HrEmployeeDirectoryPageState extends State<HrEmployeeDirectoryPage> {
  String _searchQuery = '';
  String _roleFilter = '';
  Timer? _debounce;

  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  static const _roleTabs = [
    ('', 'All'),
    ('volunteer', 'Volunteers'),
    ('coordinator', 'Coordinators'),
    ('teamLeader', 'Team Leaders'),
    ('manager', 'Managers'),
    ('admin', 'Admin'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Directory')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (v) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), () {
                  setState(() => _searchQuery = v.toLowerCase().trim());
                });
              },
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _roleTabs.map((entry) {
                final key = entry.$1;
                final label = entry.$2;
                final active = _roleFilter == key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(label, style: TextStyle(fontSize: 12, fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
                    selected: active,
                    onSelected: (_) => setState(() => _roleFilter = key),
                    selectedColor: SalsoTheme.primary.withValues(alpha: 0.15),
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(color: active ? SalsoTheme.primary : Colors.grey[700]),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.red)),
                    ),
                  );
                }

                var docs = snap.data?.docs ?? [];

                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((d) {
                    final data = d.data();
                    final name = (data['fullName'] ?? '').toString().toLowerCase();
                    final email = (data['email'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery) || email.contains(_searchQuery);
                  }).toList();
                }

                if (_roleFilter.isNotEmpty) {
                  docs = docs.where((d) {
                    final role = (d.data()['roleTemplateId'] ?? '').toString();
                    return role == _roleFilter;
                  }).toList();
                }

                docs.sort((a, b) {
                  final aName = (a.data()['fullName'] ?? '').toString();
                  final bName = (b.data()['fullName'] ?? '').toString();
                  return aName.compareTo(bName);
                });

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline, size: 56, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('No employees found', style: TextStyle(fontSize: 15, color: Colors.grey[600])),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (ctx, i) {
                    final data = docs[i].data();
                    final fullName = (data['fullName'] ?? 'Unknown').toString();
                    final email = (data['email'] ?? '').toString();
                    final role = (data['roleTemplateId'] ?? '').toString();
                    final status = (data['status'] ?? 'active').toString();
                    final programme = (data['programmeId'] ?? '').toString();
                    final phone = (data['phoneNumber'] ?? '').toString();
                    final idNumber = (data['idNumber'] ?? '').toString();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SalsoCard(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: SalsoTheme.primary.withValues(alpha: 0.1),
                                    child: Text(
                                      fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                                      style: const TextStyle(color: SalsoTheme.primary, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                        const SizedBox(height: 2),
                                        Text(email, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: status == 'active'
                                          ? Colors.green.withValues(alpha: 0.1)
                                          : Colors.orange.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: status == 'active' ? Colors.green : Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  _infoChip(Icons.badge_outlined, DisplayLabels.roleLabel(role)),
                                  if (programme.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    _infoChip(Icons.business_outlined, DisplayLabels.departmentLabel(programme)),
                                  ],
                                ],
                              ),
                              if (phone.isNotEmpty || idNumber.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    if (phone.isNotEmpty)
                                      Text(phone, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                    if (phone.isNotEmpty && idNumber.isNotEmpty)
                                      Text('  ·  ', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                                    if (idNumber.isNotEmpty)
                                      Text('ID: $idNumber', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 11)),
        ],
      ),
    );
  }
}
