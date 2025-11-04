/*
* Modelo de datos para productos:
* - Define la estructura de un producto en el sistema
* - Incluye información de inventario (stock)
* - Métodos para convertir a/desde JSON
*/

class Product {
  final int id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String imageUrl; // URL de la imagen del producto
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.createdAt,
  });

  // Crea una instancia de Product desde un mapa JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      imageUrl: json['image_url'] as String? ?? '',
      createdAt: json['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(json['created_at'] as String),
    );
  }

  // Convierte el producto a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Crea una copia del producto con valores modificados
  Product copyWith({
    int? id,
    String? name,
    String? category,
    double? price,
    int? stock,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
