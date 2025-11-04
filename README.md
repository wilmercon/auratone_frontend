# AuraTone - Frontend (Flutter)

Sistema web de venta de instrumentos musicales desarrollado con Flutter. Interfaz moderna y responsive conectada al backend.

## Descripción

AuraTone es una plataforma de comercio electrónico especializada en instrumentos musicales con dos tipos de usuarios:

- **Usuarios regulares**: Navegan el catálogo, agregan productos al carrito y realizan compras
- **Administradores**: Gestionan productos, usuarios e inventario

## Características

### Para Usuarios
- Sistema de autenticación seguro (login/registro)
- Catálogo de productos por categorías
- Carrito de compras interactivo con scroll
- Diseño responsive y moderno

### Para Administradores
- Gestión completa de usuarios registrados
- CRUD de productos (Crear, Leer, Actualizar, Eliminar)
- Control de inventario y stock
- Eliminación de usuarios con confirmación

## Tecnologías

- **Flutter 3.x** - Framework multiplataforma
- **Dart** - Lenguaje de programación
- **Material Design** - Sistema de diseño
- **HTTP** - Comunicación con API REST
- **Shared Preferences** - Almacenamiento local de sesión

##  Estructura del Proyecto

```
frontend/
├── lib/
│   ├── main.dart                 # Punto de entrada
│   ├── models/                   # Modelos de datos
│   │   ├── product_model.dart
│   │   └── user_model.dart
│   ├── screens/                  # Pantallas
│   │   ├── login_page.dart       # Inicio de sesión
│   │   ├── signup_page.dart      # Registro
│   │   ├── home_page.dart        # Catálogo (usuarios)
│   │   └── admin_page.dart       # Panel admin
│   ├── services/                 # Servicios API
│   │   ├── auth_service.dart
│   │   └── product_service.dart
│   └── widgets/                  # Componentes reutilizables
├── assets/images/                # Recursos visuales
└── pubspec.yaml                  # Dependencias
```

##  Requisitos

- Flutter SDK 3.x o superior
- Dart SDK (incluido con Flutter)
- Navegador web (Chrome recomendado)

## Inicializar plataforma y dependencias

Dentro de `frontend/` ejecute:

```bash
flutter create .
flutter config --enable-web
flutter pub get
```

Luego instale los paquetes:

```bash
flutter pub add http shared_preferences
```

## Ejecutar en web (Desarrollo)

```bash
flutter run -d chrome
```
## Diseño y Estilo

- **Colores principales**: Azul (#1976D2)
- **Tipografía**: Roboto (Material Design)
- **Imágenes de fondo**: 
  - `music_login.jpg` - Login y registro
- **Componentes**: Cards, Buttons, TextFields personalizados

## Seguridad

- Autenticación basada en sesión
- Validación de formularios
- Protección de rutas administrativas
- Almacenamiento seguro de sesión local

## Pantallas Principales

### 1. Login 
- Formulario de inicio de sesión
- Validación de email y contraseña
- Redirección según rol (usuario/admin)
- Link a registro

### 2. Registro 
- Formulario completo de registro
- Campos: CI, nombres, apellidos, email, contraseñas
- Validación en tiempo real
- Confirmación de contraseña

### 3. Home - Catálogo 
- Navegación por categorías
- Grid de productos con imágenes
- Carrito de compras
- Botón de añadir al carrito
- Logout

### 4. Admin Panel 
- Tabla de usuarios registrados
- Gestión de productos (CRUD)
- Control de stock
- Estadísticas

##  Licencia

Este proyecto es parte de un trabajo académico.

**AuraTone** - Sistema de Venta de Instrumentos Musicales 
