import 'package:http/http.dart' as http;
import 'package:tpv_elyella/config.dart';
import 'dart:convert'; // Para jsonEncode y jsonDecode
// Importamos el servicio de autenticación para poder obtener el token
import 'auth_service.dart';

///
/// Servicio para la gestión de Productos (Catálogo).
/// Reemplaza a ProductoService.js
///
class ApiProductosService {
  // TODO: ¡MUY IMPORTANTE!
  // Asegúrate de que esta URL sea la misma que en api_auth_service.dart
  static String get _apiBase => Config.backendUrl;

  /// Genera las cabeceras de autenticación necesarias para las peticiones.
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await AuthService.getToken();
    final headers = {"Content-Type": "application/json"};

    print(
      "🔑 _getAuthHeaders - Token: ${token != null ? '${token.substring(0, 20)}...' : 'NULL'}",
    );

    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
      print("✅ _getAuthHeaders - Authorization header añadido");
    } else {
      print("⚠️ ApiProductosService: No se encontró token de autenticación.");
    }
    return headers;
  }

  /// Verifica si la respuesta es JSON y la decodifica.
  /// Lanza una excepción si la respuesta no es JSON o si !response.ok
  static dynamic _handleResponse(http.Response response) {
    print("📥 _handleResponse - Status: ${response.statusCode}");
    print(
      "📥 _handleResponse - Content-Type: ${response.headers['content-type']}",
    );
    print(
      "📥 _handleResponse - Body (primeros 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}",
    );

    // Primero, verificamos si el body está vacío.
    // Una respuesta 'DELETE' exitosa puede ser un 204 (No Content).
    if (response.statusCode == 204) {
      return {'success': true, 'message': 'Recurso eliminado correctamente'};
    }

    final contentType = response.headers['content-type'];
    if (contentType == null || !contentType.contains("application/json")) {
      print("❌ _handleResponse - Respuesta NO es JSON");
      throw Exception(
        'La respuesta no es JSON. Verifica que el servidor esté corriendo en $_apiBase. Body: ${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    print("✅ _handleResponse - JSON parseado correctamente");
    if (data is Map) {
      print("📊 _handleResponse - Es Map con keys: ${data.keys.toList()}");
    } else if (data is List) {
      print("📊 _handleResponse - Es List con ${data.length} elementos");
    }

    // Manejar errores específicos
    if (response.statusCode == 401) {
      print("🔒 _handleResponse - Error 401: No autorizado");
      throw Exception("No autorizado. Por favor, inicia sesión nuevamente.");
    }
    if (response.statusCode == 403) {
      throw Exception("No tienes permisos para esta acción.");
    }
    if (response.statusCode == 404) {
      throw Exception("Recurso no encontrado (404).");
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = (data is Map<String, dynamic>)
          ? data['message'] ?? data['error']
          : 'Error en la petición';
      print("❌ _handleResponse - Error ${response.statusCode}: $message");
      throw Exception(message ?? 'Error desconocido del servidor');
    }

    return data;
  }

  /// Listar productos con paginación y filtros
  static Future<Map<String, dynamic>> listarProductos({
    int page = 1,
    int limit = 20,
    String? search,
    String? categoriaId,
    bool? activo,
    String orderBy = "nombre",
    String orderDir = "asc",
  }) async {
    print("\n🛍️ listarProductos - INICIO");
    print("🛍️ Parámetros: page=$page, limit=$limit, search=$search");

    try {
      final params = {
        'page': page.toString(),
        'limit': limit.toString(),
        'order_by': orderBy,
        'order_dir': orderDir,
      };

      if (search != null && search.isNotEmpty) params['search'] = search;
      if (categoriaId != null) params['categoria_id'] = categoriaId;
      if (activo != null) params['activo'] = activo.toString();

      final url = Uri.parse(
        '$_apiBase/productos',
      ).replace(queryParameters: params);

      print("🛍️ URL completa: $url");

      final headers = await _getAuthHeaders();
      print("🛍️ Headers preparados, haciendo GET...");

      final response = await http.get(url, headers: headers);
      print("🛍️ Respuesta recibida - Status: ${response.statusCode}");

      final data = _handleResponse(response);

      if (data is Map<String, dynamic>) {
        print("✅ listarProductos - Respuesta es Map");
        print("🛍️ Keys de la respuesta: ${data.keys.toList()}");
        print(
          "🛍️ Productos encontrados: ${data['data'] != null ? (data['data'] as List).length : 0}",
        );
        print("🛍️ listarProductos - FIN EXITOSO\n");
        // Devuelve el objeto completo (ej: { "data": [...], "total": 100, "page": 1 })
        return data;
      } else {
        print("❌ listarProductos - Respuesta NO es Map");
        throw Exception("La respuesta no fue un objeto (Map).");
      }
    } catch (e) {
      print("❌❌ Error en listarProductos: $e");
      print("❌❌ Tipo de error: ${e.runtimeType}");
      rethrow;
    }
  }

  /// Obtener un producto específico por ID
  static Future<Map<String, dynamic>> obtenerProducto(String id) async {
    try {
      final url = Uri.parse('$_apiBase/productos/$id');
      final headers = await _getAuthHeaders();

      final response = await http.get(url, headers: headers);
      final data = _handleResponse(response);

      if (data is Map<String, dynamic>) {
        return data; // Devuelve el objeto del producto
      } else {
        throw Exception("La respuesta no fue un objeto (Map).");
      }
    } catch (e) {
      print("Error en obtenerProducto: $e");
      rethrow;
    }
  }

  /// Crear un nuevo producto con sus variantes
  static Future<Map<String, dynamic>> crearProducto(
    Map<String, dynamic> productoData,
  ) async {
    try {
      final url = Uri.parse('$_apiBase/productos');
      final headers = await _getAuthHeaders();
      final body = jsonEncode(productoData);

      final response = await http.post(url, headers: headers, body: body);
      final data = _handleResponse(response);

      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception("La respuesta no fue un objeto (Map).");
      }
    } catch (e) {
      print("Error en crearProducto: $e");
      rethrow;
    }
  }

  /// Actualizar un producto existente
  static Future<Map<String, dynamic>> actualizarProducto(
    String id,
    Map<String, dynamic> productoData,
  ) async {
    try {
      final url = Uri.parse('$_apiBase/productos/$id');
      final headers = await _getAuthHeaders();
      final body = jsonEncode(productoData);

      print("🔧 ApiProductosService.actualizarProducto");
      print("   URL: $url");
      print("   Payload: $body");

      final response = await http.put(url, headers: headers, body: body);

      print("   Status: ${response.statusCode}");
      print("   Status Text: ${response.reasonPhrase}");
      print("   Body: ${response.body}");

      final data = _handleResponse(response);

      print("   Respuesta exitosa (decodificada): $data");

      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception("La respuesta no fue un objeto (Map).");
      }
    } catch (e) {
      print("❌ Error en actualizarProducto: $e");
      rethrow;
    }
  }

  /// Desactivar un producto (soft delete)
  static Future<Map<String, dynamic>> desactivarProducto(String id) async {
    try {
      final url = Uri.parse('$_apiBase/productos/$id');
      final headers = await _getAuthHeaders();

      final response = await http.delete(url, headers: headers);

      // _handleResponse maneja el 204 (No Content) o un cuerpo JSON
      final data = _handleResponse(response);

      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception("La respuesta no fue un objeto (Map).");
      }
    } catch (e) {
      print("Error en desactivarProducto: $e");
      rethrow;
    }
  }

  /// Búsqueda rápida de productos (para TPV)
  static Future<List<dynamic>> buscarProductos(
    String termino, {
    int limite = 10,
  }) async {
    try {
      final params = {'q': termino, 'limit': limite.toString()};

      // Uri.replace se encarga de codificar el término de búsqueda (termino)
      final url = Uri.parse(
        '$_apiBase/productos/search/quick',
      ).replace(queryParameters: params);
      final headers = await _getAuthHeaders();

      final response = await http.get(url, headers: headers);
      final data = _handleResponse(response);

      if (data is List) {
        return data; // Devuelve una lista de productos
      } else {
        throw Exception("La respuesta no fue una lista (Array).");
      }
    } catch (e) {
      print("Error en buscarProductos: $e");
      rethrow;
    }
  }

  /// Obtener estadísticas de productos
  static Future<Map<String, dynamic>> obtenerEstadisticas() async {
    try {
      final url = Uri.parse('$_apiBase/productos/stats/overview');
      final headers = await _getAuthHeaders();

      final response = await http.get(url, headers: headers);
      final data = _handleResponse(response);

      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception("La respuesta no fue un objeto (Map).");
      }
    } catch (e) {
      print("Error en obtenerEstadisticas: $e");
      rethrow;
    }
  }

  /// Obtener productos activos (atajo para listarProductos)
  static Future<Map<String, dynamic>> obtenerProductosActivos() {
    // Simplemente llama a la otra función con el filtro aplicado
    return listarProductos(activo: true);
  }
}
