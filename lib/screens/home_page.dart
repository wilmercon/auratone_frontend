/*
* Pantalla principal para usuarios regulares:
* - Muestra la interfaz principal del usuario
* - Carga productos dinámicamente desde ProductService
* - Gestiona la sesión del usuario
* - Permite cerrar sesión
*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variable para almacenar la información del usuario logueado
  Map<String, dynamic>? _user;

  // Variable para controlar qué categoría está seleccionada actualmente
  // Se inicializa vacía y se establece con la primera categoría disponible
  String _selectedCategory = '';

  // Lista que almacena los productos agregados al carrito
  // Cada producto tiene: name, price, quantity
  final List<Map<String, dynamic>> _cart = [];

  // Lista de productos cargados dinámicamente desde ProductService
  List<Product> _products = [];
  
  // Variable para controlar el estado de carga de productos
  bool _loadingProducts = true;
  
  // Servicio para gestionar productos
  final _productService = ProductService();
  
  // ScrollController para el carrito de compras
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Carga la información de sesión del usuario al iniciar la página
    _loadSession();
    // Carga los productos desde el servicio
    _loadProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Carga los productos desde ProductService
  Future<void> _loadProducts() async {
    setState(() => _loadingProducts = true);
    try {
      final products = await _productService.getProducts();
      setState(() {
        _products = products;
        _loadingProducts = false;
        // Establecer la primera categoría como seleccionada si no hay ninguna
        if (_selectedCategory.isEmpty && _categories.isNotEmpty) {
          _selectedCategory = _categories.first;
        }
      });
    } catch (e) {
      setState(() => _loadingProducts = false);
    }
  }

  // Obtiene las categorías únicas de los productos (sin la opción "Todas")
  List<String> get _categories {
    final uniqueCategories = _products.map((p) => p.category).toSet().toList();
    uniqueCategories.sort();
    return uniqueCategories;
  }

  // Filtra los productos según la categoría seleccionada
  // Ya no existe la opción "Todas", siempre filtra por una categoría específica
  List<Product> get _filteredProducts {
    return _products.where((p) => p.category == _selectedCategory).toList();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('session_user');
    setState(() =>
        _user = raw != null ? jsonDecode(raw) as Map<String, dynamic> : null);
  }

  // Muestra un diálogo de confirmación antes de cerrar sesión
  // Permite al usuario confirmar o cancelar la acción de cerrar sesión
  Future<void> _confirmLogout() async {
    // Muestra un diálogo modal con opciones de confirmar o cancelar
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        // Título del diálogo
        title: const Text('Cerrar sesión'),
        // Mensaje de confirmación
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        // Botones de acción
        actions: [
          // Botón para cancelar y permanecer en la sesión
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Retorna false
            child: const Text('Cancelar'),
          ),
          // Botón para confirmar el cierre de sesión
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true), // Retorna true
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Color rojo para indicar acción importante
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    // Si el usuario confirmó (shouldLogout == true), procede a cerrar sesión
    if (shouldLogout == true) {
      _logout();
    }
  }

  // Cierra la sesión del usuario eliminando los datos guardados
  // y redirige a la pantalla de login
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Elimina los datos de sesión del almacenamiento local
    await prefs.remove('session_user');
    if (!mounted) return;
    // Navega a la pantalla de login y elimina todas las rutas anteriores
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  // Función para agregar productos al carrito
  // Si el producto ya existe, incrementa la cantidad
  void _addToCart(String name, String price) {
    setState(() {
      final existingIndex = _cart.indexWhere((item) => item['name'] == name);
      if (existingIndex >= 0) {
        // Si el producto ya está en el carrito, aumentar cantidad
        _cart[existingIndex]['quantity']++;
      } else {
        // Si es un producto nuevo, agregarlo con cantidad 1
        _cart.add({
          'name': name,
          'price': price,
          'quantity': 1,
        });
      }
    });
    // Mostrar notificación de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name agregado al carrito'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  //Función para incrementar la cantidad de un producto en el carrito
  void _incrementQuantity(int index) {
    setState(() {
      _cart[index]['quantity']++;
    });
  }

  //Función para decrementar la cantidad de un producto en el carrito
  // Si la cantidad llega a 0, elimina el producto del carrito
  void _decrementQuantity(int index) {
    setState(() {
      if (_cart[index]['quantity'] > 1) {
        _cart[index]['quantity']--;
      } else {
        // Si la cantidad es 1, eliminar el producto del carrito
        _cart.removeAt(index);
      }
    });
  }

  // Muestra el carrito de compras en un diálogo centrado
  void _showCart() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        // Forma del diálogo con esquinas redondeadas
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Esquinas redondeadas
        ),
        // Elimina el padding por defecto del diálogo
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: _buildCartView(),
      ),
    );
  }

  //Función para calcular el total del carrito
  double _getTotal() {
    double total = 0;
    for (var item in _cart) {
      total += double.parse(item['price']) * item['quantity'];
    }
    return total;
  }

  // Construye la interfaz principal de la página de inicio
  // Muestra el AppBar con el carrito de compras y las pestañas de categorías
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior de la aplicación
      appBar: AppBar(
        // Título de la aplicación mostrado en el AppBar
        title: const Text('AuraTone'),
        // automaticallyImplyLeading: false elimina el botón de back/retroceso
        automaticallyImplyLeading: false,
        // Color de fondo azul sólido para el AppBar
        // Se cambió de degradado índigo-púrpura a azul sólido
        backgroundColor: Colors.blue.shade700,
        // Elevación para dar sombra al AppBar
        elevation: 4,
        // Acciones disponibles en la barra superior (carrito y cerrar sesión)
        actions: [
          // Stack permite superponer widgets, usado aquí para el badge del carrito
          Stack(
            children: [
              // Botón del carrito de compras
              IconButton(
                onPressed: _showCart, // Al presionar, muestra el modal del carrito
                icon: const Icon(Icons.shopping_cart),
                tooltip: 'Carrito',
              ),
              // Badge circular que muestra la cantidad de productos en el carrito
              // Solo se muestra si hay al menos un producto en el carrito
              if (_cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red, // Color rojo para llamar la atención
                      shape: BoxShape.circle, // Forma circular del badge
                    ),
                    child: Text(
                      '${_cart.length}', // Número de productos diferentes en el carrito
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Botón para cerrar sesión con confirmación
          IconButton(
            onPressed: _confirmLogout, 
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      // Cuerpo principal de la página con fondo de color sólido
      body: Container(
        // Fondo de color sólido gris claro para un diseño limpio
        // El color azul se aplica solo en el AppBar y botones de categorías
        color: Colors.grey.shade50,
        // Columna que contiene los botones de categorías y la vista de productos
        child: Column(
          children: [
            // Contenedor para los botones de categorías con fondo semi-transparente
            Container(
              // Fondo blanco semi-transparente para los botones
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                // Sombra sutil debajo de los botones
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              // Padding alrededor de los botones
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              // Fila de botones de categorías con scroll horizontal
              // Las categorías se cargan dinámicamente desde los productos
              child: _loadingProducts
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Permite desplazamiento horizontal
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Centra los botones
                        children: _categories.map((category) {
                          // Verifica si esta categoría es la seleccionada actualmente
                          final isSelected = category == _selectedCategory;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            // Botón de categoría con diseño personalizado
                            child: ElevatedButton(
                              // Al presionar, actualiza la categoría seleccionada
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                              // Estilo del botón que cambia según si está seleccionado o no
                              style: ElevatedButton.styleFrom(
                                // Color de fondo: azul si está seleccionado, blanco si no
                                backgroundColor: isSelected
                                    ? Colors.blue.shade700
                                    : Colors.white,
                                // Color del texto: blanco si está seleccionado, azul si no
                                foregroundColor:
                                    isSelected ? Colors.white : Colors.blue.shade700,
                                // Elevación (sombra): mayor si está seleccionado
                                elevation: isSelected ? 6 : 2,
                                // Padding interno del botón
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                // Bordes redondeados
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  // Borde visible solo si no está seleccionado
                                  // Color azul para mantener consistencia con el tema
                                  side: BorderSide(
                                    color: isSelected
                                        ? Colors.transparent
                                        : Colors.blue.shade300,
                                    width: 2,
                                  ),
                                ),
                              ),
                              // Texto del botón con el nombre de la categoría
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ),
            // Vista de productos que cambia según la categoría seleccionada
            // Expanded hace que ocupe todo el espacio vertical disponible
            Expanded(
              // Muestra la lista de productos filtrados por categoría
              child: _buildProductList(),
            ),
          ],
        ),
      ),
    );
  }

  // Construye la cuadrícula de productos para cada categoría
  // Muestra los productos en formato de tarjetas (cards) organizadas en columnas
  // Los productos se cargan dinámicamente desde ProductService
  // RESPONSIVO: El número de columnas se ajusta según el ancho de la pantalla
  Widget _buildProductList() {
    // Mostrar indicador de carga mientras se cargan los productos
    if (_loadingProducts) {
      return const Center(child: CircularProgressIndicator());
    }

    // Mostrar mensaje si no hay productos en la categoría seleccionada
    if (_filteredProducts.isEmpty) {
      return Center(
        child: Text(
          'No hay productos en la categoría "$_selectedCategory"',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcular número de columnas según el ancho disponible
        // Diseño responsivo que se adapta a diferentes tamaños de pantalla
        int crossAxisCount;
        double childAspectRatio;
        
        if (constraints.maxWidth > 1400) {
          // Pantallas muy grandes (monitores grandes, TVs)
          crossAxisCount = 6;
          childAspectRatio = 0.75;
        } else if (constraints.maxWidth > 1200) {
          // Pantallas grandes (laptops, monitores estándar)
          crossAxisCount = 5;
          childAspectRatio = 0.7;
        } else if (constraints.maxWidth > 900) {
          // Pantallas medianas (tablets en horizontal, laptops pequeñas)
          crossAxisCount = 4;
          childAspectRatio = 0.75;
        } else if (constraints.maxWidth > 600) {
          // Pantallas pequeñas (tablets en vertical, móviles grandes en horizontal)
          crossAxisCount = 3;
          childAspectRatio = 0.8;
        } else if (constraints.maxWidth > 400) {
          // Móviles en vertical
          crossAxisCount = 2;
          childAspectRatio = 0.85;
        } else {
          // Móviles muy pequeños
          crossAxisCount = 1;
          childAspectRatio = 1.0;
        }

        return GridView.builder(
          // Padding alrededor de la cuadrícula
          padding: const EdgeInsets.all(16.0),
          // Configuración responsiva de la cuadrícula
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount, // Número de columnas según ancho de pantalla
            childAspectRatio: childAspectRatio, // Relación ancho/alto ajustada
            crossAxisSpacing: 12, // Espacio horizontal entre tarjetas
            mainAxisSpacing: 12, // Espacio vertical entre tarjetas
          ),
          // Número total de productos a mostrar (filtrados por categoría)
          itemCount: _filteredProducts.length,
          // Constructor de cada tarjeta de producto
          itemBuilder: (context, index) {
            final product = _filteredProducts[index];
            return _buildProductCard(product);
          },
        );
      },
    );
  }

  // Construye la tarjeta de cada producto con diseño estilo e-commerce
  // Incluye: imagen placeholder, nombre, precio y botón de agregar al carrito
  // Ahora recibe un objeto Product en lugar de strings separados
  Widget _buildProductCard(Product product) {
    return Card(
      // Elevación para dar efecto de profundidad
      elevation: 3,
      // Bordes redondeados
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      // Contenido de la tarjeta
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Contenedor para la imagen del producto
          Expanded(
            flex: 3, // Ocupa 3/5 del espacio vertical
            child: ClipRRect(
              // Bordes redondeados solo en la parte superior
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              // Mostrar imagen del producto desde URL
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      // Placeholder mientras carga la imagen
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.indigo.shade50,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      // Mostrar icono si hay error al cargar la imagen
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.indigo.shade100,
                                Colors.purple.shade100,
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.music_note,
                            size: 40,
                            color: Colors.indigo.shade300,
                          ),
                        );
                      },
                    )
                  : Container(
                      // Mostrar degradado con icono si no hay URL de imagen
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.indigo.shade100,
                            Colors.purple.shade100,
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.music_note,
                        size: 40,
                        color: Colors.indigo.shade300,
                      ),
                    ),
            ),
          ),
          // Contenedor para la información del producto
          Expanded(
            flex: 2, // Ocupa 2/5 del espacio vertical
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Padding reducido para tarjetas más pequeñas
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nombre del producto (cargado dinámicamente)
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 12, // Tamaño de fuente reducido
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2, // Máximo 2 líneas
                    overflow: TextOverflow.ellipsis, // Agrega "..." si es muy largo
                  ),
                  // Fila con precio y botón de agregar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Precio del producto en bolivianos (cargado dinámicamente)
                      Expanded(
                        child: Text(
                          'Bs ${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14, // Tamaño de fuente reducido
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                      // Botón circular para agregar al carrito (más pequeño)
                      IconButton(
                        onPressed: () => _addToCart(
                          product.name,
                          product.price.toStringAsFixed(2),
                        ),
                        icon: const Icon(Icons.add_shopping_cart, size: 18), // Icono más pequeño
                        color: Colors.white,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          padding: const EdgeInsets.all(6), // Padding reducido
                        ),
                        tooltip: 'Añadir al carrito',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Construye la vista del carrito de compras con diseño mejorado
  // Incluye fondo degradado, esquinas redondeadas y diseño moderno
  Widget _buildCartView() {
    return Container(
      // Limita el tamaño del carrito
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
        maxWidth: 600, // Ancho máximo para que no se vea muy ancho en pantallas grandes
      ),
      // Decoración con fondo degradado y esquinas redondeadas
      decoration: BoxDecoration(
        // Fondo con degradado suave
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.indigo.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20), // Esquinas redondeadas
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Encabezado del carrito con fondo de color
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              // Fondo azul sólido para el encabezado
              color: Colors.blue.shade700,
              // Esquinas redondeadas solo en la parte superior
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Carrito de Compras',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Texto blanco sobre fondo oscuro
                  ),
                ),
                // Botón de cerrar con fondo circular
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
          // Mostrar mensaje si el carrito está vacío
          if (_cart.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'El carrito está vacío',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else ...[
            // Lista de productos en el carrito con padding
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: Scrollbar(
                  controller: _scrollController, // Asignar el controller
                  thumbVisibility: true, // Siempre visible
                  thickness: 8, // Grosor del scroll
                  radius: const Radius.circular(10), // Bordes redondeados
                  child: ListView.builder(
                    controller: _scrollController, // Asignar el mismo controller al ListView
                    padding: const EdgeInsets.all(16.0), // Padding dentro del ListView
                    shrinkWrap: true, // Ajusta al contenido
                    physics: const AlwaysScrollableScrollPhysics(), // Siempre permite scroll
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                    final item = _cart[index];
                    return Card(
                      // Elevación para dar profundidad
                      elevation: 2,
                      // Esquinas redondeadas en las tarjetas de productos
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre del producto
                          Text(
                            item['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Precio unitario en bolivianos
                              Text(
                                'Precio: Bs ${item['price']}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              // AGREGADO: Controles para aumentar/disminuir cantidad
                              Row(
                                children: [
                                  // Botón para disminuir cantidad
                                  IconButton(
                                    onPressed: () {
                                      _decrementQuantity(index);
                                      Navigator.pop(context);
                                      if (_cart.isNotEmpty) {
                                        _showCart();
                                      }
                                    },
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    color: Colors.red,
                                  ),
                                  // Mostrar cantidad actual
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${item['quantity']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  // Botón para aumentar cantidad
                                  IconButton(
                                    onPressed: () {
                                      _incrementQuantity(index);
                                      Navigator.pop(context);
                                      _showCart();
                                    },
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: Colors.green,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Botón para eliminar producto
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _cart.removeAt(index);
                                  });
                                  Navigator.pop(context);
                                  if (_cart.isNotEmpty) {
                                    _showCart();
                                  }
                                },
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                label: const Text(
                                  'Eliminar',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              // Subtotal del producto
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Subtotal',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    'Bs ${(double.parse(item['price']) * item['quantity']).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                  },
                ),
                ),
              ),
            ),
            // Divisor con estilo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(thickness: 2, color: Colors.indigo.shade200),
            ),
            // Sección de total a pagar con padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total a pagar:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Mostrar el total calculado en bolivianos con color verde
                  Text(
                    'Bs ${_getTotal().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            // Botón para finalizar la compra con diseño mejorado
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Mostrar mensaje de confirmación
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Compra realizada con éxito!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Vaciar el carrito después de la compra
                    setState(() {
                      _cart.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    // Esquinas redondeadas en el botón
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3, // Sombra del botón
                  ),
                  child: const Text(
                    'Finalizar Compra',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
