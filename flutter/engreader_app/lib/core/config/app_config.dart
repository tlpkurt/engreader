class AppConfig {
  static const String appName = 'Engreader';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  // Use environment variable or default to localhost for development
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000/api/v1',
  );
  
  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String storiesEndpoint = '/stories';
  static const String quizzesEndpoint = '/quizzes';
  static const String translationsEndpoint = '/translations';
  static const String progressEndpoint = '/progress';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  
  // API Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Cache Duration
  static const Duration translationCacheDuration = Duration(hours: 1);
  
  // Reading Configuration
  static const int wordsPerMinute = 200; // Average reading speed
  static const double targetWordUsageThreshold = 0.70; // 70% target word usage
  
  // Quiz Configuration
  static const int questionsPerQuiz = 5;
  static const int maxQuizTimeMinutes = 10;
  
  // CEFR Levels
  static const List<String> cefrLevels = [
    'A1', // Beginner
    'A2', // Elementary
    'B1', // Intermediate
    'B2', // Upper-Intermediate
    'C1', // Advanced
    'C2', // Proficient
  ];
}
