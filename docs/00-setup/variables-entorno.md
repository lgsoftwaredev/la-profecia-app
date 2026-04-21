# Variables de Entorno y Configuracion

## 1. Archivo `.env`
Ruta esperada: `apps/mobile/.env`

Ejemplo base:
```env
SUPABASE_URL=
SUPABASE_ANON_KEY=
GOOGLE_SERVER_CLIENT_ID=
GOOGLE_IOS_CLIENT_ID=
IAP_ANDROID_MONTHLY_PRODUCT_ID=
IAP_IOS_MONTHLY_PRODUCT_ID=
ADMOB_ANDROID_INTERSTITIAL_ID=
ADMOB_IOS_INTERSTITIAL_ID=
ENABLE_PUSH_AUTO_PERMISSION_PROMPT=true
```

## 2. Variables requeridas en app

### Backend (Supabase)
- `SUPABASE_URL`: URL del proyecto Supabase.
- `SUPABASE_ANON_KEY`: clave anon publica del proyecto.

### Auth social (Google)
- `GOOGLE_SERVER_CLIENT_ID`: client id web/server para login Google.
- `GOOGLE_IOS_CLIENT_ID`: client id iOS para login Google en iPhone/iPad.

### Monetizacion (IAP)
- `IAP_ANDROID_MONTHLY_PRODUCT_ID`: id del producto mensual en Google Play.
- `IAP_IOS_MONTHLY_PRODUCT_ID`: id del producto mensual en App Store Connect.

### Ads (AdMob)
- `ADMOB_ANDROID_INTERSTITIAL_ID`: ad unit interstitial Android.
- `ADMOB_IOS_INTERSTITIAL_ID`: ad unit interstitial iOS.

### Push
- `ENABLE_PUSH_AUTO_PERMISSION_PROMPT`: `true/false` para controlar prompt automatico de permisos push.

## 3. Archivos nativos requeridos
- Android: `apps/mobile/android/app/google-services.json`
- iOS: `apps/mobile/ios/Runner/GoogleService-Info.plist`
- FlutterFire: `apps/mobile/lib/firebase_options.dart`

## 4. Origen de valores
- Supabase: Settings -> API (`project URL` y `anon key`).
- Google Auth: consola Google Cloud / Firebase Auth provider.
- IAP: Google Play Console y App Store Connect.
- AdMob: panel AdMob (ad unit ids).

## 5. Seguridad
- No commitear secretos ni claves privadas.
- `.env` ya esta ignorado por git en `apps/mobile/.gitignore`.
- Rotar credenciales si fueron expuestas por error.

## 6. Verificacion rapida
```bash
cd /ruta/al/proyecto/la-profecia-app/apps/mobile
awk -F= '/^[A-Z0-9_]+=/ {print $1}' .env | sort
```
La salida debe incluir todas las variables listadas arriba.
