class DisplayLabels {
  // Human-friendly Department names (programmeId -> label)
  static const Map<String, String> departmentNames = {
    'research': 'Research & Policy',
    'programmes': 'Programmes',
    'finance': 'Finance',
    'hr': 'Human Resources',
    'comms': 'Communications',
    'ops': 'Operations',
    'admin': 'Administration',
    'youth': 'Youth Development',
  };

  // Human-friendly Project names (teamId -> label)
  static const Map<String, String> projectNames = {
    'zim_dialogue': 'Zimbabwe Dialogue',
    'moz_peace': 'Mozambique Peace',
    'gendermainstream': 'Gender Mainstreaming',
    'climate_justice': 'Climate Justice',
    'xenophobia': 'Xenophobia & Migration',
    'youth_programme': 'Youth Development Programme',
    'sadc_monitoring': 'SADC Monitoring',
    'foreign_policy': 'SA Foreign Policy',
  };

  static String departmentLabel(String? programmeId) {
    if (programmeId == null || programmeId.trim().isEmpty) return 'General';
    return departmentNames[programmeId] ?? programmeId;
  }

  static String projectLabel(String? teamId) {
    if (teamId == null || teamId.trim().isEmpty) return 'General';
    return projectNames[teamId] ?? teamId;
  }

  static String roleLabel(String roleTemplateId) {
    switch (roleTemplateId) {
      case 'executiveDirector':
        return 'Executive Director';
      case 'teamLeader':
        return 'Team Leader';
      case 'manager':
        return 'Manager';
      case 'admin':
        return 'Administrator';
      case 'coordinator':
        return 'Coordinator';
      default:
        return 'Volunteer';
    }
  }

  static String docTypeLabel(String docType) {
    switch (docType) {
      case 'cv':
        return 'CV';
      case 'id':
        return 'ID Document';
      case 'proofOfBank':
        return 'Proof of Banking';
      case 'contract':
        return 'Signed Contract';
      default:
        return docType;
    }
  }
}
