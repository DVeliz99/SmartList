import 'package:flutter/material.dart';
import 'package:smart_list/domain/product.dart';

class ProductForm extends StatefulWidget {
  final Product product;
  final Future<void> Function(Product) onSave;
  final String actionLabel;
  const ProductForm({
    super.key,
    required this.product,
    required this.onSave,
    required this.actionLabel,
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
      text: _price == 0.00 ? '' : _price.toStringAsFixed(2),
    );

    // Cuando el usuario deja el campo, formateamos el valor
    _priceFocusNode.addListener(() {
      if (!_priceFocusNode.hasFocus) {
        _priceController.text = _price.toStringAsFixed(2);
      }
    });
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
                hintText: 'Precio',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 15.0,
                ),
              ),
              style: TextStyle(
                fontSize: 18.0,
                color: _price == 0.00 ? Colors.grey[500] : Colors.black,
                letterSpacing: 0.5,
              ),
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
          onPressed: () {
            // Actualizar el objeto Product con los valores del estado local (MUTACIÓN)
            widget.product.name = _productController.text;

            // Asegurar que el mapa 'data' no es nulo antes de actualizar 'price'
            if (widget.product.data == null) {
              widget.product.data = {};
            }
            widget.product.data!['price'] = _price;

            // Mostrar SnackBar con la acción y datos actuales
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  // para debug
                  '${widget.actionLabel} producto: "${widget.product.name}" (ID: ${widget.product.id})',
                ),
              ),
            );

            // Ejecutar el callback
            widget.onSave(widget.product);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),

            elevation: 2,
          ),
          child: Text(
            widget.actionLabel,

            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
