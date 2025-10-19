import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_list/domain/product.dart';
import 'package:smart_list/core/error/result.dart';
import 'package:smart_list/presentation/widgets/form.dart';
import 'package:smart_list/presentation/widgets/product_card.dart';
import 'package:smart_list/use_cases/product_use_cases.dart';

class ProductsPage extends StatelessWidget {
  final GetCachedProductsUseCase getCachedProductsUseCase;

  const ProductsPage({super.key, required this.getCachedProductsUseCase});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ProductForm(
              product: Product(
                id: '0',
                name: 'Producto de prueba',
                data: {'price': 0.0},
              ),
              onSave: () {},
              actionLabel: 'Agregar',
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<Result<List<Product>>>(
                future: getCachedProductsUseCase.call(),
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
                      ),
                    );
                  }
                  final products = result.data!;

                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ProductCard(
                          product: product,
                          onEdit: () {},
                          onDelete: () {},
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