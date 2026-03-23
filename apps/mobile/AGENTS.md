# AGENTS.md

## Alcance de esta app
Esta app representa el MVP de La Profecía para Android/iOS.

## Reglas específicas
- Mantener navegación simple y clara.
- Priorizar guest mode.
- No bloquear el inicio por login.
- Mantener tutorial accesible desde ajustes.
- Separar la lógica del juego de widgets y pantallas.
- El estado de la partida local no debe depender de la red para funcionar.

## Diseño funcional del MVP
Implementar primero:
- onboarding/tutorial
- selección de modo de juego
- configuración de jugadores o parejas
- rondas, turnos, puntos y final de partida
- desbloqueos premium
- flujo de sugerencias
- ajustes
- perfil simple para usuarios autenticados

## Validaciones obligatorias
- loading, empty y error states
- navegación estable
- textos consistentes con producto
- flujos guest y authenticated cubiertos
