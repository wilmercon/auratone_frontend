/*
* Servicio de gestión de productos:
* - CRUD completo de productos (Crear, Leer, Actualizar, Eliminar)
* - Gestión de stock
* - Almacenamiento en SharedPreferences
*/

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class ProductService {
  static const _productsKey = 'products_db';

  // Carga la lista de productos desde el almacenamiento local
  Future<List<Product>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_productsKey);
    if (raw == null) return _getDefaultProducts();

    final List list = jsonDecode(raw) as List;
    return list
        .map((p) => Product.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  // Guarda la lista de productos en el almacenamiento local
  Future<void> _saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = products.map((p) => p.toJson()).toList();
    await prefs.setString(_productsKey, jsonEncode(jsonList));
  }

  // Agrega un nuevo producto al sistema
  Future<Map<String, dynamic>> addProduct({
    required String name,
    required String category,
    required double price,
    required int stock,
    String? imageUrl,
  }) async {
    try {
      final products = await getProducts();

      // Generar nuevo ID (el máximo ID + 1)
      final newId = products.isEmpty
          ? 1
          : products.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;

      final newProduct = Product(
        id: newId,
        name: name,
        category: category,
        price: price,
        stock: stock,
        imageUrl: imageUrl ?? '',
        createdAt: DateTime.now(),
      );

      products.add(newProduct);
      await _saveProducts(products);

      return {'success': true, 'product': newProduct.toJson()};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Actualiza un producto existente
  Future<Map<String, dynamic>> updateProduct({
    required int id,
    String? name,
    String? category,
    double? price,
    int? stock,
    String? imageUrl,
  }) async {
    try {
      final products = await getProducts();
      final index = products.indexWhere((p) => p.id == id);

      if (index == -1) {
        return {'success': false, 'error': 'Producto no encontrado'};
      }

      // Actualizar solo los campos proporcionados
      products[index] = products[index].copyWith(
        name: name,
        category: category,
        price: price,
        stock: stock,
        imageUrl: imageUrl,
      );

      await _saveProducts(products);

      return {'success': true, 'product': products[index].toJson()};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Actualiza solo el stock de un producto
  Future<Map<String, dynamic>> updateStock({
    required int id,
    required int newStock,
  }) async {
    return updateProduct(id: id, stock: newStock);
  }

  // Elimina un producto del sistema
  Future<Map<String, dynamic>> deleteProduct(int id) async {
    try {
      final products = await getProducts();
      products.removeWhere((p) => p.id == id);
      await _saveProducts(products);

      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Productos por defecto para inicializar el sistema
  // 50 productos distribuidos en 5 categorías (10 productos por categoría)
  // Precios en bolivianos (Bs)
  // Incluye URLs de imágenes de instrumentos musicales
  List<Product> _getDefaultProducts() {
    return [
      // ========== GUITARRAS (10 productos) ==========
      Product(
          id: 1,
          name: 'Guitarra Acústica Yamaha F310',
          category: 'Guitarras',
          price: 1200.00,
          stock: 15,
          imageUrl:
              'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 2,
          name: 'Guitarra Eléctrica Fender Stratocaster',
          category: 'Guitarras',
          price: 3500.00,
          stock: 10,
          imageUrl:
              'https://images.unsplash.com/photo-1564186763535-ebb21ef5277f?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 3,
          name: 'Guitarra Clásica Española',
          category: 'Guitarras',
          price: 950.00,
          stock: 20,
          imageUrl:
              'https://images.unsplash.com/photo-1516924962500-2b4b3b99ea02?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 4,
          name: 'Guitarra Electroacústica Ibanez',
          category: 'Guitarras',
          price: 2800.00,
          stock: 12,
          imageUrl:
              'https://images.unsplash.com/photo-1525201548942-d8732f6617a0?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 5,
          name: 'Guitarra Eléctrica Gibson Les Paul',
          category: 'Guitarras',
          price: 8500.00,
          stock: 5,
          imageUrl:
              'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 6,
          name: 'Guitarra Acústica Takamine',
          category: 'Guitarras',
          price: 2200.00,
          stock: 18,
          imageUrl:
              'https://images.unsplash.com/photo-1550985616-10810253b84d?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 7,
          name: 'Guitarra Eléctrica Epiphone SG',
          category: 'Guitarras',
          price: 2500.00,
          stock: 14,
          imageUrl:
              'https://images.unsplash.com/photo-1510915228340-29c85a43dcfe?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 8,
          name: 'Guitarra Criolla Gracia',
          category: 'Guitarras',
          price: 650.00,
          stock: 25,
          imageUrl:
              'https://images.unsplash.com/photo-1556449895-a33c9dba33dd?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 9,
          name: 'Guitarra Bajo Fender Precision',
          category: 'Guitarras',
          price: 4200.00,
          stock: 8,
          imageUrl:
              'https://images.unsplash.com/photo-1556449895-a33c9dba33dd?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 10,
          name: 'Guitarra Acústica Cort Earth',
          category: 'Guitarras',
          price: 1500.00,
          stock: 16,
          imageUrl:
              'https://images.unsplash.com/photo-1519892300165-cb5542fb47c7?w=400',
          createdAt: DateTime.now()),

      // ========== BATERÍAS (10 productos) ==========
      Product(
          id: 11,
          name: 'Batería Acústica Pearl Export',
          category: 'Baterias',
          price: 5500.00,
          stock: 6,
          imageUrl:
              'https://images.unsplash.com/photo-1519892300165-cb5542fb47c7?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 12,
          name: 'Batería Electrónica Roland TD-17',
          category: 'Baterias',
          price: 6200.00,
          stock: 7,
          imageUrl:
              'https://images.unsplash.com/photo-1571327073757-71d13c24de30?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 13,
          name: 'Batería Infantil 5 Piezas',
          category: 'Baterías',
          price: 1200.00,
          stock: 25,
          imageUrl:
              'https://images.unsplash.com/photo-1519892300165-cb5542fb47c7?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 14,
          name: 'Batería Acústica Tama Imperialstar',
          category: 'Baterias',
          price: 4800.00,
          stock: 9,
          imageUrl:
              'https://images.unsplash.com/photo-1519892300165-cb5542fb47c7?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 15,
          name: 'Batería Electrónica Alesis Nitro',
          category: 'Baterias',
          price: 3500.00,
          stock: 12,
          imageUrl:
              'https://images.unsplash.com/photo-1571327073757-71d13c24de30?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 16,
          name: 'Batería Acústica Mapex Tornado',
          category: 'Baterias',
          price: 3200.00,
          stock: 10,
          imageUrl:
              'https://images.unsplash.com/photo-1519892300165-cb5542fb47c7?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 17,
          name: 'Batería Profesional DW Collectors',
          category: 'Baterias',
          price: 15000.00,
          stock: 3,
          imageUrl:
              'https://images.unsplash.com/photo-1519892300165-cb5542fb47c7?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 18,
          name: 'Batería Compacta Ludwig Breakbeats',
          category: 'Baterias',
          price: 4500.00,
          stock: 8,
          imageUrl:
              'https://images.unsplash.com/photo-1519892300165-cb5542fb47c7?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 19,
          name: 'Batería Electrónica Yamaha DTX452K',
          category: 'Baterias',
          price: 5800.00,
          stock: 6,
          imageUrl:
              'https://images.unsplash.com/photo-1571327073757-71d13c24de30?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 20,
          name: 'Batería Acústica Gretsch Catalina',
          category: 'Baterias',
          price: 6500.00,
          stock: 5,
          imageUrl:
              'https://images.unsplash.com/photo-1519892300165-cb5542fb47c7?w=400',
          createdAt: DateTime.now()),

      // ========== TECLADOS (10 productos) ==========
      Product(
          id: 21,
          name: 'Teclado Casio CTK-3500',
          category: 'Teclados',
          price: 1800.00,
          stock: 12,
          imageUrl:
              'https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 22,
          name: 'Piano Digital Yamaha P-45',
          category: 'Teclados',
          price: 4500.00,
          stock: 8,
          imageUrl:
              'https://images.unsplash.com/photo-1552422535-c45813c61732?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 23,
          name: 'Sintetizador Roland JUNO-DS61',
          category: 'Teclados',
          price: 6800.00,
          stock: 5,
          imageUrl:
              'https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 24,
          name: 'Teclado Yamaha PSR-E373',
          category: 'Teclados',
          price: 2200.00,
          stock: 15,
          imageUrl:
              'https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 25,
          name: 'Piano Digital Korg B2',
          category: 'Teclados',
          price: 3800.00,
          stock: 10,
          imageUrl:
              'https://images.unsplash.com/photo-1552422535-c45813c61732?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 26,
          name: 'Sintetizador Korg MicroKorg',
          category: 'Teclados',
          price: 5500.00,
          stock: 7,
          imageUrl:
              'https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 27,
          name: 'Teclado Casio LK-265',
          category: 'Teclados',
          price: 2500.00,
          stock: 14,
          imageUrl:
              'https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 28,
          name: 'Piano Digital Roland FP-30X',
          category: 'Teclados',
          price: 7200.00,
          stock: 6,
          imageUrl:
              'https://images.unsplash.com/photo-1552422535-c45813c61732?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 29,
          name: 'Órgano Electrónico Yamaha PSR-SX600',
          category: 'Teclados',
          price: 9500.00,
          stock: 4,
          imageUrl:
              'https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 30,
          name: 'Teclado Controlador MIDI Novation',
          category: 'Teclados',
          price: 1500.00,
          stock: 18,
          imageUrl:
              'https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=400',
          createdAt: DateTime.now()),

      // ========== INSTRUMENTOS DE VIENTO (10 productos) ==========
      Product(
          id: 31,
          name: 'Saxofón Alto Yamaha YAS-280',
          category: 'Instrumentos de Viento',
          price: 6500.00,
          stock: 9,
          imageUrl:
              'https://images.unsplash.com/photo-1511192336575-5a79af67a629?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 32,
          name: 'Trompeta Profesional Bach TR300',
          category: 'Instrumentos de Viento',
          price: 4200.00,
          stock: 11,
          imageUrl:
              'https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 33,
          name: 'Flauta Traversa Yamaha YFL-222',
          category: 'Instrumentos de Viento',
          price: 3500.00,
          stock: 18,
          imageUrl:
              'https://images.unsplash.com/photo-1465821185615-20b3c2fbf41b?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 34,
          name: 'Clarinete Buffet Crampon E11',
          category: 'Instrumentos de Viento',
          price: 5800.00,
          stock: 8,
          imageUrl:
              'https://images.unsplash.com/photo-1465821185615-20b3c2fbf41b?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 35,
          name: 'Saxofón Tenor Selmer AS42',
          category: 'Instrumentos de Viento',
          price: 8500.00,
          stock: 5,
          imageUrl:
              'https://images.unsplash.com/photo-1511192336575-5a79af67a629?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 36,
          name: 'Trombón de Varas Yamaha YSL-354',
          category: 'Instrumentos de Viento',
          price: 5200.00,
          stock: 7,
          imageUrl:
              'https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 37,
          name: 'Flauta Dulce Soprano Yamaha',
          category: 'Instrumentos de Viento',
          price: 180.00,
          stock: 30,
          imageUrl:
              'https://images.unsplash.com/photo-1465821185615-20b3c2fbf41b?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 38,
          name: 'Armónica Hohner Marine Band',
          category: 'Instrumentos de Viento',
          price: 450.00,
          stock: 25,
          imageUrl:
              'https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 39,
          name: 'Oboe Yamaha YOB-241',
          category: 'Instrumentos de Viento',
          price: 7800.00,
          stock: 4,
          imageUrl:
              'https://images.unsplash.com/photo-1465821185615-20b3c2fbf41b?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 40,
          name: 'Corno Francés Yamaha YHR-314II',
          category: 'Instrumentos de Viento',
          price: 9200.00,
          stock: 3,
          imageUrl:
              'https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=400',
          createdAt: DateTime.now()),

      // ========== INSTRUMENTOS TRADICIONALES (10 productos) ==========
      Product(
          id: 41,
          name: 'Charango Boliviano Profesional',
          category: 'Instrumentos Tradicionales',
          price: 850.00,
          stock: 15,
          imageUrl:
              'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 42,
          name: 'Quena de Bambú Afinada en Sol',
          category: 'Instrumentos Tradicionales',
          price: 280.00,
          stock: 22,
          imageUrl:
              'https://images.unsplash.com/photo-1465821185615-20b3c2fbf41b?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 43,
          name: 'Zampoña Malta 13 Tubos',
          category: 'Instrumentos Tradicionales',
          price: 420.00,
          stock: 18,
          imageUrl:
              'https://images.unsplash.com/photo-1465821185615-20b3c2fbf41b?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 44,
          name: 'Bombo Legüero Argentino',
          category: 'Instrumentos Tradicionales',
          price: 1500.00,
          stock: 8,
          imageUrl:
              'https://images.unsplash.com/photo-1519892300165-cb5542fb47c7?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 45,
          name: 'Cajón Peruano Profesional',
          category: 'Instrumentos Tradicionales',
          price: 650.00,
          stock: 20,
          imageUrl:
              'https://images.unsplash.com/photo-1519892300165-cb5542fb47c7?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 46,
          name: 'Tarka Boliviana de Madera',
          category: 'Instrumentos Tradicionales',
          price: 320.00,
          stock: 16,
          imageUrl:
              'https://images.unsplash.com/photo-1465821185615-20b3c2fbf41b?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 47,
          name: 'Siku Cromático 2 Hileras',
          category: 'Instrumentos Tradicionales',
          price: 580.00,
          stock: 12,
          imageUrl:
              'https://images.unsplash.com/photo-1465821185615-20b3c2fbf41b?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 48,
          name: 'Tambor Andino con Parche Natural',
          category: 'Instrumentos Tradicionales',
          price: 450.00,
          stock: 14,
          imageUrl:
              'https://images.unsplash.com/photo-1519892300165-cb5542fb47c7?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 49,
          name: 'Pinkillo de Caña Profesional',
          category: 'Instrumentos Tradicionales',
          price: 250.00,
          stock: 19,
          imageUrl:
              'https://images.unsplash.com/photo-1465821185615-20b3c2fbf41b?w=400',
          createdAt: DateTime.now()),
      Product(
          id: 50,
          name: 'Wankara Tradicional Boliviana',
          category: 'Instrumentos Tradicionales',
          price: 720.00,
          stock: 10,
          imageUrl:
              'https://images.unsplash.com/photo-1519892300165-cb5542fb47c7?w=400',
          createdAt: DateTime.now()),
    ];
  }
}
