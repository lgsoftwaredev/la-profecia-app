# Estado y Persistencia - La Profecia MVP

## 1. Objetivo
Definir claramente que datos viven solo en la partida local y cuales requieren persistencia en backend para evitar mezclas de responsabilidades.

## 2. Tipos de estado

### A. Estado local de partida
Datos efimeros necesarios durante una sesion de juego:
- jugadores de la partida actual
- turno activo y orden
- ronda actual
- puntos acumulados durante la partida
- decisiones temporales de UI

Persistencia recomendada: memoria y, si aplica, cache local de recuperacion corta.

### B. Progreso persistente del usuario
Datos asociados a identidad de cuenta (o migrables desde guest):
- desbloqueos permanentes
- historial de progreso
- estado premium
- preferencias relevantes del usuario

Persistencia recomendada: Supabase (tablas de usuario y progreso).

### C. Contenido administrable
Datos de catalogo que se publican para consumo en app:
- retos/cartas/preguntas oficiales
- configuraciones de nivel
- metadatos de dificultad o categoria

Persistencia recomendada: Supabase con flujo de publicacion controlado.

### D. Sugerencias y moderacion
Datos enviados por usuarios para evaluacion:
- sugerencias pendientes
- estado de revision (pendiente/aprobada/rechazada)
- trazabilidad basica de moderacion

Persistencia recomendada: Supabase con politicas y permisos claros.

## 3. Reglas clave
- No mezclar estado temporal de partida con progreso permanente.
- No acoplar widgets a consultas directas de backend.
- No exponer contenido no moderado como oficial.
- Toda transicion guest -> cuenta debe preservar datos permitidos.

## 4. Beneficios de esta separacion
- Menor riesgo de bugs de consistencia.
- Mejor capacidad de test por tipo de estado.
- Menor costo de evolucion en fases futuras.
- Base clara para escalado sin rehacer el MVP.
