import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Para jsonEncode y jsonDecode
import 'package:tpv_elyella/config.dart';

///
/// Servicio de Autenticación que llama a una API REST personalizada.
/// Reemplaza el authService.js que usa 'fetch'.
///
class AuthService {
  // TODO: ¡MUY IMPORTANTE!
  // Reemplaza esta URL por la URL base de tu backend (tu FUNCTIONS_URL)
  static String get _apiBase => Config.backendUrl;

  // Esta es la clave que usaremos para guardar el token en el dispositivo
  static const String _tokenKey = "auth_token";

  // Headers estándar para peticiones JSON
  static const Map<String, String> _headers = {
    "Content-Type": "application/json",
  };

  /// Guarda el token de autenticación en el almacenamiento seguro.
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Obtiene el token de autenticación guardado.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Limpia el token de autenticación del almacenamiento.
  static Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Inicia sesión con email y contraseña.
  /// Devuelve el cuerpo de la respuesta y guarda el token.
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$_apiBase/auth/login');
    final body = jsonEncode({'email': email, 'password': password});

    final response = await http.post(url, headers: _headers, body: body);
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      String? token;

      // Estructura: data.session.access_token (tu backend)
      if (data.containsKey('data') && data['data'] is Map) {
        final dataObj = data['data'] as Map<String, dynamic>;

        if (dataObj.containsKey('session') && dataObj['session'] is Map) {
          final session = dataObj['session'] as Map<String, dynamic>;

          token =
              session['access_token'] as String? ??
              session['refresh_token'] as String? ??
              session['token'] as String?;
        }
      }
      // Estructura alternativa: session.access_token (directo en raíz)
      else if (data.containsKey('session') && data['session'] is Map) {
        final session = data['session'] as Map<String, dynamic>;

        token =
            session['access_token'] as String? ??
            session['refresh_token'] as String? ??
            session['token'] as String?;
      }
      // Estructura simple: token directo en raíz
      else if (data.containsKey('token')) {
        token = data['token'] as String?;
      } else if (data.containsKey('access_token')) {
        token = data['access_token'] as String?;
      } else if (data.containsKey('accessToken')) {
        token = data['accessToken'] as String?;
      }

      if (token != null && token.isNotEmpty) {
        await _saveToken(token);
      }

      return data;
    } else {
      // Lanza un error con el mensaje del servidor
      throw Exception(data['message'] ?? 'Error en login');
    }
  }

  /// Registra un nuevo usuario.
  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> userData,
  ) async {
    final url = Uri.parse('$_apiBase/auth/register');
    final body = jsonEncode(userData);

    final response = await http.post(url, headers: _headers, body: body);
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Error en registro');
    }
  }

  /// Cierra la sesión del usuario.
  /// Llama al endpoint del backend y limpia el token local.
  static Future<Map<String, dynamic>> logout() async {
    final token = await getToken();

    // Si no hay token local, simplemente limpiamos (por si acaso) y salimos.
    if (token == null || token.isEmpty) {
      await _clearToken();
      return {'success': true, 'message': 'No local session.'};
    }

    final url = Uri.parse('$_apiBase/auth/logout');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // Envía el token para invalidarlo
      },
    );

    // Independientemente de la respuesta del servidor, limpiamos el token local.
    await _clearToken();

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      // Informa del error, pero el token local ya se ha limpiado.
      throw Exception(
        data['message'] ?? 'Error al cerrar sesión en el servidor',
      );
    }
  }

  /// Verifica un token contra el backend.
  static Future<Map<String, dynamic>> verifyToken(String token) async {
    final url = Uri.parse('$_apiBase/auth/verify');
    final body = jsonEncode({'access_token': token});

    final response = await http.post(url, headers: _headers, body: body);
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Token inválido');
    }
  }
}
