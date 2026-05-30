/// Maps SOP request types to their display info and role filter.
class SopFormConfig {
  final String type;
  final String label;
  final String description;
  final String icon; // Material Icons name
  final String submitterRole; // who can create this type

  const SopFormConfig({
    required this.type,
    required this.label,
    required this.description,
    required this.icon,
    required this.submitterRole,
  });

  static const List<SopFormConfig> all = [
    SopFormConfig(type: 'leave', label: 'Leave Request', description: 'Annual, sick, or personal leave', icon: 'vacation', submitterRole: 'all'),
    SopFormConfig(type: 'reimbursement', label: 'Reimbursement', description: 'Expense reimbursement claim', icon: 'receipt_long', submitterRole: 'all'),
    SopFormConfig(type: 'travel', label: 'Travel Request', description: 'Official travel approval', icon: 'flight', submitterRole: 'all'),
    SopFormConfig(type: 'procurement', label: 'Procurement', description: 'Purchase request for goods/services', icon: 'shopping_cart', submitterRole: 'manager'),
    SopFormConfig(type: 'activityProposal', label: 'Activity Proposal', description: 'New programme activity proposal', icon: 'event', submitterRole: 'manager'),
    SopFormConfig(type: 'venueBooking', label: 'Venue Booking', description: 'Venue/space reservation', icon: 'location_on', submitterRole: 'all'),
    SopFormConfig(type: 'equipmentRequest', label: 'Equipment Request', description: 'Request equipment or tools', icon: 'handyman', submitterRole: 'all'),
    SopFormConfig(type: 'itSupport', label: 'IT Support', description: 'IT/tech support request', icon: 'computer', submitterRole: 'all'),
    SopFormConfig(type: 'trainingNomination', label: 'Training Nomination', description: 'Nominate staff for training', icon: 'school', submitterRole: 'manager'),
    SopFormConfig(type: 'incidentReport', label: 'Incident Report', description: 'Report an incident or hazard', icon: 'warning', submitterRole: 'all'),
    SopFormConfig(type: 'vehicleRequest', label: 'Vehicle Request', description: 'Request use of SALSO vehicle', icon: 'directions_car', submitterRole: 'all'),
    SopFormConfig(type: 'budgetTransfer', label: 'Budget Transfer', description: 'Transfer between budget lines', icon: 'swap_horiz', submitterRole: 'manager'),
    SopFormConfig(type: 'newPosition', label: 'New Position', description: 'Request new staff position', icon: 'person_add', submitterRole: 'manager'),
    SopFormConfig(type: 'termination', label: 'Termination', description: 'Employee termination process', icon: 'person_remove', submitterRole: 'admin'),
    SopFormConfig(type: 'disciplinary', label: 'Disciplinary', description: 'Disciplinary case referral', icon: 'gavel', submitterRole: 'admin'),
    SopFormConfig(type: 'partnershipProposal', label: 'Partnership Proposal', description: 'New partnership proposal', icon: 'handshake', submitterRole: 'executiveDirector'),
    SopFormConfig(type: 'mediaRequest', label: 'Media Request', description: 'Media/communications request', icon: 'campaign', submitterRole: 'all'),
    SopFormConfig(type: 'volunteerPlacement', label: 'Volunteer Placement', description: 'Place volunteer at site', icon: 'diversity_3', submitterRole: 'coordinator'),
    SopFormConfig(type: 'attendanceCorrection', label: 'Attendance Correction', description: 'Request clock-out correction', icon: 'edit_calendar', submitterRole: 'all'),
    SopFormConfig(type: 'general', label: 'General Request', description: 'Other request not listed', icon: 'description', submitterRole: 'all'),
  ];

  static SopFormConfig? fromType(String type) {
    try {
      return all.firstWhere((c) => c.type == type);
    } catch (_) {
      return null;
    }
  }
}
