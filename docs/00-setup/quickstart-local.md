# Quickstart Local - Levantar la App

## 1. Objetivo
Levantar la app movil de La Profecia en entorno local (Android/iOS) con una configuracion minima reproducible para desarrollo y demo.

## 2. Prerrequisitos
- Flutter `3.41.5` (el repo incluye `.fvmrc` con esta version).
- Dart SDK compatible (incluido con Flutter).
- Java 17 (requerido por la configuracion Android actual).
- Android Studio + Android SDK (para Android).
- Xcode + CocoaPods (para iOS en macOS).

## 3. Clonar e instalar dependencias
```bash
cd /ruta/al/proyecto/la-profecia-app/apps/mobile
fvm flutter pub get
```

Si no usas FVM:
```bash
cd /ruta/al/proyecto/la-profecia-app/apps/mobile
flutter pub get
```

## 4. Configuracion minima requerida
1. Crear archivo `.env` en `apps/mobile/.env`.
2. Completar variables requeridas (ver `variables-entorno.md`).
3. Confirmar archivos Firebase nativos:
   - `apps/mobile/android/app/google-services.json`
   - `apps/mobile/ios/Runner/GoogleService-Info.plist`

## 5. Ejecutar la app
### Android
```bash
cd /ruta/al/proyecto/la-profecia-app/apps/mobile
fvm flutter run -d android
```

### iOS
```bash
cd /ruta/al/proyecto/la-profecia-app/apps/mobile
fvm flutter run -d ios
```

## 6. Validacion basica post-arranque
- La pantalla inicial abre sin crash.
- El flujo guest permite entrar al tutorial/juego base.
- No aparece error de configuracion de Supabase/Firebase al iniciar.

## 7. Comandos recomendados antes de entregar cambios
```bash
cd /ruta/al/proyecto/la-profecia-app
dart format .
cd apps/mobile
flutter analyze
```

## 8. Notas de entorno
- La app esta optimizada para Android e iOS (MVP).
- El proyecto usa Supabase como backend principal y Firebase para analytics/push.
- Para detalles de base de datos y migraciones, ver `supabase-local.md`.
