class ApiConfig {
  static const String apiHost = 'v3.football.api-sports.io';
  static const String apiKey = '40ee81a09ca448a2565549eb1dcb76ca';

  static Map<String, String> get headers => {
    'x-rapidapi-host': apiHost,
    'x-rapidapi-key': apiKey,
  };
}