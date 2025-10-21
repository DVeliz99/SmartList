import 'package:flutter/material.dart';
import 'package:smart_list/domain/product.dart';
import 'package:smart_list/core/error/result.dart';
import 'package:smart_list/presentation/widgets/app_bar.dart';
import 'package:smart_list/presentation/widgets/form.dart';
import 'package:smart_list/presentation/widgets/product_card.dart';
import 'package:smart_list/use_cases/product_use_cases.dart';

class ProductsPage extends StatefulWidget {
  final GetCachedProductsUseCase getCachedProductsUseCase;
  final AddProductUseCase addProductUseCase;
  final CheckProductExistsUseCase checkProductExistsUseCase;
  final SoftDeleteLocalProductUseCase softDeleteLocalProductUseCase;
  final DeleteRemoteProductUseCase deleteRemoteProductUseCase;
  final UpdateLocalProductUseCase updateLocalProductUseCase;

  const ProductsPage({
    super.key,
    required this.getCachedProductsUseCase,
    required this.addProductUseCase,
    required this.checkProductExistsUseCase,
    required this.softDeleteLocalProductUseCase,
    required this.deleteRemoteProductUseCase,
    required this.updateLocalProductUseCase,
  });

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late Future<Result<List<Product>>> _futureProducts;
  List<Product> _products = [];
  Product? _editingProduct;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    _futureProducts = widget.getCachedProductsUseCase.call();
    // When the future completes, update the local _products list from the result.
    _futureProducts.then((result) {
      if (!mounted) return;
      setState(() {
        if (result.isSuccess && result.data != null) {
          _products = result.data!;
        } else {
          _products = [];
        }
      });
    }).catchError((_) {
      
    });
  }

  Future<void> _addProduct(Product product) async {
    try {
      //guarda el producto en local
      final result = await widget.addProductUseCase.call(product);
      if (result.isSuccess && result.data != null) {
        setState(() {
          //producto real al inicio de la lista
          _products.insert(0, result.data!);
        });
      } else {
        print('Error al guardar producto: ${result.failure?.message ?? ''}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al guardar producto',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  Future<void> _deleteLocalProduct(String id) async {
    try {
      final deleteLocalProduct = await widget.softDeleteLocalProductUseCase
          .call(id);

      if (deleteLocalProduct.isSuccess) {
        // Actualizar UI
        setState(() {
          _products.removeWhere((p) => p.id == id);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Producto eliminado con éxito')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar producto')));
    }
  }

  Future<void> _updateProduct(Product product) async {
    try {
      final result = await widget.updateLocalProductUseCase.call(product);
      if (result.isSuccess && result.data != null) {
        setState(() {
          final index = _products.indexWhere((p) => p.id == product.id);
          if (index != -1) _products[index] = result.data!;
          _editingProduct = null; // reset para modo agregar
        });
      } else {
        print('Error al actualizar producto: ${result.failure?.message ?? ''}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error al actualizar producto',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomShoppingAppBar(productCount: _products.length),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ProductForm(
              product:
                  _editingProduct ??
                  Product(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: '',
                    data: {'price': 0.0},
                  ),
              onSave: _addProduct,
              onUpdate: _updateProduct,
              actionLabel: _editingProduct != null
                  ? 'Guardar cambios'
                  : 'Agregar Producto',
              isEditing: _editingProduct != null,
            ),

            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<Result<List<Product>>>(
                future: _futureProducts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final result = snapshot.data;
                  if (result == null ||
                      result.isFailure ||
                      result.data == null) {
                    return Center(
                      child: Text(
                        'No hay productos: ${result?.failure?.message ?? ''}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  if (_products.isEmpty) _products = result.data!;

                  return ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ProductCard(
                          product: product,
                          // Al hacer click en editar, se pasa al formulario
                          onEdit: () {
                            setState(() {
                              _editingProduct = product;
                            });
                            print('Objeto a editar $_editingProduct');
                          },
                          onDelete: () => _deleteLocalProduct(product.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
