/*
* Panel de administración:
* - Lista de usuarios registrados con roles (admin/user)
* - Tabla con información detallada de usuarios
* - Gestión completa de productos (CRUD)
* - Control de stock de productos
* - Control de acceso solo para administradores
* - Funcionalidad de cerrar sesión
*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../widgets/common_widgets.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  static const routeName = '/admin';

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // Variables para gestión de usuarios
  List<User>? _users;
  String? _error;
  bool _loading = true;
  
  // Variables para gestión de productos
  List<Product>? _products;
  String? _productError;
  bool _loadingProducts = true;
  
  // Variable para controlar qué pestaña está activa (0: Usuarios, 1: Productos)
  int _selectedTab = 0;
  
  // Variable para filtrar productos por categoría
  String _selectedProductCategory = 'Todas';
  
  // Servicio de productos
  final _productService = ProductService();

  @override
  void initState() {
    super.initState();
    // Verificar permisos de admin y cargar datos iniciales
    _checkAdminAndLoadUsers();
    _loadProducts();
  }

  // Verifica si el usuario es administrador y carga la lista de usuarios
  Future<void> _checkAdminAndLoadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString('session_user');
    if (rawUser == null) {
      setState(() => _error = 'No hay sesión activa');
      return;
    }

    final user = jsonDecode(rawUser) as Map<String, dynamic>;
    if (user['role'] != 'admin') {
      setState(() => _error = 'Acceso no autorizado');
      return;
    }

    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final result = await AuthService().getUsers();
      
      // Obtener la información del administrador actual
      final prefs = await SharedPreferences.getInstance();
      final rawUser = prefs.getString('session_user');
      
      List<User> usersList = (result['users'] as List).map((u) => User.fromJson(u)).toList();
      
      // Agregar el administrador actual 
      if (rawUser != null) {
        final adminData = jsonDecode(rawUser) as Map<String, dynamic>;
        if (adminData['role'] == 'admin') {
          int adminIndex = usersList.indexWhere((u) => u.email == adminData['email']);
          final adminUser = User(
            id: 0, // ID 0 para identificar como admin
            ci: adminData['ci'] ?? 'N/A',
            firstName: adminData['firstName'] ?? 'Administrador',
            middleName: adminData['middleName'],
            lastName: adminData['lastName'] ?? 'Sistema',
            secondLastName: adminData['secondLastName'],
            email: adminData['email'] ?? 'admin@auratone.com',
            createdAt: DateTime(2025, 10, 15),
          );
          if (adminIndex >= 0) {
            usersList[adminIndex] = adminUser;
          } else {
            usersList.insert(0, adminUser);
          }
        }
      }

      setState(() {
        _users = usersList;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  // Carga la lista de productos desde el servicio
  Future<void> _loadProducts() async {
    try {
      setState(() {
        _loadingProducts = true;
        _productError = null;
      });

      final products = await _productService.getProducts();

      setState(() {
        _products = products;
      });
    } catch (e) {
      setState(() => _productError = e.toString());
    } finally {
      setState(() => _loadingProducts = false);
    }
  }

  // Cierra la sesión del administrador y redirige al login
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_user');
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  // Muestra el diálogo para agregar o editar un producto
  Future<void> _showProductDialog({Product? product}) async {
    final isEditing = product != null;
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final categoryCtrl = TextEditingController(text: product?.category ?? '');
    final priceCtrl = TextEditingController(text: product?.price.toString() ?? '');
    final stockCtrl = TextEditingController(text: product?.stock.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Producto' : 'Agregar Producto'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Campo de nombre del producto
                CustomTextField(
                  controller: nameCtrl,
                  label: 'Nombre del producto',
                  icon: Icons.shopping_bag,
                  validator: (v) => v?.isEmpty ?? true ? 'Ingrese el nombre' : null,
                ),
                const SizedBox(height: 12),
                // Campo de categoría
                CustomTextField(
                  controller: categoryCtrl,
                  label: 'Categoría',
                  icon: Icons.category,
                  validator: (v) => v?.isEmpty ?? true ? 'Ingrese la categoría' : null,
                ),
                const SizedBox(height: 12),
                // Campo de precio
                CustomTextField(
                  controller: priceCtrl,
                  label: 'Precio',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Ingrese el precio';
                    if (double.tryParse(v!) == null) return 'Precio inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Campo de stock
                CustomTextField(
                  controller: stockCtrl,
                  label: 'Stock',
                  icon: Icons.inventory,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Ingrese el stock';
                    if (int.tryParse(v!) == null) return 'Stock inválido';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          // Botón cancelar
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          // Botón guardar
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final result = isEditing
                  ? await _productService.updateProduct(
                      id: product.id,
                      name: nameCtrl.text.trim(),
                      category: categoryCtrl.text.trim(),
                      price: double.parse(priceCtrl.text),
                      stock: int.parse(stockCtrl.text),
                    )
                  : await _productService.addProduct(
                      name: nameCtrl.text.trim(),
                      category: categoryCtrl.text.trim(),
                      price: double.parse(priceCtrl.text),
                      stock: int.parse(stockCtrl.text),
                    );

              if (!mounted) return;
              Navigator.pop(context);

              if (result['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEditing
                        ? 'Producto actualizado correctamente'
                        : 'Producto agregado correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadProducts();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['error'] ?? 'Error al guardar producto'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(isEditing ? 'Actualizar' : 'Agregar'),
          ),
        ],
      ),
    );
  }

  // Muestra el diálogo para actualizar solo el stock de un producto
  Future<void> _showStockDialog(Product product) async {
    final stockCtrl = TextEditingController(text: product.stock.toString());
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar Stock'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Producto: ${product.name}'),
              const SizedBox(height: 16),
              CustomTextField(
                controller: stockCtrl,
                label: 'Nuevo Stock',
                icon: Icons.inventory,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Ingrese el stock';
                  if (int.tryParse(v!) == null) return 'Stock inválido';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final result = await _productService.updateStock(
                id: product.id,
                newStock: int.parse(stockCtrl.text),
              );

              if (!mounted) return;
              Navigator.pop(context);

              if (result['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Stock actualizado correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadProducts();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['error'] ?? 'Error al actualizar stock'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  // Confirma y elimina un producto
  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _productService.deleteProduct(product.id);
      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadProducts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error al eliminar producto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // AppBar con título y botón de cerrar sesión
        appBar: AppBar(
          title: const Text('Panel de Administración'),
          backgroundColor: Colors.blue.shade700,
          leading: IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
          ),
          // Pestañas para cambiar entre Usuarios y Productos
          bottom: TabBar(
            onTap: (index) => setState(() => _selectedTab = index),
            tabs: const [
              Tab(icon: Icon(Icons.people), text: 'Usuarios'),
              Tab(icon: Icon(Icons.inventory), text: 'Productos'),
            ],
          ),
        ),
        // Cuerpo que cambia según la pestaña seleccionada
        body: _selectedTab == 0 ? _buildUsersView() : _buildProductsView(),
        // Botón flotante para agregar productos (solo visible en pestaña de productos)
        floatingActionButton: _selectedTab == 1
            ? FloatingActionButton.extended(
                onPressed: () => _showProductDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Agregar Producto'),
                backgroundColor: Colors.blue.shade700,
              )
            : null,
      ),
    );
  }

  // Vista de la tabla de usuarios con columna de rol
  Widget _buildUsersView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Usuarios Registrados',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_error != null)
                ErrorMessage(message: _error!)
              else if (_users?.isEmpty ?? true)
                const Center(child: Text('No hay usuarios registrados'))
              else
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: Container(
                        // Contenedor con borde para toda la tabla
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DataTable(
                          columnSpacing: 24,
                          horizontalMargin: 16,
                          // Estilo para las líneas divisorias de la tabla
                          dividerThickness: 1,
                          border: TableBorder.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          headingRowColor: MaterialStateProperty.all(
                            Colors.blue.shade50,
                          ),
                          headingTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          // Columnas de la tabla incluyendo Rol
                          columns: const [
                            DataColumn(label: Text('Nombre')),
                            DataColumn(label: Text('CI'), numeric: true),
                            DataColumn(label: Text('Correo')),
                            DataColumn(label: Text('Rol')),
                            DataColumn(label: Text('Fecha de Registro')),
                            DataColumn(label: Text('Eliminar')),
                          ],
                          rows: _users!.map((user) {
                            // Combinar nombre completo (nombres + apellidos)
                            final nombreCompleto = [
                              user.firstName,
                              user.middleName,
                              user.lastName,
                              user.secondLastName
                            ].where((n) => n != null && n.isNotEmpty).join(' ');

                            // Formatear fecha a dd/mm/yyyy
                            final fecha = user.createdAt.toLocal();
                            final fechaFormateada = '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';

                            return DataRow(cells: [
                              // Nombre completo
                              DataCell(
                                Container(
                                  constraints: const BoxConstraints(minWidth: 200),
                                  child: Text(nombreCompleto),
                                ),
                              ),
                              // CI
                              DataCell(Text(user.ci)),
                              // Correo
                              DataCell(
                                Container(
                                  constraints: const BoxConstraints(minWidth: 200),
                                  child: Text(user.email),
                                ),
                              ),
                              // Celda de rol con badge de color
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: user.id == 0
                                        ? Colors.red.shade100
                                        : Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    user.id == 0 ? 'Administrador' : 'Usuario',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: user.id == 0
                                          ? Colors.red.shade700
                                          : Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              ),
                              // Fecha formateada
                              DataCell(
                                Text(fechaFormateada),
                              ),
                              // Botón de borrar usuario
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    // Mostrar diálogo de confirmación
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirmar eliminación'),
                                        content: Text(
                                          '¿Está seguro que desea eliminar al usuario $nombreCompleto?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              // TODO: Implementar eliminación de usuario
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Eliminado'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  tooltip: 'Eliminar',
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Vista de la tabla de productos con botones de acción y filtro por categoría
  Widget _buildProductsView() {
    // Obtener lista de categorías únicas de los productos
    final categories = ['Todas'];
    if (_products != null) {
      final uniqueCategories = _products!.map((p) => p.category).toSet().toList();
      categories.addAll(uniqueCategories..sort());
    }

    // Filtrar productos según la categoría seleccionada
    final filteredProducts = _selectedProductCategory == 'Todas'
        ? _products
        : _products?.where((p) => p.category == _selectedProductCategory).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado con título y filtro de categoría
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gestión de Productos',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  // Dropdown para filtrar por categoría
                  if (!_loadingProducts && _products != null && _products!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedProductCategory,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.filter_list),
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(
                              category,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedProductCategory = value ?? 'Todas';
                          });
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (_loadingProducts)
                const Center(child: CircularProgressIndicator())
              else if (_productError != null)
                ErrorMessage(message: _productError!)
              else if (filteredProducts?.isEmpty ?? true)
                Center(
                  child: Text(
                    _selectedProductCategory == 'Todas'
                        ? 'No hay productos registrados'
                        : 'No hay productos en la categoría "$_selectedProductCategory"',
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: Container(
                        // Contenedor con borde para toda la tabla
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DataTable(
                          columnSpacing: 20,
                          horizontalMargin: 16,
                          // Estilo para las líneas divisorias de la tabla
                          dividerThickness: 1,
                          border: TableBorder.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          headingRowColor: MaterialStateProperty.all(
                            Colors.blue.shade50,
                          ),
                          headingTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          // Columnas de la tabla de productos
                          columns: const [
                            DataColumn(label: Text('ID'), numeric: true),
                            DataColumn(label: Text('Nombre')),
                            DataColumn(label: Text('Categoría')),
                            DataColumn(label: Text('Precio')),
                            DataColumn(label: Text('Stock')),
                            DataColumn(label: Text('Acciones')),
                          ],
                          rows: filteredProducts!.map((product) {
                            return DataRow(cells: [
                              DataCell(Text(product.id.toString())),
                              DataCell(
                                Container(
                                  constraints: const BoxConstraints(minWidth: 200),
                                  child: Text(product.name),
                                ),
                              ),
                              DataCell(
                                Container(
                                  constraints: const BoxConstraints(minWidth: 100),
                                  child: Text(product.category),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              // Celda de stock con indicador de color
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: product.stock < 10
                                        ? Colors.red.shade100
                                        : product.stock < 20
                                            ? Colors.orange.shade100
                                            : Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    product.stock.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: product.stock < 10
                                          ? Colors.red.shade700
                                          : product.stock < 20
                                              ? Colors.orange.shade700
                                              : Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ),
                              // Celda de acciones con botones
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Botón para actualizar stock
                                    IconButton(
                                      icon: const Icon(Icons.inventory_2, size: 20),
                                      tooltip: 'Actualizar Stock',
                                      color: Colors.orange,
                                      onPressed: () => _showStockDialog(product),
                                    ),
                                    // Botón para editar producto
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      tooltip: 'Editar',
                                      color: Colors.blue,
                                      onPressed: () => _showProductDialog(product: product),
                                    ),
                                    // Botón para eliminar producto
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      tooltip: 'Eliminar',
                                      color: Colors.red,
                                      onPressed: () => _deleteProduct(product),
                                    ),
                                  ],
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
