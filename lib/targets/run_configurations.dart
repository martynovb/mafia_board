class RunConfigurations {
  static String get firebaseApiKey =>
      const String.fromEnvironment('firebaseApiKey');

  static String get firebaseAppId =>
      const String.fromEnvironment('firebaseAppId');

  static String get firebaseMessagingSenderId =>
      const String.fromEnvironment('firebaseMessagingSenderId');

  static String get firebaseProjectId =>
      const String.fromEnvironment('firebaseProjectId');

  static String get firebaseAuthDomain =>
      const String.fromEnvironment('firebaseAuthDomain');

  static String get firebaseStorageBucket =>
      const String.fromEnvironment('firebaseStorageBucket');

  static String get firebaseMeasurementId =>
      const String.fromEnvironment('firebaseMeasurementId');
}
