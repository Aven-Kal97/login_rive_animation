import 'package:flutter/material.dart';

import '../services/product_api.dart';

class ProductFormScreen extends StatefulWidget {
  final Map<String, dynamic>? product;
  final Map<int, String> categories;

  const ProductFormScreen({super.key, this.product, required this.categories});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _imageController;

  int? _categoryId;
  bool _isSaving = false;
  String? _errorMessage;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    _nameController = TextEditingController(
      text: product?['name']?.toString() ?? '',
    );

    _priceController = TextEditingController(
      text: product?['price']?.toString() ?? '',
    );

    _stockController = TextEditingController(
      text: product?['stock']?.toString() ?? '0',
    );

    _imageController = TextEditingController(
      text: product?['imageUrl']?.toString() ?? '',
    );

    final existingId = (product?['categoryId'] as num?)?.toInt();

    _categoryId = widget.categories.containsKey(existingId)
        ? existingId
        : widget.categories.keys.firstOrNull;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final imageUrl = _imageController.text.trim();

    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'categoryId': _categoryId,
      'price': double.parse(_priceController.text.trim().replaceAll(',', '.')),
      'stock': int.parse(_stockController.text.trim()),
      'active': widget.product?['active'] ?? true,
      'imageUrl': imageUrl.isEmpty ? null : imageUrl,
    };

    try {
      if (isEditing) {
        final id = (widget.product!['productId'] as num).toInt();
        await ProductApi.updateProduct(id, data);
      } else {
        await ProductApi.createProduct(data);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error is ProductApiException
            ? error.message
            : 'No se pudo guardar el producto.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.categories.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar producto' : 'Nuevo producto'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                isEditing ? 'Actualizar producto' : 'Agregar al catálogo',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Completa los datos para guardarlos en Spring Boot.'),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                maxLength: 45,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el nombre del producto.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items: categories.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: _isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _categoryId = value;
                        });
                      },
                validator: (value) =>
                    value == null ? 'Selecciona una categoría.' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final number = double.tryParse(
                    (value ?? '').trim().replaceAll(',', '.'),
                  );

                  if (number == null || !number.isFinite || number <= 0) {
                    return 'Ingresa un precio válido mayor que cero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Existencias',
                  prefixIcon: Icon(Icons.warehouse_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final number = int.tryParse((value ?? '').trim());

                  if (number == null || number < 0) {
                    return 'Ingresa una cantidad válida.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _imageController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL pública de la imagen',
                  prefixIcon: Icon(Icons.image_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) return null;

                  final uri = Uri.tryParse(text);

                  if (uri == null ||
                      uri.scheme != 'https' ||
                      uri.host.isEmpty) {
                    return 'Ingresa una URL HTTPS válida.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Puedes utilizar una URL pública de Supabase Storage.',
                style: TextStyle(color: Colors.grey),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(isEditing ? Icons.save : Icons.add),
                label: Text(_isSaving ? 'Guardando...' : 'Guardar producto'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
