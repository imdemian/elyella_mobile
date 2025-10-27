import 'package:flutter/material.dart';
import 'package:tpv_elyella/services/producto_service.dart';
import 'package:tpv_elyella/services/auth_service.dart';

class ProductoScreen extends StatefulWidget {
  const ProductoScreen({super.key});

  @override
  State<ProductoScreen> createState() => _ProductoScreenState();
}

class _ProductoScreenState extends State<ProductoScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _productos = [];
  bool _loading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _verificarAutenticacion();
  }

  /// Verifica si el usuario está autenticado antes de cargar datos
  Future<void> _verificarAutenticacion() async {
    print("🔐 ProductoScreen - Verificando autenticación...");
    final token = await AuthService.getToken();

    print("🔐 ProductoScreen - Token: ${token != null ? 'EXISTE' : 'NULL'}");

    if (token == null || token.isEmpty) {
      // No hay token, redirigir al login
      if (!mounted) return;

      print("⚠️ ProductoScreen - Sin token, redirigiendo al login");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, inicia sesión para continuar'),
          backgroundColor: Colors.orange,
        ),
      );

      // Redirigir al login y eliminar esta pantalla del stack
      Navigator.of(context).pushReplacementNamed('/');
      return;
    }

    // Si hay token, cargar productos
    print("✅ ProductoScreen - Token existe, cargando productos...");
    _cargarProductos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarProductos({String? searchTerm}) async {
    print("\n📦 ProductoScreen._cargarProductos - INICIO");
    print("📦 searchTerm: $searchTerm, page: $_currentPage");

    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      print("📦 Llamando a ApiProductosService.listarProductos...");

      final resp = await ApiProductosService.listarProductos(
        page: _currentPage,
        limit: 20,
        search: searchTerm,
        activo: true, // ← Buscar solo productos activos
      );

      print("📦 Respuesta recibida del servicio");
      print("📦 resp.keys: ${resp.keys.toList()}");
      print("📦 resp completo: $resp");

      if (!mounted) return;

      // Extraer datos de la estructura: { data: [...], pagination: {...} }
      final productos = resp['data'] ?? [];
      final pagination = resp['pagination'] as Map<String, dynamic>?;

      print("📦 productos.length: ${productos.length}");
      print("📦 pagination: $pagination");

      setState(() {
        _productos = productos;
        _total = pagination?['total_items'] ?? 0;
        _totalPages = pagination?['total_pages'] ?? 1;
        _loading = false;
      });

      print("✅ ProductoScreen._cargarProductos - ÉXITO");
      print(
        "✅ Productos cargados: ${_productos.length}, Total: $_total, Páginas: $_totalPages",
      );
    } catch (e) {
      print("❌❌ ProductoScreen._cargarProductos - ERROR");
      print("❌❌ Error: $e");
      print("❌❌ Tipo: ${e.runtimeType}");

      if (!mounted) return;

      final errorMsg = e.toString();

      // Si es error 401 (no autorizado), redirigir al login
      if (errorMsg.contains('401') ||
          errorMsg.contains('No autorizado') ||
          errorMsg.contains('No se encontró token')) {
        print("🔒 ProductoScreen - Error 401, redirigiendo al login");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sesión expirada. Por favor, inicia sesión nuevamente.',
            ),
            backgroundColor: Colors.red,
          ),
        );

        // Redirigir al login
        Navigator.of(context).pushReplacementNamed('/');
        return;
      }

      print(
        "⚠️ ProductoScreen - Error no relacionado con auth, mostrando en UI",
      );

      setState(() {
        _hasError = true;
        _errorMessage = errorMsg;
        _loading = false;
      });
    }
  }

  void _buscar() {
    setState(() => _currentPage = 1);
    _cargarProductos(searchTerm: _searchController.text.trim());
  }

  void _irAPagina(int page) {
    if (page < 1 || page > _totalPages) return;
    setState(() => _currentPage = page);
    _cargarProductos(searchTerm: _searchController.text.trim());
  }

  void _abrirFormularioProducto({Map<String, dynamic>? producto}) {
    // TODO: Navegar a pantalla de crear/editar producto
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          producto == null
              ? 'Abrir formulario nuevo producto'
              : 'Editar: ${producto['nombre']}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _abrirFormularioProducto(),
            tooltip: 'Nuevo producto',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar productos',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _buscar();
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _buscar(),
            ),
          ),

          // Loading indicator
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator())),

          // Error state
          if (_hasError && !_loading)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar productos',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _cargarProductos,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),

          // Lista de productos
          if (!_loading && !_hasError)
            Expanded(
              child: _productos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inbox, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontraron productos',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _productos.length,
                      itemBuilder: (context, index) {
                        final producto = _productos[index];
                        return _ProductoListItem(
                          producto: producto,
                          onTap: () =>
                              _abrirFormularioProducto(producto: producto),
                        );
                      },
                    ),
            ),

          // Paginación
          if (!_loading && !_hasError && _totalPages > 1)
            _PaginacionFooter(
              currentPage: _currentPage,
              totalPages: _totalPages,
              total: _total,
              onPageChanged: _irAPagina,
            ),
        ],
      ),
    );
  }
}

class _ProductoListItem extends StatelessWidget {
  final Map<String, dynamic> producto;
  final VoidCallback onTap;

  const _ProductoListItem({required this.producto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final nombre = producto['nombre'] ?? 'Sin nombre';
    final precio = producto['precio_base'] ?? 0.0;
    final activo = producto['activo'] ?? false;
    final sku = producto['sku'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: activo ? Colors.green : Colors.grey,
          child: Icon(activo ? Icons.check : Icons.close, color: Colors.white),
        ),
        title: Text(nombre),
        subtitle: Text('SKU: $sku • \$${precio.toStringAsFixed(2)}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _PaginacionFooter extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int total;
  final Function(int) onPageChanged;

  const _PaginacionFooter({
    required this.currentPage,
    required this.totalPages,
    required this.total,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total: $total productos',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 1
                    ? () => onPageChanged(currentPage - 1)
                    : null,
              ),
              Text(
                'Pág. $currentPage de $totalPages',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
