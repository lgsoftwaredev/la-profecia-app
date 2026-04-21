# Publicacion en Tiendas - La Profecia MVP

## 1. Objetivo
Definir una ruta clara de salida a produccion para Android e iOS con controles minimos de calidad y cumplimiento.

## 2. Preparacion previa al release
- Versionado de app actualizado (build number y version).
- Changelog resumido para stakeholders.
- Assets de store y metadata revisados.
- Politica de privacidad y textos legales listos.

## 3. Gate tecnico antes de generar build
- `dart format .` ejecutado.
- `flutter analyze` sin errores criticos.
- Smoke test completo del flujo principal.

## 4. Gate funcional antes de envio
- Guest mode correcto.
- Monetizacion validada (free/premium/ads).
- Eventos de analytics verificados.
- Push basico validado.

## 5. Checklist Android
- Build firmado para release.
- Configuracion de in-app products activa.
- Pruebas en dispositivos representativos.
- Carga en Play Console y revision de warnings.

## 6. Checklist iOS
- Build firmado y subido a App Store Connect.
- Configuracion de IAP en estado correcto.
- Validacion en TestFlight.
- Reglas de compliance y privacidad completas.

## 7. Post-release (primeras 2 semanas)
- Monitorear crashes y eventos de embudo clave.
- Revisar retencion inicial y conversion premium.
- Priorizar fixes criticos sobre nuevas features.
- Consolidar feedback de usuarios para siguiente iteracion.
