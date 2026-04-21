# Troubleshooting de Arranque

## 1. `flutter pub get` falla por version
### Sintoma
Errores de compatibilidad de SDK/Flutter.

### Accion
Usar la version del repo:
```bash
cd /ruta/al/proyecto/la-profecia-app/apps/mobile
fvm flutter --version
fvm flutter pub get
```

## 2. Android build falla por Java
### Sintoma
Errores Gradle/Kotlin relacionados a JVM.

### Accion
Confirmar Java 17:
```bash
java -version
```
El proyecto Android esta configurado con `JavaVersion.VERSION_17`.

## 3. Error de Firebase en Android/iOS
### Sintoma
`Default FirebaseApp is not initialized` o fallos de servicios Firebase.

### Accion
Verificar archivos:
- `apps/mobile/android/app/google-services.json`
- `apps/mobile/ios/Runner/GoogleService-Info.plist`
- `apps/mobile/lib/firebase_options.dart`

## 4. Error de Supabase al iniciar
### Sintoma
No conecta backend o falla autenticacion.

### Accion
- Revisar `SUPABASE_URL` y `SUPABASE_ANON_KEY` en `.env`.
- Confirmar que las claves no tengan espacios extra.
- Validar que el proyecto Supabase este activo.

## 5. iOS falla en pods
### Sintoma
Errores de pods/plugin al compilar iOS.

### Accion
```bash
cd /ruta/al/proyecto/la-profecia-app/apps/mobile
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter run -d ios
```

## 6. Productos IAP no aparecen
### Sintoma
Compra premium no disponible o product id invalido.

### Accion
- Revisar `IAP_ANDROID_MONTHLY_PRODUCT_ID` / `IAP_IOS_MONTHLY_PRODUCT_ID`.
- Confirmar que productos esten activos en stores.
- Probar con cuentas de testing de cada plataforma.

## 7. Ads no cargan
### Sintoma
Interstitial no muestra anuncio.

### Accion
- Revisar `ADMOB_ANDROID_INTERSTITIAL_ID` / `ADMOB_IOS_INTERSTITIAL_ID`.
- Verificar conectividad y estado de cuenta AdMob.
- En desarrollo, usar ids de prueba cuando aplique.

## 8. Checklist de recuperacion rapida
```bash
cd /ruta/al/proyecto/la-profecia-app/apps/mobile
flutter clean
flutter pub get
flutter analyze
flutter run
```
