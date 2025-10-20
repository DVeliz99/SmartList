class Product {
  final String id;
  String name;
  Map<String, dynamic>? data;
  DateTime? createdAt; //añadido opcionalmente en caso de que la api lo devuelva
  Product({required this.id, required this.name, this.data, this.createdAt});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'].toString(),
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'data': data,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  //Para envíos a la API
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'data': data};
  }

  //Version personalizada de toString para mejor visualización
  @override
  String toString() {
    return 'Product(id: $id, name: $name, data: $data, createdAt: $createdAt)';
  }
}
