# AGENTS.md

## Contexto del proyecto
Este repositorio implementa el MVP móvil de "La Profecía".

La kickoff define:
- App Flutter para Android e iOS
- Experiencia local/presencial en un solo dispositivo
- Modelo freemium
- Acceso invitado antes de login obligatorio
- Supabase como backend base para autenticación y persistencia
- Firebase Cloud Messaging para push notifications
- Google Analytics para medición básica
- In-App Purchases para premium
- Flujo inicial de sugerencias y moderación desde backend

## Prioridad de producto
La prioridad del MVP es:
1. experiencia local de juego fluida
2. estructura escalable
3. monetización básica
4. publicación en tiendas
No priorizar funcionalidades online multijugador en tiempo real.

## Reglas de implementación
- No agregar tecnologías nuevas sin justificación clara.
- Mantener Flutter como app principal.
- Mantener Supabase como backend principal salvo instrucción explícita en contra.
- Usar Firebase solo para push y analytics, no como backend central.
- No diseñar flujos complejos de tiempo real porque no forman parte del alcance actual.
- Preferir cambios pequeños y verificables.
- Siempre alinear el trabajo con los hitos de la kickoff.

## Arquitectura esperada
- feature-first consistente
- Separar presentation, domain y data
- Mantener lógica del juego desacoplada de UI
- Mantener integraciones externas detrás de adapters/services
- Toda decisión de persistencia debe distinguir entre:
  - estado local de partida
  - progreso persistente del usuario
  - contenido administrable
  - sugerencias/moderación

## Lo que Codex debe evitar
- Reescribir el proyecto completo
- Introducir multiplayer online
- Acoplar UI con Supabase directamente
- Hacer auth obligatoria para jugar el tutorial o flujo base
- Mezclar anuncios, premium y lógica de niveles de forma desordenada

## Validación mínima antes de cerrar tareas
- flutter analyze
- dart format .
- flutter test cuando aplique
- verificar que el cambio no rompe guest mode
- verificar que premium y niveles no quedan expuestos por error
