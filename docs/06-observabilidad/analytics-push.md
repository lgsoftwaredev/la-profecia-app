# Analytics y Push - La Profecia MVP

## 1. Objetivo
Medir comportamiento basico de uso y activar comunicacion simple de reenganche, sin sobredisenar observabilidad.

## 2. Analytics (Google Analytics)

### Eventos minimos
- apertura de app
- inicio de tutorial
- tutorial completado
- inicio de partida
- partida completada
- paywall visto
- compra iniciada/completada/fallida

### Parametros recomendados
- modo de juego
- nivel
- tipo de usuario (guest/logged)
- estado premium
- plataforma (android/ios)

### Uso esperado
- medir conversion de onboarding
- detectar abandonos en flujo de juego
- entender embudo freemium -> premium

## 3. Push Notifications (FCM)

### Casos MVP
- recordatorio de volver a jugar
- mensajes simples de novedades de contenido
- comunicaciones de valor para usuarios registrados

### Reglas de experiencia
- no enviar volumen excesivo
- respetar consentimiento/notification settings
- priorizar mensajes de valor real

## 4. Buenas practicas
- nombrado consistente de eventos.
- versionado de eventos si cambia semantica.
- tablero simple con KPIs de uso y conversion.
- validacion de eventos en QA previo a release.
