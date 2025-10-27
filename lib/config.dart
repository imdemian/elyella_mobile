/// Configuración central de la aplicación.
///
/// Expone la URL del backend y soporta dos modos de configuración:
///  - Build-time: pasar `--dart-define=BACKEND_URL=https://mi-backend` al compilar.
///  - Runtime: llamar a `Config.setBackendUrl(...)` desde `main()` (útil para tests o desarrollo).
class Config {
  // Valor por defecto (desarrollo local). Cámbialo si deseas otro por defecto.
  static const String _kDefaultBackend =
      'http://localhost:5001/elyella-d411f/us-central1/api/supabase';

  // Usamos String.fromEnvironment para permitir --dart-define en compilación.
  static String _backendUrl = const String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: _kDefaultBackend,
  );

  /// URL actual del backend.
  static String get backendUrl => _backendUrl;

  /// Permite cambiar la URL en tiempo de ejecución (p. ej. en `main()` o tests).
  static void setBackendUrl(String url) {
    if (url.isNotEmpty) {
      _backendUrl = url;
    }
  }
}
