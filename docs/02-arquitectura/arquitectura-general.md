# Arquitectura General - La Profecia MVP

## 1. Principios
- Arquitectura feature-first para escalar por modulos.
- Separacion explicita entre `presentation`, `domain` y `data`.
- Logica del juego desacoplada de widgets/UI.
- Integraciones externas encapsuladas en adapters/services.
- Cambios incrementales y verificables.

## 2. Vista de alto nivel

### Capa Presentation
Responsable de UI, navegacion, estado visual y manejo de eventos de usuario.

### Capa Domain
Responsable de reglas de negocio puras:
- reglas de turnos y rondas
- calculo de puntajes
- desbloqueo de niveles
- casos de uso de autenticacion y monetizacion

### Capa Data
Responsable de repositorios, adaptadores y fuentes de datos:
- almacenamiento local
- acceso a Supabase
- servicios de analytics/push/iap/ads

## 3. Organizacion recomendada (ejemplo)
```
apps/mobile/lib/
  core/
  features/
    gameplay/
      presentation/
      domain/
      data/
    auth/
      presentation/
      domain/
      data/
    monetization/
      presentation/
      domain/
      data/
    moderation/
      presentation/
      domain/
      data/
```

## 4. Limites de integracion
- Supabase no se consume directo desde UI.
- Firebase se usa para push y analytics, no como backend principal.
- IAP y Ads se centralizan en servicios de monetizacion.
- Repositorios exponen contratos estables al dominio.

## 5. Decisiones de escalabilidad
- Casos de uso por feature para reducir acoplamiento.
- Modelos de dominio independientes de DTO remotos.
- Mappers dedicados para transformar entre dominio y data.
- Contratos de repositorio pensados para test unitario.

## 6. Calidad y mantenimiento
- Preferencia por funciones puras en reglas de juego.
- Pruebas unitarias en domain para logica critica.
- Pruebas de integracion en data para adapters externos.
- Reglas de lint y formateo como puerta de calidad continua.
