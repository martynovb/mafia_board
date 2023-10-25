class AppState {
  final String language;
  final bool isAuthorized;

  AppState({
    required this.language,
    this.isAuthorized = false,
  });
}

class InitialAppState extends AppState {
  InitialAppState({
    String language = 'en',
  }) : super(language: language);
}
