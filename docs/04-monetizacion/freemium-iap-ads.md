# Freemium, IAP y Ads - La Profecia MVP

## 1. Objetivo
Implementar monetizacion simple y estable, sin romper experiencia de juego local ni exponer contenido premium de forma accidental.

## 2. Modelo freemium definido
### Plan Free
- acceso al flujo base de juego
- acceso a contenido inicial
- anuncios habilitados en puntos definidos

### Plan Premium
- niveles/contenido extra habilitado
- experiencia sin anuncios
- beneficios persistentes asociados a cuenta/estado de compra

## 3. In-App Purchases (IAP)
- IAP como mecanismo oficial para desbloquear premium.
- Validacion de compra y restauracion segun plataforma.
- Estado premium reflejado de forma consistente en la app.

## 4. Politica de anuncios
- Ads solo en plan free.
- No interrumpir momentos criticos de decision del juego.
- Evitar exceso de frecuencia para no degradar retencion.

## 5. Reglas de gating (obligatorias)
- Toda pantalla/accion premium valida permiso premium antes de abrir.
- Ningun unlock premium depende unicamente de flags de UI.
- Reglas de acceso centralizadas en dominio, no dispersas en widgets.
- Casos offline deben respetar ultimo estado premium valido conocido.

## 6. Eventos de negocio recomendados
- `paywall_viewed`
- `purchase_started`
- `purchase_completed`
- `purchase_failed`
- `premium_content_opened`
- `ad_impression`

## 7. Riesgos y mitigacion
- Riesgo: exponer premium por error de UI.
  Mitigacion: validacion en casos de uso de dominio.
- Riesgo: inconsistencia compra restaurada.
  Mitigacion: flujo de restore testeado por plataforma.
- Riesgo: caida de UX por exceso de anuncios.
  Mitigacion: reglas de frecuencia y ubicacion controladas.
