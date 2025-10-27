# TPV Elyella

Sistema de Punto de Venta (TPV) construido con Flutter, soportando múltiples plataformas incluyendo PWA (Progressive Web App).

## 📋 Descripción

TPV Elyella es una aplicación completa para gestión de punto de venta que incluye:

- 🔐 **Autenticación JWT** con Supabase
- 🛍️ **Gestión de productos** con paginación, búsqueda y filtros
- 📱 **Multiplataforma**: Web (PWA), Android, iOS, Windows, macOS, Linux
- 🎨 **Diseño Material 3** con tema personalizado
- 🔄 **Estado centralizado** con manejo de sesión persistente

## 🚀 Inicio Rápido

### Requisitos Previos

- Flutter SDK 3.9.0 o superior
- Dart SDK 3.9.0 o superior
- Un editor de código (VS Code, Android Studio, IntelliJ IDEA)

### Instalación

1. **Clonar el repositorio**

```bash
git clone https://github.com/tu-usuario/tpv_elyella.git
cd tpv_elyella
```

2. **Instalar dependencias**

```bash
flutter pub get
```

3. **Configurar la URL del backend**

Opción A - Build time (recomendado para producción):

```bash
flutter run --dart-define=BACKEND_URL=https://tu-backend.com
```

Opción B - Runtime (útil para desarrollo):

```dart
// En lib/main.dart
void main() {
  Config.setBackendUrl('http://localhost:3000'); // URL de desarrollo
  runApp(const MyApp());
}
```

### Ejecutar la Aplicación

#### Desarrollo Web (PWA)

```bash
# Con URL de desarrollo
flutter run -d chrome --dart-define=BACKEND_URL=http://localhost:3000

# O con runtime config en main.dart
flutter run -d chrome
```

#### Desarrollo Móvil

```bash
# Android
flutter run -d android --dart-define=BACKEND_URL=https://tu-backend.com

# iOS
flutter run -d ios --dart-define=BACKEND_URL=https://tu-backend.com
```

#### Build para Producción (PWA)

```bash
flutter build web --release --dart-define=BACKEND_URL=https://api.tudominio.com
```

Los archivos compilados estarán en `build/web/`

## 🏗️ Estructura del Proyecto

```
lib/
├── config.dart                 # Configuración centralizada (BACKEND_URL)
├── main.dart                   # Punto de entrada de la app
├── models/                     # Modelos de datos
├── screens/                    # Pantallas de la aplicación
│   ├── login.dart             # Pantalla de autenticación
│   └── productoScreen.dart    # Gestión de productos
├── services/                   # Servicios de API
│   ├── auth_service.dart      # Servicio de autenticación
│   ├── user_service.dart      # Servicio de usuarios
│   └── producto_service.dart  # Servicio de productos
└── widgets/                    # Widgets reutilizables

web/
├── index.html                  # HTML principal para PWA
├── manifest.json              # Manifiesto PWA
└── icons/                     # Iconos de la aplicación
```

## ⚙️ Configuración del Backend

### Variables de Entorno

La aplicación utiliza `Config.backendUrl` para todas las llamadas API. Puedes configurarlo de dos formas:

1. **Build-time** usando `--dart-define`:

```bash
flutter build web --dart-define=BACKEND_URL=https://api.production.com
```

2. **Runtime** en el código:

```dart
import 'package:tpv_elyella/config.dart';

void main() {
  // Solo para desarrollo/testing
  Config.setBackendUrl('http://192.168.1.100:3000');
  runApp(const MyApp());
}
```

### Endpoints Esperados del Backend

El backend debe implementar los siguientes endpoints:

#### Autenticación

- `POST /auth/login` - Login con email/password
  - Body: `{ "email": "...", "password": "..." }`
  - Response: `{ "data": { "session": { "access_token": "..." } } }`

#### Productos

- `GET /productos` - Listar productos con paginación
  - Query params: `page`, `limit`, `search`, `categoria_id`, `activo`, `order_by`, `order_dir`
  - Response: `{ "data": [...], "pagination": { "total_items": 100, "total_pages": 5, "current_page": 1 } }`
- `GET /productos/:id` - Obtener producto específico
- `POST /productos` - Crear nuevo producto
- `PUT /productos/:id` - Actualizar producto
- `DELETE /productos/:id` - Desactivar producto (soft delete)
- `GET /productos/search/quick` - Búsqueda rápida para TPV
- `GET /productos/stats/overview` - Estadísticas de productos

## 🔐 Autenticación

La aplicación usa JWT tokens almacenados en `SharedPreferences`:

1. El usuario inicia sesión en `/` (LoginScreen)
2. El token se extrae de `data.session.access_token` o `data['data']['session']['access_token']`
3. El token se guarda con la clave `"auth_token"`
4. Todas las peticiones incluyen `Authorization: Bearer <token>`
5. Si hay un 401, se redirige automáticamente al login

## 📱 PWA (Progressive Web App)

### Características PWA

- ✅ Instalable en dispositivos móviles y escritorio
- ✅ Funciona offline (con service worker de Flutter)
- ✅ Tema de color personalizado (#0175C2)
- ✅ Iconos adaptativos y maskable
- ✅ Manifest.json configurado

### Configuración PWA

Edita `web/manifest.json` para personalizar:

- `name`: Nombre de la aplicación
- `short_name`: Nombre corto
- `description`: Descripción
- `theme_color`: Color del tema
- `background_color`: Color de fondo
- `icons`: Iconos (192x192, 512x512, maskable)

### Desplegar PWA

1. Build de producción:

```bash
flutter build web --release --dart-define=BACKEND_URL=https://api.tudominio.com
```

2. Subir `build/web/` a tu servidor web (Nginx, Apache, Firebase Hosting, Vercel, etc.)

3. Configurar HTTPS (requerido para PWA)

## 🧪 Testing

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests con cobertura
flutter test --coverage

# Ver reporte de cobertura
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 📦 Dependencias Principales

- `http: ^1.5.0` - Cliente HTTP para llamadas API
- `shared_preferences: ^2.5.3` - Almacenamiento local persistente
- `cupertino_icons: ^1.0.8` - Iconos iOS

Ver `pubspec.yaml` para la lista completa.

## 🛠️ Comandos Útiles

```bash
# Limpiar el proyecto
flutter clean

# Obtener dependencias
flutter pub get

# Analizar código
flutter analyze

# Formatear código
flutter format lib/

# Ver dispositivos disponibles
flutter devices

# Hot reload (en app en ejecución)
r

# Hot restart (en app en ejecución)
R

# Abrir DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

## 🐛 Troubleshooting

### Error: "No autorizado"

- Verifica que el token se esté guardando correctamente
- Revisa que el backend esté recibiendo el header `Authorization`
- Comprueba que el token no haya expirado

### Error: "La respuesta no es JSON"

- Verifica que el backend esté corriendo
- Confirma que la URL en `Config.backendUrl` sea correcta
- Revisa que el backend devuelva `Content-Type: application/json`

### Productos no se muestran

- Verifica que el parámetro `activo: true` se esté enviando
- Revisa los logs en la consola (modo debug)
- Confirma que haya productos activos en la base de datos

### CORS en desarrollo web

Si estás desarrollando con `flutter run -d chrome`, asegúrate de que tu backend permita CORS:

```javascript
// Express.js ejemplo
app.use(
  cors({
    origin: "http://localhost:PORT", // Puerto de flutter web
    credentials: true,
  })
);
```

## 📝 Notas de Desarrollo

- **No hardcodear URLs**: Siempre usa `Config.backendUrl`
- **Logs de seguridad**: Evita loggear tokens o datos sensibles en producción
- **Validación de formularios**: Usa `Form` y `TextFormField` con validators
- **Manejo de errores**: Siempre usa try-catch en servicios API
- **Estado de carga**: Muestra indicadores de carga durante peticiones

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto es privado y no está publicado en pub.dev.

## 👥 Autores

- Tu Nombre - [GitHub](https://github.com/tu-usuario)

## 🙏 Agradecimientos

- Flutter Team por el excelente framework
- Supabase por el backend y autenticación
- Comunidad de Flutter por recursos y soporte
