import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/product_api.dart';
import 'login_screen.dart';
import 'product_form_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();

  late Future<List<Map<String, dynamic>>> _productsFuture;

  Map<int, String> _categories = {};
  String _search = '';
  int? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchProducts();
  }

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    final products = await ProductApi.getProducts();
    final categories = <int, String>{};

    for (final product in products) {
      final id = (product['categoryId'] as num?)?.toInt();
      final category = product['category'];

      if (id != null && category is Map) {
        categories[id] = category['category']?.toString() ?? 'Sin categoría';
      }
    }

    _categories = categories;
    return products;
  }

  void _refresh() {
    setState(() {
      _productsFuture = _fetchProducts();
    });
  }

  void _message(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (_) {
      _message('No se pudo cerrar sesión.');
    }
  }

  Future<void> _openCreate() async {
    if (_categories.isEmpty) {
      _message('No hay categorías disponibles.');
      return;
    }

    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(categories: _categories),
      ),
    );

    if (!mounted || saved != true) return;

    _refresh();
    _message('Producto registrado correctamente.');
  }

  Future<void> _openEdit(Map<String, dynamic> product) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProductFormScreen(product: product, categories: _categories),
      ),
    );

    if (!mounted || saved != true) return;

    _refresh();
    _message('Producto actualizado correctamente.');
  }

  Future<void> _deleteProduct(Map<String, dynamic> product) async {
    final name = product['name']?.toString() ?? 'Producto';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text(
          '¿Seguro que deseas eliminar "$name"? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final id = (product['productId'] as num).toInt();
      await ProductApi.deleteProduct(id);

      if (!mounted) return;

      _refresh();
      _message('Producto eliminado correctamente.');
    } catch (error) {
      if (!mounted) return;

      final message = error is ProductApiException
          ? error.message
          : 'No se pudo eliminar el producto.';

      _message(message);
    }
  }

  String _formatPrice(dynamic value) {
    final price = value is num
        ? value.toDouble()
        : double.tryParse(value.toString()) ?? 0;

    final parts = price.toStringAsFixed(2).split('.');
    final integer = parts.first;
    final buffer = StringBuffer();

    for (var i = 0; i < integer.length; i++) {
      if (i > 0 && (integer.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(integer[i]);
    }

    return '\$${buffer.toString()}.${parts.last}';
  }

  Widget _productCard(Map<String, dynamic> product) {
    final name = product['name']?.toString() ?? 'Sin nombre';

    final category = product['category'] is Map
        ? product['category']['category']?.toString() ?? 'Sin categoría'
        : 'Sin categoría';

    final imageUrl = (product['imageUrl'] ?? '').toString().trim();

    final stock = product['stock'] is num
        ? (product['stock'] as num).toInt()
        : int.tryParse(product['stock'].toString()) ?? 0;

    final lowStock = stock < 50;

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE9EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 135,
                width: double.infinity,
                child: imageUrl.isEmpty
                    ? const ColoredBox(
                        color: Color(0xFFF0F1F5),
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 42,
                          color: Colors.grey,
                        ),
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const ColoredBox(
                              color: Color(0xFFF0F1F5),
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 42,
                                color: Colors.grey,
                              ),
                            ),
                      ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: lowStock
                        ? const Color(0xFFFFE8CC)
                        : const Color(0xFFDBF5E5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    stock == 0
                        ? 'Sin stock'
                        : lowStock
                        ? 'Poco stock: $stock'
                        : 'Stock: $stock',
                    style: TextStyle(
                      color: lowStock
                          ? const Color(0xFFB45309)
                          : const Color(0xFF166534),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 9),
                Text(
                  _formatPrice(product['price']),
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => _openEdit(product),
                      icon: const Icon(Icons.edit_outlined, size: 17),
                      label: const Text('Editar'),
                    ),
                    IconButton(
                      tooltip: 'Eliminar producto',
                      onPressed: () => _deleteProduct(product),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _networkError(Object? error) {
    final unavailable = error is ProductApiException && error.connectionError;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              unavailable ? Icons.cloud_off : Icons.error_outline,
              size: 72,
              color: Colors.grey,
            ),
            const SizedBox(height: 18),
            Text(
              unavailable
                  ? 'Servidor no disponible'
                  : 'No se pudo cargar el catálogo',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              unavailable
                  ? 'No pudimos conectar con Spring Boot. '
                        'Comprueba que el servidor esté encendido.'
                  : 'Ocurrió un problema al obtener los productos.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _catalog(List<Map<String, dynamic>> products) {
    final categories = _categories.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final filtered = products.where((product) {
      final name = product['name']?.toString().toLowerCase() ?? '';

      final categoryId = (product['categoryId'] as num?)?.toInt();

      final matchName = name.contains(_search.toLowerCase().trim());

      final matchCategory =
          _selectedCategory == null || categoryId == _selectedCategory;

      return matchName && matchCategory;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Explora nuestro catálogo',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                '${filtered.length} productos disponibles',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _search = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Buscar productos...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _search = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 54,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('Todas'),
                  selected: _selectedCategory == null,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                ),
              ),
              ...categories.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(entry.value),
                    selected: _selectedCategory == entry.key,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = entry.key;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No se encontraron productos.'))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 900
                        ? 4
                        : constraints.maxWidth >= 600
                        ? 3
                        : 2;

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        mainAxisExtent: 305,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) =>
                          _productCard(filtered[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Catálogo de productos'),
        actions: [
          IconButton(
            tooltip: 'Actualizar catálogo',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _networkError(snapshot.error);
          }

          return _catalog(snapshot.data ?? []);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
