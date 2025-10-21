import 'package:flutter/material.dart';
import 'package:smart_list/domain/product.dart';

//form reutlizable
class ProductForm extends StatefulWidget {
  final Product product;
  final Future<void> Function(Product) onSave;
  final Future<void> Function(Product)? onUpdate;
  final String actionLabel;
  final bool isEditing;
  const ProductForm({
    super.key,
    required this.product,
    required this.onSave,
    required this.onUpdate,
    required this.actionLabel,
    this.isEditing = false,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  // Controlador para el campo de texto del producto
  late final TextEditingController _productController;
  late double _price = 0.00;
  late final TextEditingController _priceController;
  final FocusNode _priceFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _productController = TextEditingController(text: widget.product.name);
    _price = (widget.product.data?['price'] as num?)?.toDouble() ?? 0.00;
    _priceController = TextEditingController(
      text: widget.product.name.isEmpty ? '' : _price.toStringAsFixed(2),
    );

    // Cuando el usuario deja el campo, formateamos el valor
    _priceFocusNode.addListener(() {
      if (!_priceFocusNode.hasFocus) {
        _priceController.text = _price.toStringAsFixed(2);
      }
    });

    // print('El producto es: $_productController');
  }

  @override
  void didUpdateWidget(covariant ProductForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si el producto cambió, actualizar los controllers
    if (oldWidget.product.id != widget.product.id) {
      _productController.text = widget.product.name;
      _price = (widget.product.data?['price'] as num?)?.toDouble() ?? 0.0;
      _priceController.text = widget.product.name.isEmpty
          ? ''
          : _price.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _productController.dispose();
    _priceController.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({String? initialText}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 15.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 2.0,
        ),
      ),
      hintText: initialText,
    );
  }

  Widget _quantityField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.0),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _priceController,
              focusNode: _priceFocusNode,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                hintText: 'Precio', // placeholder
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 15.0,
                ),
              ),
              style: TextStyle(
                fontSize: 18.0,
                color: _priceController.text.isEmpty
                    ? Colors.grey[500]
                    : Colors.black,
                letterSpacing: 0.5,
              ),
              onTap: () {
                // Solo limpiar al agregar un producto nuevo
                if (!widget.isEditing && _priceController.text.isNotEmpty) {
                  _priceController.clear();
                }
              },
              onChanged: (value) {
                final parsed =
                    double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
                setState(() {
                  _price = parsed;
                });
              },
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              InkWell(
                onTap: () {
                  setState(() {
                    _price += 1.00;
                    _priceController.text = _price.toStringAsFixed(2);
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    Icons.arrow_drop_up,
                    size: 24.0,
                    color: Colors.grey,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    if (_price >= 1.00) _price -= 1.00;
                    _priceController.text = _price.toStringAsFixed(2);
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    Icons.arrow_drop_down,
                    size: 24.0,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = const Color(0xFF6A5ACD);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextFormField(
          controller: _productController,
          decoration: _inputDecoration(initialText: 'Nombre del producto'),
          // CONSISTENCIA: Usar Colors.black para el texto ingresado (no gris)
          style: const TextStyle(
            fontSize: 18.0,
            letterSpacing: 0.5,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 15.0),
        _quantityField(),

        const SizedBox(height: 25.0),

        // Botón principal
        ElevatedButton(
          onPressed: () async {
            final name = _productController.text.trim();
            final price = _price;

            //  Validar campos vacíos
            if (name.isEmpty) {
              _showSnackBar('Por favor ingresa un nombre para el producto');
              return;
            }

            if (price <= 0) {
              _showSnackBar('Por favor ingresa un precio válido');
              return;
            }

            // Actualizar valores del producto desde los TextFields
            widget.product.name = _productController.text;
            widget.product.data ??= {};
            widget.product.data!['price'] = _price;

            // Ejecutar la acción correcta
            if (widget.isEditing && widget.onUpdate != null) {
              await widget.onUpdate!(widget.product);
            } else {
              await widget.onSave(widget.product);
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Center(
                  child: Text(
                    'Acción realizada con éxito',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
          child: Text(
            widget.actionLabel,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
