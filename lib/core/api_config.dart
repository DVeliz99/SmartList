// Configuración de la API
class ApiConfig {
  //URL base de la API
  static const String baseUrl = 'https://api.restful-api.dev/objects';

  //Headers y timeout
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };
  static const int timeout = 5000; //5 segundos
}
