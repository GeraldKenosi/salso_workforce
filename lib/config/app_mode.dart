enum AppMode { live, demo }

class AppConfig {
  static AppMode mode = AppMode.demo;

  static bool get isDemo => mode == AppMode.demo;

  static String get appName =>
      isDemo ? 'Show Me Your Number NPC Demo' : 'SALSO Workforce';

  static String get organisationName =>
      isDemo ? 'Show Me Your Number NPC' : 'SALSO';

  static String get uploadStatusLabel => isDemo ? 'pending' : 'uploaded';
}