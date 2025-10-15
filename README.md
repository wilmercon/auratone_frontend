# Frontend (Flutter)

UI de login conectada al backend Flask (`http://localhost:5000`).

## Requisitos
- Flutter SDK 3.x

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

## Ejecutar en web

```bash
flutter run -d chrome
```

## Variables
- El `ApiService` usa por defecto `http://localhost:5000`. Si cambia el puerto/host, edítelo en `lib/services/api_service.dart`.
