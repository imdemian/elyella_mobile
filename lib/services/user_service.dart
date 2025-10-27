import 'package:http/http.dart' as http;
import 'dart:convert'; // Para jsonEncode y jsonDecode
// Importamos el servicio de autenticación para poder obtener el token
import 'auth_service.dart';
import 'package:tpv_elyella/config.dart';

///
/// Servicio para la gestión de usuarios por parte de un administrador.
/// Reemplaza a UsuariosService.js
///
class UsuariosService {
  // TODO: ¡MUY IMPORTANTE!
  // Asegúrate de que esta URL sea la misma que en api_auth_service.dart
  static String get _apiBase => Config.backendUrl;

  /// Genera las cabeceras de autenticación necesarias para las peticiones.
  /// Obtiene el token guardado por AuthService.
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await AuthService.getToken();
    final headers = {"Content-Type": "application/json"};

    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    } else {
      // En Flutter, es más común manejar esto lanzando una excepción
      // o permitiendo que la API falle con 401.
      print("⚠️ No se encontró token de autenticación en SharedPreferences");
    }
    return headers;
  }

  /// Verifica si la respuesta es JSON y la decodifica.
  /// Lanza una excepción si la respuesta no es JSON o si !response.ok
  static dynamic _handleResponse(http.Response response) {
    final contentType = response.headers['content-type'];
    if (contentType == null || !contentType.contains("application/json")) {
      throw Exception(
        'La respuesta no es JSON. Verifica que el servidor esté corriendo en $_apiBase',
      );
    }

    final data = jsonDecode(response.body);

    // Manejar errores específicos
    if (response.statusCode == 401) {
      throw Exception(
        "No estás autenticado. Por favor, inicia sesión nuevamente.",
      );
    }
    if (response.statusCode == 403) {
      throw Exception(
        "No tienes permisos de administrador para acceder a esta sección.",
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = (data is Map<String, dynamic>)
          ? data['message']
          : 'Error en la petición';
      throw Exception(message ?? 'Error desconocido');
    }

    return data;
  }

  /// Obtiene la lista completa de usuarios del sistema.
  /// Requiere rol de 'admin'.
  static Future<List<dynamic>> obtenerUsuarios() async {
    try {
      final url = Uri.parse('$_apiBase/usuarios');
      final headers = await _getAuthHeaders();

      final response = await http.get(url, headers: headers);

      // _handleResponse maneja los errores y decodifica el JSON
      final data = _handleResponse(response);

      // Esperamos una lista (un Array en JS)
      if (data is List) {
        return data;
      } else {
        throw Exception("La respuesta no es una lista de usuarios.");
      }
    } catch (e) {
      print("Error en obtenerUsuarios: $e");
      // Re-lanzar el error para que se muestre en la UI
      rethrow;
    }
  }

  /// Obtiene los datos de un usuario específico por su ID.
  /// Requiere rol de 'admin'.
  static Future<Map<String, dynamic>> obtenerUsuario(String id) async {
    try {
      final url = Uri.parse('$_apiBase/usuarios/$id');
      final headers = await _getAuthHeaders();

      final response = await http.get(url, headers: headers);

      final data = _handleResponse(response);

      // Esperamos un objeto (un Map en Dart)
      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception("La respuesta no es un objeto de usuario.");
      }
    } catch (e) {
      print("Error en obtenerUsuario: $e");
      rethrow;
    }
  }

  /// Actualiza los datos de un usuario.
  /// Requiere rol de 'admin'.
  static Future<Map<String, dynamic>> actualizarUsuario(
    String id,
    Map<String, dynamic> userData,
  ) async {
    try {
      final url = Uri.parse('$_apiBase/usuarios/$id');
      final headers = await _getAuthHeaders();
      final body = jsonEncode(userData);

      final response = await http.put(url, headers: headers, body: body);

      final data = _handleResponse(response);

      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception("La respuesta no es un objeto de usuario.");
      }
    } catch (e) {
      print("Error en actualizarUsuario: $e");
      rethrow;
    }
  }

  /// Elimina un usuario del sistema.
  /// Requiere rol de 'admin'.
  static Future<Map<String, dynamic>> eliminarUsuario(String id) async {
    try {
      final url = Uri.parse('$_apiBase/usuarios/$id');
      final headers = await _getAuthHeaders();

      final response = await http.delete(url, headers: headers);

      final data = _handleResponse(response);

      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception("La respuesta no fue la esperada.");
      }
    } catch (e) {
      print("Error en eliminarUsuario: $e");
      rethrow;
    }
  }

  /// Cambia la contraseña de un usuario (como admin).
  /// Requiere rol de 'admin'.
  static Future<Map<String, dynamic>> changePassword(
    String id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final url = Uri.parse('$_apiBase/usuarios/$id/password-change');
      final headers = await _getAuthHeaders();
      final body = jsonEncode(payload);

      final response = await http.put(url, headers: headers, body: body);

      final data = _handleResponse(response);

      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception("La respuesta no fue la esperada.");
      }
    } catch (e) {
      print("Error en changePassword: $e");
      rethrow;
    }
  }
}
